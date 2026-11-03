# Скрипти першої версії (архів)

Перенесено з кореня проєкту 2026-11-03 без змін. Ніщо в застосунку, CI чи інших скриптах їх не використовує; лишаються для історії.

| Файл | Що робив |
|---|---|
| `check.py` | Рахував рядки A1 у вивантаженні словника (`lexemes_rows (2).csv`). |
| `data.json` | Перші модулі й діалоги до появи бази (`module_1` …). |
| `generate_sql.py` | Будував SQL словника з megahr і `vocabulary_rows (3).csv` (до таблиці `lexemes`). |
| `generate_exercises.py` | Перші вправи напряму в Supabase. |
| `generate_audio_google.py` | Озвучення в Supabase Storage (`<таблиця>/<id>.mp3`); тепер озвучення — `/api/tts` і `supabase/functions/generate-audio`. |

Ключі не зашиті: скрипти читають `NEXT_PUBLIC_SUPABASE_*` з оточення. Актуальні генератори — у `scripts/` (див. `docs/STRUCTURE.md`).
