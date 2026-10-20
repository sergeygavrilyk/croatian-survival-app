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
