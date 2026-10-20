#!/bin/bash
# Локальна копія бази для перевірки міграцій, пакетів контенту й SQL-тестів (для хмарних сесій Claude; Linux + PostgreSQL 16).
# Postgres на сокеті /tmp, порт 5491, дані — /tmp/pgcur. Запуск: bash scripts/dev/curdb.sh   (~1 хв)
# Лише підняти вже створену базу після перезапуску машини: bash scripts/dev/curdb.sh --start
# Сиди (scripts/dev/seed/) — мінімальна імітація Supabase і слова з робочої бази, яких немає в пакетах; даних користувачів немає.
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"
A="$(cd "$HERE/../../supabase" && pwd)"; S="$HERE/seed"
D=/tmp/pgcur; P=5491; B=/usr/lib/postgresql/16/bin
if [ "$1" = "--start" ]; then
  su postgres -c "$B/pg_ctl -D $D/data -o '-p $P -k /tmp' -l $D/log start" >/dev/null 2>&1 || true
  sleep 1; psql -h /tmp -p $P -U postgres -Atc "select 'ok: lexemes=' || count(*) from lexemes"; exit 0
fi
su postgres -c "$B/pg_ctl -D $D/data stop -m fast" >/dev/null 2>&1 || true
rm -rf $D; mkdir -p $D; chown postgres $D
su postgres -c "$B/initdb -D $D/data -A trust -U postgres >/dev/null"
su postgres -c "$B/pg_ctl -D $D/data -o '-p $P -k /tmp' -l $D/log start >/dev/null"
sleep 1
run() { psql -h /tmp -p $P -U postgres -q -v ON_ERROR_STOP=1 -f "$1" >/dev/null || { echo "FAILED: $1"; exit 1; }; echo "applied $(basename "$1")"; }
run $S/supabase_stub.sql
for f in $A/migrations/*.sql; do
  case "$f" in *m10_*|*m11_*|*m12_*|*m13_*) continue;; esac
  run "$f"
done
run $S/seed_curr.sql
run $A/migrations/20261012240000_m10_lesson_order.sql
run $A/data_fixes/20261012_curriculum_a0_v1.sql
run $S/seed_v2_supplement.sql
run $S/seed_a1_supplement.sql
run $S/seed_a1v2_supplement.sql
run $S/seed_interf_supplement.sql
run $A/migrations/20261013100000_m11_translation_cache.sql
run $A/migrations/20261013120000_m12_user_errors_review.sql
run $A/migrations/20261013140000_m13_exercise_types.sql
run $A/data_fixes/20261013_curriculum_a0_v2.sql
run $A/data_fixes/20261013_curriculum_a0_v3.sql
for f in $A/data_fixes/20261013_curriculum_a1_v1_part*.sql $A/data_fixes/20261013_curriculum_a1_v2_part*.sql; do run "$f"; done
run $S/seed_interf.sql
run $A/data_fixes/20261013_interference_v1.sql
run $A/data_fixes/20261014_reading_a1_v1.sql
run $A/data_fixes/20261015_reading_a1_grammar.sql
run $A/data_fixes/20261015_reading_a0_v1.sql
run $A/data_fixes/20261015_reading_a0_questions.sql
run $A/data_fixes/20261015_reading_a2_v1_part1.sql
run $A/data_fixes/20261015_reading_a2_v1_part2.sql
run $A/data_fixes/20261015_assessments_a0_v1.sql
run $A/data_fixes/20261015_assessments_a1_v1.sql
run $S/seed_a0v4_supplement.sql
run $A/data_fixes/20261015_curriculum_a0_v4_m01.sql
run $A/data_fixes/20261015_curriculum_a0_v4_names.sql
run $S/seed_a0v4_m02_supplement.sql
run $A/data_fixes/20261019_curriculum_a0_v4_m02.sql
run $A/data_fixes/20261019_assessments_a0_v4.sql
for f in $A/data_fixes/20261019_reading_known_a0v4_part[0-9].sql; do run "$f"; done
run $S/seed_a0v4_m03_supplement.sql
run $A/data_fixes/20261019_curriculum_a0_v4_m03.sql
run $A/data_fixes/20261019_assessments_a0_v4_m03.sql
for f in $A/data_fixes/20261019_reading_known_a0v4_m03_part*.sql; do run "$f"; done
run $S/seed_a0v4_m04_supplement.sql
run $A/data_fixes/20261019_curriculum_a0_v4_m04.sql
run $A/data_fixes/20261019_assessments_a0_v4_m04.sql
for f in $A/data_fixes/20261019_reading_known_a0v4_m04_part*.sql; do run "$f"; done
run $S/seed_a0v4_m05_supplement.sql
run $A/data_fixes/20261019_curriculum_a0_v4_m05.sql
run $A/data_fixes/20261019_assessments_a0_v4_m05.sql
run $S/seed_a0v4_m06_supplement.sql
run $A/data_fixes/20261019_curriculum_a0_v4_m06.sql
run $A/data_fixes/20261019_assessments_a0_v4_m06.sql
for f in $A/data_fixes/20261019_reading_known_a0v4_m06_part*.sql; do run "$f"; done
run $S/seed_a0v4_m07_m08_supplement.sql
run $A/data_fixes/20261019_curriculum_a0_v4_m07.sql
run $A/data_fixes/20261019_curriculum_a0_v4_m08.sql
run $A/data_fixes/20261019_assessments_a0_v4_m07.sql
run $A/data_fixes/20261019_assessments_a0_v4_m08.sql
for f in $A/data_fixes/20261019_reading_known_a0v4_m08_part*.sql; do run "$f"; done
run $S/seed_a0v4_m09_supplement.sql
run $A/data_fixes/20261019_curriculum_a0_v4_m09.sql
run $A/data_fixes/20261019_assessments_a0_v4_m09.sql
for f in $A/data_fixes/20261019_reading_known_a0v4_m09_part*.sql; do run "$f"; done
run $S/seed_a0v4_m10_supplement.sql
run $A/data_fixes/20261020_curriculum_a0_v4_m10.sql
run $A/data_fixes/20261020_assessments_a0_v4_m10.sql
for f in $A/data_fixes/20261020_reading_known_a0v4_m10_part*.sql; do run "$f"; done
run $A/data_fixes/20261020_translation_cache_truncated.sql
run $A/data_fixes/20261015_reading_a2_publish.sql
run $S/seed_lexemes_fix_20261020.sql
run $A/data_fixes/20261020_lexemes_a0_problem_words.sql
run $A/data_fixes/20261020_assessments_a0_v4_level.sql
echo "Готово. Тести: for t in supabase/tests/*.sql; do psql -h /tmp -p $P -U postgres -q -v ON_ERROR_STOP=1 -f \$t | tail -1; done"
