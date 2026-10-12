# Звірка бази даних з ТЗ

> Станом на 2026-10-12. Джерело реальної схеми: `supabase/migrations/20261012000000_baseline.sql` (знято з проєкту Supabase «New app for learning», ref `mhdgozragkkogvxpjksp`). Нормативна модель: `DATABASE.md` §112–132.

## Рішення власника

**Головна таблиця словника — `lexemes`** (2026-10-12). У ТЗ (§116, §118, §129) цю роль виконує розширена `vocabulary`. Тепер усі ці вимоги стосуються `lexemes`: один рядок = одне лексичне поняття, форми — окремо (`vocabulary_forms` у ТЗ → `lexeme_forms`). Таблиці `vocabulary` у базі немає, і її не створюємо.

## Що вже збігається з ТЗ і рішеннями з чатів Gemini

| Область | Стан |
|---|---|
| Ієрархія програми `levels → modules → units → lessons → lesson_items` (§117) | Є |
| Словник `lexemes` + `word_families` (§118) | Є; форми, колокації, фрази, приклади поки в JSONB |
| `vocabulary_type`: core, function_word, formulaic, collocation, chunk | Є (CHECK) |
| Граматика `grammar_topics`, `grammar_rules`, `lesson_grammar` (§119) | Є |
| `srs_reviews` — історія повторень (§120) | Є, з `lexeme_id` |
| `skill_progress` (§120) | Є (без обмеження на 9 навичок) |
| `ai_conversations` / `ai_messages` окремо від статичних `conversations` (§122, §129) | Є |
| RLS увімкнено на всіх 19 таблицях (§126) | Так |
| Дані користувача обмежені `auth.uid()` | Так |

## Код не збігається з базою

> **2026-10-12: виправлено в M1** (код переведено на `lexemes` / `lexeme_id`, створено `lesson_progress`). Діє після запуску міграції `20261012160000_m1_srs_lesson_progress.sql`. Таблиця нижче — для історії.

| Де в коді | Що шукає | Що є насправді | Наслідок |
|---|---|---|---|
| `app/actions/srs.ts`, `app/trainer/page.tsx` | `user_progress.vocabulary_id`, `srs_reviews.vocabulary_id` | колонка `lexeme_id` | оцінка картки падає, SRS не зберігається (у `user_progress` 0 рядків) |
| `app/actions/srs.ts` | upsert `onConflict: 'user_id, vocabulary_id'` | немає unique (user_id, lexeme_id) | upsert неможливий навіть після перейменування |
| `app/actions/vocabulary.ts`, `app/dictionary/page.tsx`, `app/trainer/page.tsx`, `app/admin/page.tsx` | таблиця `vocabulary` | немає | словник, тренажер і адмінка словника не працюють з базою |
| `app/actions/progress.ts` | таблиця `topic_progress` | немає | позначка «тему пройдено» падає |
| `app/(main)/lesson/[id]/page.tsx` | таблиця `lesson_progress` | немає | прогрес уроку не зберігається |
| функція `complete_lesson_and_start_srs` у БД | `topic_progress`, `vocabulary` | немає | будь-який виклик — помилка |

`components/LessonView.tsx` уже використовує `lexeme_id` — правильно.

## Розходження схеми з ТЗ

### Потрібно для найближчих зрізів (VS-001, VS-002)

1. `user_progress`: додати `unique (user_id, lexeme_id)`; додати поля адаптивного SRS з §120 (stability, difficulty, lapses, last_result, direction); `updated_at`.
2. ✅ (M2) `lexemes.status`: було default `PUBLISHED` і без CHECK. За §64–65: default `AI_GENERATED`, CHECK на статуси DRAFT / AI_GENERATED / AUTO_VALIDATED / NEEDS_REVIEW / APPROVED / PUBLISHED / DEPRECATED.
3. ✅ (M2) Публічне читання контенту: було `using (true)` — видно все, включно з чернетками. За §124 і §126 мають бути видимі лише рядки зі статусом `PUBLISHED`.
4. Прогрес уроку: таблиця для завершення уроку (`learning_sessions` з §115 або проста `lesson_progress`).
5. Прибрати або переписати `complete_lesson_and_start_srs` під `lexemes` і `lesson_items`.

### Безпека та керування контентом (§124, §126)

- ~~Адмін визначається за email у політиках~~ → `app_admins` + `is_admin()` (M3).
- ~~Немає `content_versions`, `content_reviews`; у `lexemes` немає `source`, `updated_at`, `published_at`~~ → M2. Окремого `review_status` немає: його роль виконує `status` + журнал `content_reviews`.

### Відсутні сутності з канонічної моделі (§115)

| Група | Відсутні таблиці | Коли потрібні |
|---|---|---|
| Словник | `lexeme_forms` (= vocabulary_forms), `collocations`, `examples`, `topics` (✅ `phrases` — M6, 2026-10-12) | коли JSONB стане тісним; до A1 |
| Помилки українців | `linguistic_errors`, ~~`user_errors`~~ ✅ M9 | Interference Engine (§19) |
| Сесії та спроби | `learning_sessions`, `exercise_attempts` | VS-002, аналітика |
| Сценарії | `scenarios`, `scenario_turns` (`ai_conversations.scenario_id` поки без FK) | VS-004 |
| Говоріння | ~~`speaking_sessions`, `speaking_attempts`~~ ✅ M8 | VS-003 |
| Помічник | `assistant_requests` | VS-005, VS-006 |
| Читання / письмо / медіація | `reading_documents`, `reading_words`, `writing_attempts`, `mediation_tasks`, `mediation_attempts` | після MVP-ядра |
| Оцінювання | ~~`assessments`, `assessment_items`, `assessment_attempts`~~ ✅ M7 | placement у MVP (§90) |
| Операції | `analytics_events`, `ai_usage_events`, `subscriptions`, `notifications`, `sync_operations` | аналітика — з VS-001 (§84); офлайн-синхронізація — MVP |

### Інше

- `exercises`: лише 4 типи (CHECK), немає target_skill, difficulty, acceptable_answers, feedback, status (§121).
- ✅ (M7) `profiles`: додано native_language, current_level, daily_goal_minutes, learning_goals (масив), timezone, onboarding_completed(_at), updated_at (§116).
- `lesson_items.item_id` не має цілісності посилань: це поліморфне поле без FK, тож можлива «висяча» вправа.

## Якість контенту в `lexemes` (3 387 рядків до очищення, 3 374 після)

| Проблема | Кількість | Стан |
|---|---|---|
| Приклади-шаблони («Važno je X u ovoj situaciji», «Primjer rečenice», «To je vrlo X»…) | 348 | ✅ очищено 2026-10-12 (`supabase/data_fixes/20261012_lexemes_cleanup.sql`) |
| Леми зі змішаною кирилицею/латиницею або сербською кирилицею | 17 (13 дублікатів + 4 без пари) | ✅ виправлено |
| Дублікат з одруківкою `osobna iskazenica` | 1 | ✅ виправлено |
| `li` → «li» | 1 | ✅ виправлено |
| Репліки діалогів і речення записані як леми (`A: Dobar dan!…`, `Developer: …`, `Konobar: …`) | 125 | ✅ рішення: 39 реплік → 11 діалогів, 86 → `phrases`; у `lexemes` — DEPRECATED (скрипт M6 + data_fix) |
| `normalized` з діакритикою | 636 | виправити одним UPDATE (без діакритики) |
| Без `part_of_speech` | 1 410 | доповнити |
| Без прикладів (після очищення) | ~2 350 | доповнювати поступово, з перевіркою |
| Усі рядки мають статус `PUBLISHED` без перевірки | 3 387 | рішення про статуси — див. п. 2 вище |

## Порядок міграцій

1. ✅ **M1 — полагодити SRS і уроки** (код готовий, міграцію запускає власник): unique на `user_progress (user_id, lexeme_id)`, поля SRS, `updated_at`; таблиця прогресу уроку; прибрати `complete_lesson_and_start_srs`; паралельно перевести код з `vocabulary`/`vocabulary_id` на `lexemes`/`lexeme_id`.
2. ✅ **M2 — статуси контенту** (`20261012201000_m2_content_status.sql`, 2026-10-12): CHECK і NOT NULL на статуси в 9 таблицях, default `AI_GENERATED` для нових слів і `DRAFT` для решти, читання лише `PUBLISHED` (частини — за «батьком»), `exercises.status`, `source` / `updated_at` / `published_at` + тригер, `content_reviews`, `content_versions`. Існуючі рядки не змінюються.
3. ✅ **M3 — адміни** (`20261012200000_m3_app_admins.sql`): `app_admins`, `is_admin()`, політики за роллю замість email у всіх таблицях контенту (читання всього, додавання, зміна; без видалення), адмін бачить усю аналітику.
4. ✅ **M4 — аналітика:** `analytics_events` (M4) і `ai_usage_events` (`20261012202000_m4b_ai_usage_events.sql`).
5. ✅ **M7 — онбординг і тест рівня** (`20261012210000_m7_onboarding_placement.sql`): поля профілю, `assessments`, `assessment_items`, `assessment_attempts`.
6. ✅ **M8 — говоріння** (`20261012220000_m8_speaking.sql`): `speaking_sessions`, `speaking_attempts` (без аудіо, лише текст розпізнавання).
7. ✅ **M9 — рольова гра** (`20261012230000_m9_roleplay.sql`): `ai_conversations` (ситуація, рівень, репліки, підсумок, кінець), `ai_messages` (переклад, виправлення; append-only), `user_errors`.
8. ✅ **M10 — порядок уроків** (`20261012240000_m10_lesson_order.sql`): `lessons.order_index` (NOT NULL, ≥ 1), `unique (unit_id, order_index)`, тригер ставить новий урок у кінець юніту. Разом із ним — data-fix `20261012_curriculum_a0_v1.sql` (програма A0 + каркас A1–B2).
9. Далі — таблиці під кожен вертикальний зріз (speaking, assistant_requests, assessments…), коли до нього доходить черга.
