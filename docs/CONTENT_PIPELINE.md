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

**Виняток — програми A0 і A1 як бета (рішення власника 2026-10-12, розширення A0 і A1 — 2026-10-13):** уроки, діалоги, вправи і граматика з пакетів `curriculum_a0_v1`, `curriculum_a0_v2`, `curriculum_a0_v3`, `curriculum_a1_v1` і `curriculum_a1_v2` опубліковано одразу (`PUBLISHED`) після автоперевірок генератора і AI-перевірки. У `content_reviews` записано `verdict = 'auto_passed'`, `reviewer_kind = 'ai'`, нотатка «Бета…». Перевірка носієм іде вже після публікації; після неї додається запис `reviewer_kind = 'human'`. Так само як бета опубліковано **каталог типових помилок** (`linguistic_errors`, пакет `interference_v1`, 74 записи, A0–A2) і **тексти для читання A1** (`reading_texts`, пакет `reading_a1_v1`, 40 текстів) — 2026-10-14, за аналогією з уроками; підтвердження власника — відкрите рішення в `PROJECT_STATE.md` (у генераторах `gen_interference.py` і `gen_reading.py` є перемикач `STATUS`). Обидва батчі не перезаписують наявні коди (`on conflict (code) do nothing`); зміни до вже опублікованих текстів — окремим пакетом із знімком у `content_versions` (перший такий — `20261015_reading_a1_grammar.sql`: граматичні підказки й точніші леми у словничку; написано одним блоком `do $…$`, бо SQL Editor не тримає тимчасові таблиці до кінця файлу — так само робимо наступні такі пакети); `content_reviews` / `content_versions` приймають `entity_type` `linguistic_error` і `reading_text` (M14, M15). Вивіски й тексти **A0** (`reading_a0_v1`, 2026-10-15) — бета, як уроки A0 (`PUBLISHED`); тексти **A2** (`reading_a2_v1`) — `DRAFT`, публікує власник файлом `20261015_reading_a2_publish.sql` (запис рішення — `content_reviews`, `reviewer_kind = 'human'`). Для нового контенту (A2 і далі) знову діє звичайний шлях — спершу перевірка, потім публікація, — якщо власник не вирішить інакше (у генераторі A1 для цього є перемикач `STATUS`).

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

## Розширення уроків (curriculum_a0_v2, 2026-10-13)

- **Дані** `scripts/curriculum_a0_v2_data.py`: на кожен урок — додаткові слова, друга сцена діалогу, «склади», «аудіювання», 2 фрази «скажіть уголос»; нові слова; виправлення перекладів.
- **Знімок бази** `scripts/curriculum_a0_v2_snapshot.json`: слова уроків v1 і їхні переклади. З нього генератор будує вправи на слова — тексти відомі заздалегідь і потрапляють у звіт.
- **Генератор** `scripts/gen_curriculum_a0_v2.py` (`--review` — таблиця всіх вправ на слова). Крім перевірок v1, зупиняється, якщо:
  - слова немає ні в знімку, ні серед нових;
  - в уроці не 8–12 слів;
  - «аудіювання» не з другої сцени;
  - для вправи на слова бракує 3 хибних варіантів.

  Хибні варіанти не перетинаються за змістом із правильним (спільне слово в перекладі, синоніми); слова з однаковим перекладом не бувають відповіддю.
- **Зміна опублікованого перекладу:** стара версія рядка → `content_versions`, запис у `content_reviews`. Зміна застосовується, лише якщо в базі ще старий переклад.
- **Програма A1** (`scripts/gen_curriculum_a1.py`) — той самий підхід, але одразу в повній структурі уроку. Додатково:
  - граматичні теми каркаса отримують правила й публікуються;
  - модулі каркаса — опис і юніт;
  - вправа «вставте слово» — на граматику уроку;
  - можна виправити регістр леми (`LEMMA_FIXES`, стара версія — у `content_versions`).
- **Спільний модуль** `scripts/full_lessons.py` (2026-10-13): клас `Course` — перевірка повного уроку, вправи на слова (хибні варіанти, неоднозначні слова, `NO_VOCAB_EXERCISE`), SQL уроку з перевіркою зайнятого місця, записи `content_reviews`. На ньому працюють `gen_curriculum_a1.py` і `gen_curriculum_a0_v3.py`. Новий рівень (A2) — новий файл даних + короткий генератор поверх `Course`.
- **Доповнення рівня** (`scripts/gen_curriculum_a0_v3.py`, 2026-10-13): нові уроки стають у свій модуль, назви всіх уроків рівня перенумеровуються наскрізно (стара назва → `content_versions`); нова граматична тема; виправлення перекладів (`TRANSLATION_FIXES`) і лем (`LEMMA_FIXES`). Кожне нове слово перед додаванням звіряється з робочою базою (є / немає / інший переклад) — знімок `scripts/curriculum_a0_v3_snapshot.json`.
- **Розмір SQL:** SQL Editor Supabase не приймає великі запити («Query is too large»; 1 МБ — ні, 366 КБ — так). Тримаємо файл ≤ ~300 КБ: уроки — коротким записом (`Course.lesson_sql(compact=True)` + `HELPERS_SQL`, тимчасові функції `pg_temp`), великий пакет — кількома частинами, кожна в одній транзакції з власною самоперевіркою, наступна частина перевіряє, що попередню запущено.
- **Доповнення рівня частинами** (`scripts/gen_curriculum_a1_v2.py`, 2026-10-13): `PARTS` у файлі даних ділить нові уроки на файли по 10; кожна частина несе лише свої нові слова й виправлення, сама перенумеровує назви всіх уроків рівня (за модулем і місцем) і перевіряє себе. Нові слова уроків не повторюють слова наявних уроків рівня (генератор зупиняється).
- **Якщо переклад слова змінять пізніше**, вправи на це слово треба перегенерувати: оновити знімок і запустити генератор. Нові id вправ не з'являться — зміниться лише текст.
