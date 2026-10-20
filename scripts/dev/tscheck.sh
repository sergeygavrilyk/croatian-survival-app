#!/bin/bash
# Швидка перевірка типів окремих файлів без node_modules (у хмарній сесії немає npm-реєстру).
# Бібліотеки (react, next, supabase, lucide…) замінено заглушками tscheck/stubs.d.ts, тому помилки
# TS7006/TS7031 («implicitly any») і про LucideIcon / SupabaseClient — це артефакти заглушок, їх ігноруємо.
# Повну перевірку робить власник: npm run typecheck && npm run build.
# Запуск: bash scripts/dev/tscheck.sh app/x/page.tsx components/X.tsx lib/x.ts
set -e
HERE="$(cd "$(dirname "$0")" && pwd)"; ROOT="$(cd "$HERE/../.." && pwd)"
TSC="${TSC:-$(command -v tsc || echo /opt/npm-tools/node_modules/.bin/tsc)}"
TMP="$(mktemp -d)"
python3 - "$HERE/tscheck/stubs.d.ts" "$ROOT" "$TMP/tsconfig.json" "$@" <<'PY'
import json, sys
stubs, root, out, *files = sys.argv[1:]
json.dump({"compilerOptions": {"target": "ES2022", "module": "ESNext", "moduleResolution": "Bundler", "jsx": "preserve",
           "strict": True, "noEmit": True, "skipLibCheck": True, "allowImportingTsExtensions": True, "types": [],
           "paths": {"@/*": [root + "/*"]}, "lib": ["ES2022", "DOM", "DOM.Iterable"]},
           "files": [stubs] + [f if f.startswith('/') else f"{root}/{f}" for f in files]}, open(out, "w"))
PY
"$TSC" -p "$TMP/tsconfig.json" 2>&1 | grep -vE "TS7006|TS7031|LucideIcon|SupabaseClient|next/headers" || true
rm -rf "$TMP"
