<!-- Джерело: Croatia_survival_UPDATED.docx (ТЗ). Розділи збережені з оригінальною нумерацією. Редагуйте тут — це тепер джерело правди. -->

# Оцінювання і валідація навчання

Placement test, assessment, визначення B2, валідація навчального ефекту, головний експеримент.

## 59. Placement Test

Components:

- Vocabulary
- Grammar
- Reading
- Listening
- Speaking

Result:

Estimated CEFR + skill profile + confidence + recommended start

The result must be labelled as an **app estimate**, not an official CEFR certification.

## 60. Assessment

Every level:

Diagnostic → Module assessment → Mid-level assessment → Final assessment

Assessment should measure:

- Can understand
- Can produce
- Can interact
- Can mediate

not simply:

Completed 90% of lessons.

### Реалізація (2026-10-15)

- **Тест рівня на вході (§59)** — `placement-v1`, екран онбордингу (`lib/placement.ts`).
- **Перевірки рівня (§60) для A0 і A1** — по 12 на рівень: тест після кожного з 10 модулів (10 завдань), середина рівня (20, модулі 1–5), фінал (30). Окремої «діагностики» на рівень немає: її роль виконує тест рівня на вході.
- Кожне завдання має навичку §60: `understand` (розумію), `produce` (кажу), `interact` (спілкуюся), `mediate` (переказую). Результат — бал загалом і за кожною навичкою, а не відсоток пройдених уроків.
- **Пройдено** = ≥ 70 % загалом і ≥ 50 % у кожній навичці (рішення власника 2026-10-15). Говоріння можна пропустити — тоді воно не рахується. Тести не блокують уроки. Фінал пройдено → користувач може перейти на наступний рівень.
- Результат позначено як **оцінку застосунку, не офіційний сертифікат CEFR**.
- Схема — M17; код — `lib/assessment.ts`, `app/actions/assessment.ts`, `/lessons/tests`, `/assessment/<slug>`. Подробиці — `docs/PROJECT_STATE.md` → «Перевірки рівня A0 і A1».
- **A0 під уроки за темою (curriculum_a0_v4):** перевірки модулів оновлено разом із модулями (2026-10-19/20), середину й фінал — 2026-10-20 (`scripts/gen_assessment_a0_v4.py level`, `20261020_assessments_a0_v4_level.sql`): середина — лише модулі A0.1–A0.5 (і хибні варіанти теж), фінал — усі 10 модулів (≥ 2 завдань з кожного); жодне речення з перевірок модулів не повторюється, середина й фінал не повторюють одна одну.
- **A2 v2 (2026-11-12, PR #19)** — уже за схемою 2026-11-07: 14 перевірок модулів (2 завдання на урок, від 12 до 20 — разом 180), середина `a2-mid` після A2.7 (30) і фінал `a2-final` (48) = 258 завдань; завдання — з діалогів і вправ уроків A2 і текстів для читання (модулі без текстів — більше «на слух»); у фіналі кожен модуль ≥ 2 завдань. Генератор — `scripts/gen_assessment_a2_v2.py`; середина в застосунку — `midLastModule('A2') = 7`.

- **A0 і A1 — за схемою 2026-11-07 (2026-11-16, пакети v5):** модуль — 2 завдання на урок (від 12 до 20), середина — 30 (A0 — модулі 1–5, A1 — 1–6), фінал — 48 (кожен модуль ≥ 2 завдань); A0 — 218 завдань, A1 — 300; старі завдання (10 / 20 / 30) — DEPRECATED, спроби користувачів не змінюються. Генератор — `scripts/gen_assessment_a0_a1_v5.py` (знімок уроків і текстів — `scripts/assessment_a0_a1_v5_snapshot.json`).
- **«Складіть» — кілька порядків слів (рішення власника 2026-11-15):** інші правильні порядки тих самих плиток — `assessment_items.answer_alternatives` (M27); сервер зараховує будь-який записаний порядок (`lib/assessment.ts`, альтернатива з іншими словами відкидається), розбір показує «Теж правильно: …». Порядки записано вручну за правилом енклітик на другому місці, без порядків-наголосів (`scripts/sentence_order_alternatives.py`); A0 / A1 — 31 з 57 завдань, A2 — 17 з 24; потрібна перевірка носієм (`content/reviews/2026-11-16_sentence_orders.md`).
- **A1 і A2 наново після плану «Дублі» (2026-11-19, задача власника «Перезібрати перевірки рівнів A1 і A2 після цих змін»):** усі 15 тестів A1 (302 завдання) і 16 тестів A2 (260: a2-m11 — 14, бо в A2.11 тепер 7 уроків) — генератором v5 з уроків і текстів, які є в курсі після PR 3–4 (хибні варіанти більше не з прибраних діалогів); A2 тепер теж v5 (`scripts/gen_a2_dupes.py assessments`, знімок — `scripts/assessment_a2_dupes_snapshot.json`); «Складіть» з іншими порядками — A1 21 з 36, A2 17 з 24 (нові порядки — для носія в `content/reviews/2026-11-19_a2_dupes.md`).
- **Стан навичок `skill_progress` (рішення власника 2026-11-15):** після кожної перевірки рівня — рядок на навичку завдань (`listening`, `reading`, `interaction`, `mediation`, `writing`, `speaking`): `xp_or_score` — результат навички в останній перевірці (0–100 %), `level_estimate` — найвищий рівень, де навичка ≥ 70 % у **фінальній** перевірці; рівень не знижується; пропущене говоріння не рахується (`lib/skill-progress.ts`). Збій запису не ламає результат перевірки. Показ у застосунку — окремою задачею.

- **B1 (рішення власника 2026-11-13):** перевірки модулів і середина — за схемою 2026-11-07; **фінал B1 — у форматі іспиту B1 для довгострокового перебування** (звірити з NN 100/21), кількість частин — на розсуд Claude, достатньо для перевірки рівня; результат — неофіційна оцінка застосунку, не сертифікат. Модулі «Сленг» і «18+» мають власні перевірки модуля, які **не впливають на «рівень пройдено»**.

## 61. B2 Definition

B2 is not:

«knows 10,000 words».

B2 requires the ability to:
- understand extended speech;
- interact with reasonable fluency;
- explain ideas;
- discuss abstract/familiar topics;
- support arguments;
- write structured texts;
- handle professional/social communication.

## 107. Learning Validation

Do not evaluate the first version only by:

«Чи подобається app?»

Measure:

**Immediate learning**

Can user recall item immediately?

**Delayed learning**

Can user recall after 1/7/30 days?

**Transfer**

Can user use it in a new sentence?

**Listening**

Can user recognize it in natural speech?

**Production**

Can user produce it without prompt?

**Communication**

Can user successfully complete scenario?

## 108. The Most Important Experiment

Compare:

Traditional lesson

vs.

Context + retrieval + production + SRS

Measure:

- 7-day retention
- 30-day retention
- production accuracy
- listening recognition
- scenario success

The product should evolve from data rather than assumptions.
