# Інструменти розробника (для хмарних сесій Claude)

Перенесено з тимчасової папки сесії 2026-10-19, щоб кожна нова сесія не створювала їх заново. Даних користувачів і ключів тут немає.

| Файл | Навіщо |
|---|---|
| `curdb.sh` | Локальна копія бази (PostgreSQL 16, сокет `/tmp`, порт 5491): імітація Supabase → усі міграції → пакети контенту → сиди. `bash scripts/dev/curdb.sh` — з нуля (~1 хв); `--start` — лише підняти наявну. |
| `seed/` | `supabase_stub.sql` — ролі `anon` / `authenticated`, схеми `auth`, `extensions`; `seed_*.sql` — модулі, уроки й слова з робочої бази, на які посилаються пакети. |
| `tscheck.sh` + `tscheck/stubs.d.ts` | Перевірка типів окремих файлів без `node_modules`: `bash scripts/dev/tscheck.sh <файли>`. Помилки «implicitly any» — артефакти заглушок. |
| `sqltests.sh` | Усі SQL-тести (`supabase/tests/*.test.sql`) на локальній базі: PASS / FAIL на файл, код виходу ≠ 0, якщо щось упало. Так само запускає CI (`.github/workflows/ci.yml`). |

## Як перевіряти зміни

1. `bash scripts/dev/curdb.sh` (або `--start`, якщо база вже є).
2. Новий пакет SQL — запустити **двічі** (`psql -h /tmp -p 5491 -U postgres -v ON_ERROR_STOP=1 -f <файл>`), потім усі тести: `bash scripts/dev/sqltests.sh`.
3. Unit-тести: команда зі скрипту `test` у `package.json` (`node --test --experimental-strip-types …`).
4. Новий пакет контенту — додати рядок `run …` у `curdb.sh` (і сид, якщо пакет посилається на слова робочої бази, яких немає в локальній).

Повну збірку (`npm run build`, `npm run typecheck`, `npm run lint`) з 2026-10-21 робить CI після кожного push; E2E з тестовим акаунтом (`npm run e2e`) — власник на своєму комп'ютері.
