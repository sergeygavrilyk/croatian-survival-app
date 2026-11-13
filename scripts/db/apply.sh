#!/usr/bin/env bash
# Запуск нових SQL-файлів у робочій базі Supabase (workflow .github/workflows/db-apply.yml, після «Approve» власника).
#
#   SUPABASE_DB_URL=postgresql://... bash scripts/db/apply.sh [тест.test.sql ...]
#
# 1. Журнал ops.sql_journal (міграція M20 — запускається щоразу, ідемпотентна) + baseline (supabase/sql_journal_baseline.txt).
# 2. Нові файли — спершу supabase/migrations/*.sql, потім supabase/data_fixes/*.sql, за назвою (дата на початку).
#    Файл з власними BEGIN / COMMIT — як є; без них — однією транзакцією (psql --single-transaction).
#    Перша помилка зупиняє все: решта файлів не запускається, журнал фіксує лише успішні.
# 3. Файл, уже записаний у журнал, не запускається вдруге, навіть якщо його змінили (лише попередження).
# 4. Тести з аргументів (supabase/tests/*.test.sql, транзакція + ROLLBACK) — кожен має вивести «ALL TESTS PASSED».
# 5. Наприкінці (і після помилки), якщо запускався хоч один файл, — очищення статистики запитів
#    (extensions.pg_stat_statements_reset()): довгі тексти контентних пакетів у ній змушували моніторинг Supabase
#    щохвилини писати тимчасові файли на диск і вичерпали бюджет Disk IO (2026-11-12). Дані й схему не зачіпає;
#    не вдалося — лише попередження.
#
# SQL_ROOT — інша тека supabase/ (для самоперевірки скрипта на локальній базі).
set -euo pipefail

: "${SUPABASE_DB_URL:?Немає SUPABASE_DB_URL (секрет середовища production)}"
HERE="$(cd "$(dirname "$0")" && pwd)"
ROOT="${SQL_ROOT:-$(cd "$HERE/../../supabase" && pwd)}"
SUMMARY="${GITHUB_STEP_SUMMARY:-/dev/null}"
RUN_URL="${GITHUB_SERVER_URL:-}/${GITHUB_REPOSITORY:-}/actions/runs/${GITHUB_RUN_ID:-local}"
BY="github-actions:${GITHUB_ACTOR:-local}"
LOG="$(mktemp)"

psql_db() { psql "$SUPABASE_DB_URL" -X -q -v ON_ERROR_STOP=1 "$@"; }
say() { echo "$*"; echo "$*" >> "$SUMMARY"; }
show_log() { echo '```' >> "$SUMMARY"; grep -E "NOTICE|WARNING|ERROR|DETAIL|HINT|CONTEXT" "$LOG" | sed 's/^psql:[^ ]* //' | head -40 | tee -a "$SUMMARY" || true; echo '```' >> "$SUMMARY"; }

say "## Застосування SQL у робочій базі"

# 5. Очищення статистики запитів після запуску файлів (див. шапку). Спрацьовує й тоді, коли файл упав.
touched=0
reset_stats() {
  [ "$touched" -eq 1 ] || return 0
  if psql_db -c "select extensions.pg_stat_statements_reset()" >/dev/null 2>&1; then
    say "🧹 Статистику запитів (pg_stat_statements) очищено — щоб моніторинг Supabase не витрачав Disk IO."
  else
    say "⚠️ Не вдалося очистити статистику запитів (pg_stat_statements) — на дані це не впливає."
  fi
}
trap reset_stats EXIT

# 1. Журнал і baseline
psql_db -f "$ROOT/migrations/20261107120000_m20_sql_journal.sql" > "$LOG" 2>&1 || { cat "$LOG"; say "❌ Не вдалося створити журнал ops.sql_journal (адреса бази / доступ?)."; exit 1; }
BASE_LIST="$(grep -vE '^\s*(#|$)' "$ROOT/sql_journal_baseline.txt" | tr -d '\r' | paste -sd ',' -)"
psql_db -v list="$BASE_LIST" <<'SQL' >/dev/null
insert into ops.sql_journal (filename, applied_by)
select f, 'baseline' from unnest(string_to_array(:'list', ',')) as f
on conflict (filename) do nothing;
SQL

declare -A DONE_SHA=()
while IFS='|' read -r name sha; do DONE_SHA["$name"]="$sha"; done \
  < <(psql_db -At -F '|' -c "select filename, coalesce(sha256, '') from ops.sql_journal")

# 2. Нові файли
applied=0; skipped_changed=0
for dir in migrations data_fixes; do
  for path in "$ROOT/$dir"/*.sql; do
    [ -e "$path" ] || continue
    name="$dir/$(basename "$path")"
    sha="$(sha256sum "$path" | cut -d' ' -f1)"
    if [ -n "${DONE_SHA[$name]+x}" ]; then
      if [ -n "${DONE_SHA[$name]}" ] && [ "${DONE_SHA[$name]}" != "$sha" ]; then
        say "⚠️ \`$name\` уже запущено раніше, але файл змінився — НЕ запускаю. Потрібна зміна — новий файл."
        skipped_changed=$((skipped_changed + 1))
      fi
      continue
    fi
    say ""
    say "### ▶ \`$name\`"
    touched=1
    if grep -qiE '^[[:space:]]*(begin|commit)[[:space:]]*;' "$path"; then mode=(); else mode=(--single-transaction); fi
    if psql_db "${mode[@]}" -f "$path" > "$LOG" 2>&1; then
      show_log
      psql_db -v f="$name" -v s="$sha" -v by="$BY" -v url="$RUN_URL" <<'SQL' >/dev/null
insert into ops.sql_journal (filename, sha256, applied_by, run_url)
values (:'f', :'s', :'by', :'url')
on conflict (filename) do update set sha256 = excluded.sha256, applied_at = now(),
  applied_by = excluded.applied_by, run_url = excluded.run_url;
SQL
      say "✅ запущено"
      applied=$((applied + 1))
    else
      show_log
      say "❌ **Помилка — зупинено.** Цей файл і всі наступні не записані в журнал (зміни файлу відкочено його транзакцією)."
      exit 1
    fi
  done
done
[ "$applied" -eq 0 ] && say "" && say "Нових SQL-файлів немає."

# 3. Тести
fail=0
if [ "$#" -gt 0 ]; then
  say ""
  say "### Тести"
  for t in "$@"; do
    tp="$ROOT/tests/$(basename "$t")"
    if [ ! -e "$tp" ]; then say "– \`$(basename "$t")\` — файлу немає, пропущено"; continue; fi
    if psql_db -f "$tp" > "$LOG" 2>&1 && grep -q "ALL TESTS PASSED" "$LOG"; then
      say "✅ \`$(basename "$t")\` — ALL TESTS PASSED"
    else
      say "❌ \`$(basename "$t")\`"; show_log; fail=1
    fi
  done
fi

say ""
say "Разом: запущено файлів — $applied; змінених уже запущених (пропущено) — $skipped_changed."
exit "$fail"
