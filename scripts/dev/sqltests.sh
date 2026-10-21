#!/bin/bash
# Усі SQL-тести (supabase/tests/*.test.sql) на локальній базі з curdb.sh. Кожен тест — транзакція з ROLLBACK;
# помилка перевірки (pg_temp.ok → raise exception) зупиняє psql (ON_ERROR_STOP) → тест FAIL.
# Запуск: bash scripts/dev/sqltests.sh   (спершу bash scripts/dev/curdb.sh). Код виходу ≠ 0, якщо впав хоч один тест.
HERE="$(cd "$(dirname "$0")" && pwd)"; T="$(cd "$HERE/../../supabase/tests" && pwd)"
P="${PGPORT_CURDB:-5491}"
pass=0; fail=0
for t in "$T"/*.test.sql; do
  if out=$(psql -h /tmp -p "$P" -U postgres -q -v ON_ERROR_STOP=1 -f "$t" 2>&1) && grep -q "ALL TESTS PASSED" <<<"$out"; then
    pass=$((pass + 1)); echo "PASS $(basename "$t")"
  else
    fail=$((fail + 1)); echo "FAIL $(basename "$t")"; echo "$out" | grep -E "ERROR|FAIL|NOTICE" | head -5
  fi
done
echo "SQL-тести: $pass пройдено, $fail впало"
[ "$fail" -eq 0 ]
