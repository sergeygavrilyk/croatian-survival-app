<!-- Джерело: Croatia_survival_UPDATED.docx (ТЗ). Розділи збережені з оригінальною нумерацією. Редагуйте тут — це тепер джерело правди. -->

# Правила роботи AI-агента

Як AI працює над проєктом: порядок дій, що заборонено без людини, класи рішень, Definition of Done, release gate, project state.

## 80. AI Agent Operating Rules

AI must:

0\. Load the project skills for the task type before the first change — table «Skills — завантажити ДО першої зміни» in `CLAUDE.md` — and name them in the first message to the owner; before editing an existing SQL file, check that its PR is not merged and the file is not in `ops.sql_journal` (owner decision 2026-11-13).

1\. Read relevant specifications.

2\. Inspect existing code.

3\. Identify dependencies.

4\. Produce plan.

5\. Implement.

6\. Run tests.

7\. Validate acceptance criteria.

8\. Update documentation.

9\. Report changes.

10\. Generate next tasks.

## 81. AI Must Not

Without human approval:
- change product vision;
- change target users;
- change CEFR scope;
- delete production data;
- change monetization;
- replace core learning methodology;
- introduce major infrastructure;
- publish uncertain linguistic content;
- silently change database contracts.

## 82. AI Decision Classes

**AUTO**

Internal implementation.

**PROPOSE**

Architecture changes, new dependencies, significant UX changes.

**HUMAN**

Product direction, monetization, curriculum philosophy, target audience.

## 94. Definition of Done

Feature is DONE only when:

- ✓ requirements implemented
- ✓ acceptance criteria pass
- ✓ unit tests
- ✓ integration tests where applicable
- ✓ E2E where applicable
- ✓ analytics
- ✓ error handling
- ✓ documentation
- ✓ no critical regression

## 96. Release Gate

Before release AI runs:

- lint
- typecheck
- unit tests
- integration tests
- E2E tests
- DB migration tests
- content validation
- broken-reference scan
- analytics validation
- build

Failed critical gate:

RELEASE BLOCKED

## 101. AI-Generated Next Tasks

After every completed vertical slice, AI must return:

- Implemented
- Tests
- Analytics
- Known limitations
- Technical debt
- Product risks
- Learning risks
- Recommended next 3 tasks

The AI may recommend priorities.

The Human Product Owner makes the final priority decision.

## 102. Project State

**Де і коли оновлювати (рішення власника 2026-11-11).** Після КОЖНОЇ зміни Claude оновлює `docs/PROJECT_STATE.md`, `docs/HISTORY.md` (рядок на задачу; подробиці — в описі PR), `docs/DECISIONS.md` (рішення власника дослівно), `CLAUDE.md` (якщо змінилися правила) і змінені файли ТЗ у трьох місцях: у гілці PR, одразу в папці власника на комп'ютері (не чекаючи мержу; лише наявні документи — нові файли з'являються в папці після `git pull`) і в проєкті claude.ai. Кожне рішення власника, що змінює ТЗ, фіксується в профільному файлі ТЗ і рядком у `docs/SPEC_CHANGELOG.md` (дата, що оновлено, було → стало).

**Розмір документів (рішення власника 2026-11-14).** `PROJECT_STATE.md` ≤ 15 КБ, `HISTORY.md` і `SPEC_CHANGELOG.md` ≤ 30 КБ, ТЗ і довідники ≤ 60 КБ, `DECISIONS.md` — без ліміту. Перевірка — у кожному PR (`wc -c docs/*.md`). Більше ліміту — старе (минулі місяці, виконане, старі чеклісти) переноситься новим файлом у `docs/archive/`; архів заморожений, не редагується і не копіюється в папку власника чи проєкт claude.ai.

Maintain:

```yaml
project:
release:
active_level:
active_module:
active_slice:
completed_slices:
blocked_tasks:
vocabulary:
approved:
published:
curriculum:
lessons_ready:
lessons_published:
tests:
passing:
failing:
content:
draft:
review:
approved:
technical_debt:
risks:
last_updated:
```
