#!/usr/bin/env bash
# Already-merged SQL files are immutable: «Apply SQL» runs each file once (ops.sql_journal),
# so an edit to a merged file never reaches production. Fix → new file (CLAUDE.md, decision 2026-11-19).
#
#   scripts/dev/check_frozen_sql.sh                 # local: branch vs origin/main (merge-base)
#   scripts/dev/check_frozen_sql.sh HEAD^1 HEAD     # CI on pull_request: merge commit vs main tip
set -euo pipefail

if [ "$#" -ge 2 ]; then
  range=("$1" "$2")
else
  range=("${1:-origin/main}...HEAD")
fi

changed=$(git diff --name-only --no-renames --diff-filter=MD "${range[@]}" -- \
  supabase/migrations supabase/data_fixes supabase/sql_journal_baseline.txt)

if [ -n "$changed" ]; then
  echo "Змінено або видалено SQL-файли, які вже є в main (їх не можна міняти — виправлення новим файлом):"
  echo "$changed" | sed 's/^/  /'
  exit 1
fi
echo "OK: уже змерджені SQL-файли не змінено."
