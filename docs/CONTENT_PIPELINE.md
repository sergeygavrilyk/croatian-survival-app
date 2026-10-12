<!-- Джерело: Croatia_survival_UPDATED.docx (ТЗ). Розділи збережені з оригінальною нумерацією. Редагуйте тут — це тепер джерело правди. -->

# Контент: якість, статуси, версії

Pipeline перевірки контенту, статуси, версіонування, Content Definition of Done, перший контент-пакет.

## 64. Content Quality Pipeline

No AI-generated content goes directly to production.

AI generation → Schema validation → Linguistic validation → CEFR validation → Ukrainian validation → Consistency validation

↓

Review → Publish

## 65. Content Status

- DRAFT
- AI_GENERATED
- AUTO_VALIDATED
- NEEDS_REVIEW
- APPROVED
- PUBLISHED
- DEPRECATED

## 66. Content Versioning

Every learning object has:

- id
- version
- created_at
- updated_at
- author
- review_status
- source
- change_reason

## 95. Content Definition of Done

- ✓ vocabulary validated
- ✓ translation validated
- ✓ grammar validated
- ✓ examples validated
- ✓ CEFR appropriate
- ✓ audio available
- ✓ exercise answer verified
- ✓ distractors verified
- ✓ references valid
- ✓ no unsupported vocabulary

## 106. First Content Package

Before generating thousands of lessons:

- A0
- Module 1
- 10 lessons
- ~50 lexical concepts
- ~100 exercises
- 10 dialogues
- audio
- SRS
- speaking
- mini assessment

This package must be tested on real users.

---

# Реалізація в БД (M2 + M3, 2026-10-12)

**Статуси.** У `lexemes`, `phrases`, `conversations`, `lessons`, `units`, `modules`, `levels`, `grammar_topics`, `exercises`:
- поле `status` обов'язкове, CHECK на 7 статусів §65;
- за замовчуванням: нове слово — `AI_GENERATED`, діалог / фраза / урок / вправа — `DRAFT`;
- наявні рядки не змінювались (що було `PUBLISHED`, лишилось).

**Хто що бачить (RLS):**
- гість і користувач — лише `PUBLISHED`. Репліки, кроки уроку, правила граматики видно, коли опубліковано «батька» (діалог, урок, тему);
- адмін (`app_admins`, функція `is_admin()`) бачить усе, додає й змінює. **Видаляти контент через застосунок не може ніхто** — замість видалення `DEPRECATED`.

**Простежуваність (§66):**
- `lexemes.source`, `updated_at`, `published_at` (також у `phrases`, `conversations`, `lessons`);
- тригер `content_touch` сам оновлює `updated_at` і ставить `published_at` при публікації.

**Журнали (лише адмін, append-only):**
- `content_reviews` — кожна перевірка: що, з якого статусу в який, вердикт (`approved` / `changes_requested` / `rejected` / `auto_passed` / `auto_failed`), хто (`human` / `ai` / `script`), знахідки (`findings`), нотатки;
- `content_versions` — знімок попередньої версії (`payload`) з причиною зміни.

**Шлях AI-контенту до користувача:**
1. Генерація батчем (skill `croatian-lexeme-batch`) → рядки `AI_GENERATED`, `source` = назва батчу.
2. Автоперевірка скриптом (діакритики, дублікати, заглушки) → `AUTO_VALIDATED` + запис у `content_reviews` (`reviewer_kind = 'script'`).
3. Лінгвістична перевірка (skill `croatian-content-review`) → `NEEDS_REVIEW` (є зауваження) або `APPROVED` + запис у `content_reviews`.
4. Рішення власника → `PUBLISHED` (SQL Editor або, пізніше, кнопка в адмінці).

Слово, яке власник додає вручну в адмінці, одразу `PUBLISHED` (`source = 'admin_manual'`): це не AI-контент.

**Виняток — програма A0 як бета (рішення власника 2026-10-12):** уроки, діалоги, вправи і граматика A0 з пакета `curriculum_a0_v1` опубліковано одразу (`PUBLISHED`) після автоперевірок генератора і AI-перевірки. У `content_reviews` записано `verdict = 'auto_passed'`, `reviewer_kind = 'ai'`, нотатка «Бета…». Перевірка носієм іде вже після публікації; після неї додається запис `reviewer_kind = 'human'`. Для нового контенту (A1 і далі) знову діє звичайний шлях: спершу перевірка, потім публікація.

# Генерація програми (уроки, 2026-10-12)

- **Дані** — Python-файл (`scripts/curriculum_a0_data.py`): модулі, юніти, уроки (цілі, діалог, слова зі словника, граматика, вправи), граматичні теми з правилами.
- **Генератор** (`scripts/gen_curriculum_a0.py`) спершу перевіряє дані і зупиняється з помилкою, якщо:
  - у хорватському тексті є кирилиця, а в українському її немає;
  - ситуації діалогу немає в `lib/situations.ts`;
  - в уроці немає діалогу, слів або трьох вправ;
  - у «встав слово» варіанти повторюються;
  - у «склади речення» / «аудіюванні» слова повторюються (`LessonView` такого не підтримує).
- **SQL** (`supabase/data_fixes/…`):
  - id детерміновані — повторний запуск нічого не дублює;
  - наявні рядки не змінюються;
  - слово, якого немає в словнику (або воно не опубліковане), зупиняє весь скрипт;
  - у кінці самоперевірка кількості.
- **Звіт перевірки** — `content/reviews/<дата>_<пакет>.md`; тест — `supabase/tests/curriculum.test.sql`.
- Наступні рівні (A1…) — той самий підхід: новий файл даних + генератор, модулі вже є в БД як DRAFT і публікуються разом з уроками.
