<!-- Джерело: Croatia_survival_UPDATED.docx (ТЗ). Розділи збережені з оригінальною нумерацією. Редагуйте тут — це тепер джерело правди. -->

# Програма: граматика, модулі, структура уроку

Граматика A0–B2, модулі кожного рівня, архітектура і схема уроку.

> **Стан у БД (2026-10-12):**
> - **A0** — 10 модулів, 30 уроків, 12 граматичних тем, усе опубліковано як бета;
> - **A1–B2** — модулі (§28–31) і граматичні теми (§22–25) створено як DRAFT, без уроків.
>
> Деталі — `docs/PROJECT_STATE.md` → «Програма A0 + каркас A1–B2», дані — `scripts/curriculum_a0_data.py`.

## 20. Grammar Curriculum

Граматика не повинна бути окремим «підручником». Вона вводиться через:

Context → Examples → Pattern discovery → Short explanation → Controlled practice → Production

## 21. Grammar A0

**Основи**
- personal pronouns;
- biti;
- imati;
- basic word order;
- negation;
- questions;
- gender;
- singular/plural;
- demonstratives;
- basic adjectives;
- basic prepositions;
- numbers;
- time.

## 22. Grammar A1

- present tense;
- regular verbs;
- common irregular verbs;
- accusative;
- locative;
- genitive basics;
- possessives;
- modal verbs;
- imperative;
- comparison;
- question formation;
- negation;
- conjunctions.

## 23. Grammar A2

*Рішення власника 2026-11-12:* «11 нових тем граматики. Граматика потрібна бути як нагадування з іншого рівня та також доповнена за необхідністю рівня A2». Основи perfekt, futur I, зворотних дієслів, орудного й коротких форм давального вже в A1 — в A2 вони йдуть як **нагадування + розширення**. Повний розподіл тем по модулях — `content/reviews/2026-11-12_curriculum_a2_v2_program.md`.

22 теми:

- conditional I (politeness, wishes, purpose *da bih*);
- subordinate clauses (*ako, kad, dok, čim, da, što*);
- aspect;
- pronoun patterns (full and clitic forms in all cases);
- comparative structures;
- genitive expansion (plural, *zbog, umjesto, tijekom, osim, nakon*);
- perfekt — reminder + aspect in the past;
- reflexive verbs — reminder + *sjećati se* + genitive;
- instrumental — reminder + plural, *pred, iza, među*;
- dative — reminder + full forms, plural, *prema*;
- future I — reminder + perfective aspect;
- **new:** plural dative / locative / instrumental; sound changes (fleeting *a*, sibilarisation, jotation); stem extension and irregular plurals (*gradovi, djeca, braća, ime – imena*); possessive adjectives (*Ivanov, mamin*); numbers 2–4, collective numerals, dates; prefixed verbs of motion; impersonal sentences; *se*-passive; clitic order; relative *koji* (start of B1); future II — recognition only.

## 24. Grammar B1

- complex subordinate clauses;
- relative clauses;
- aspect nuances;
- conditional;
- passive;
- reported speech;
- discourse connectors;
- complex prepositional structures;
- participial constructions where appropriate;
- formal/informal register.

## 25. Grammar B2

- advanced aspect;
- nuanced modality;
- idiomatic constructions;
- complex syntax;
- register variation;
- argumentation structures;
- nominalization;
- discourse cohesion;
- pragmatic grammar.

## 26. Curriculum Structure

Level → Module → Unit → Lesson → Learning Objectives → Input → Practice → Production → Assessment

## 27. A0 Curriculum

**Module A0.1 — Pozdrav!**
- greetings;
- goodbye;
- polite expressions;
- basic pronunciation.

**A0.2 — Ja sam...**
- name;
- nationality;
- where you live;
- occupation.

**A0.3 — Brojevi**
- 0–100;
- age;
- prices;
- phone numbers.

**A0.4 — Vrijeme**
- days;
- months;
- today/tomorrow/yesterday;
- clock.

**A0.5 — Obitelj**
- family;
- relationships;
- possessives.

**A0.6 — Moj dom**
- rooms;
- objects;
- location.

**A0.7 — Hrana**
- food;
- drinks;
- ordering.

**A0.8 — Kupovina**
- prices;
- quantities;
- requests;
- payment.

**A0.9 — Grad**
- streets;
- directions;
- transport.

**A0.10 — Survival Croatian**
- help;
- repetition;
- misunderstanding;
- emergency;
- basic administration.

## 28. A1 Curriculum

10 modules:

- 1\. Daily life
- 2\. Food & restaurants
- 3\. Shopping
- 4\. Transport
- 5\. Housing
- 6\. Work
- 7\. Health
- 8\. Social life
- 9\. Croatia
- 10\. A1 integration

## 29. A2 Curriculum

*Рішення власника 2026-11-12:* «12 + 2 модуля які були би цікавими для українців, разом 14 модулів і 86 уроків, уроки повинні закривати модуль, згідно рівня A2»; 20–25 нових слів на урок; уроки A2 — бета. Деталі — `content/reviews/2026-11-12_curriculum_a2_v2_program.md`.

14 modules, 86 lessons:

- 1\. Tourism & travel: the Adriatic (8)
- 2\. Education: courses, university, school (8)
- 3\. My past: childhood & memories (6)
- 4\. People & relationships (7)
- 5\. Work & career (7)
- 6\. Institutions, services & money (6)
- 7\. Health: the system & wellbeing (5)
- 8\. Car in Croatia (6) — for Ukrainians
- 9\. Trouble in the city & environment (6)
- 10\. Media, culture & opinions (6)
- 11\. Croatia: regions & customs (6)
- 12\. Ukrainians in Croatia (6) — for Ukrainians
- 13\. Plans, wishes & arrangements (6)
- 14\. A2 integration (3)

*Реалізація (2026-11-12, PR #19):* усі 86 уроків, 22 теми граматики й 16 перевірок — `scripts/gen_curriculum_a2_v2.py`, `scripts/gen_assessment_a2_v2.py`; бета. Тексти для читання — поки 20 з 56.

## 30. B1 Curriculum

*Програма B1 v1 (пропозиція 2026-11-12, чекає рішень власника):* 14 модулів, 84 уроки, 3 діалоги на урок, 4 тексти для читання й рольова гра в кожному модулі, код ситуації в кожному уроці — `content/reviews/2026-11-12_curriculum_b1_v1_program.md`. Нижче — каркас у базі (10 DRAFT-модулів).

10 modules:

- 1\. Personal life
- 2\. Career
- 3\. Society
- 4\. Media
- 5\. Culture
- 6\. Health
- 7\. Environment
- 8\. Relationships
- 9\. Discussion
- 10\. B1 integration

## 31. B2 Curriculum

12 modules:

- 1\. Complex communication
- 2\. Professional Croatian
- 3\. Society

4\. Politics as language topic, without ideological training

- 5\. Economy
- 6\. Media
- 7\. Culture
- 8\. Science & technology
- 9\. Abstract discussion
- 10\. Argumentation
- 11\. Negotiation
- 12\. B2 integration

## 32. Lesson Architecture

Every lesson contains:

- 1\. Objective
- 2\. Input
- 3\. Vocabulary
- 4\. Grammar
- 5\. Listening
- 6\. Retrieval
- 7\. Reading
- 8\. Speaking
- 9\. Writing
- 10\. Interaction
- 11\. Review
- 12\. Assessment

Not every lesson must contain all components, but every lesson must have a defined skill purpose.

**Діалоги в уроці за рівнями** (рішення власника 2026-11-12; ролі діалогів, 7 нових кодів ситуацій B1 і рольова гра за рівнем — затверджено 2026-11-13): A0–A2 — 2 діалоги; **B1 — 3 діалоги по 8–10 реплік** (нейтральний — ситуація уроку; ускладнення — проблема чи незгода; між друзями — розмовна мова); **B2 — 4 діалоги по 8–10 реплік** (+ регіональний голос — зрозуміти місцеве мовлення: регіональні слова й позначені діалектні форми в тексті, учень відповідає стандартною мовою). Кожен діалог має код ситуації (`conversations.situation`, `lib/situations.ts`), тож потрапляє в розділ «Ситуації». З B1 у програмі рівня для кожного модуля вказано 4 тексти для читання (`reading_texts`) і рольову гру (M9).

**Наріччя й діалекти** (рішення власника 2026-11-13): B1 урок 47 і B2 («Živi hrvatski II») — **текст і зразки**; живе мовлення — лише **посиланнями** на відкриті записи носіїв («🎧 Послухати носія»), власних записів у застосунку немає. Вправи з діалектами — **лише впізнавання за текстом** (в уроці 47 — 3–4: визначити *kaj / ča / što*, зіставити зі стандартним); вправ на слух із діалектом немає; говорити й писати діалектом не вимагаємо; у перевірках рівня діалектів немає. Як показувати — `DESIGN_SYSTEM.md` §4, як готувати — `CONTENT_PIPELINE.md` «Діалектні зразки».

**Нецензурна лексика (psovke) — модуль «18+»** (рішення власника 2026-11-13): окремий модуль із кількома уроками — лайки, сталі вирази, діалоги. Затверджено 2026-11-13: 5 уроків у кінці B1, поза перевірками рівня, відкривається після уроку 8 B1; прихований, поки користувач не ввімкне «Показувати контент 18+» у профілі (з підтвердженням «Мені виповнилося 18»); лише впізнавання (значення, грубість, де доречно, пом'якшені замінники), без рольової гри з AI; **образливі слова про групи людей (національність, релігійна належність, орієнтація, інвалідність) — включено**, з позначкою «образа» і нейтральним відповідником; **бета**. Віковий рейтинг застосунку — обговорити потім. Деталі — `docs/proposals/2026-11-12_b1_b2_dialogues_reading_situations.md` §3а.

**Сленг і розмовна мова — окремі модулі** (рішення власника 2026-11-13): не менше 300 одиниць; B1 — модуль «Сленг: живий хорватський» (6 уроків × 20–25: реакції, люди, гроші й робота, вечірка, Загреб, Далмація), B2 — «Živi hrvatski I» (4 уроки: інтернет, молодіжний сленг, почуття й стосунки, англіцизми); решта — тексти, діалоги «між друзями», рубрика «Živi hrvatski». Деталі — той самий план §3б; список — `content/reviews/2026-11-13_slang_18plus_list.md`.

## 33. Lesson Schema

```yaml
lesson:
id:
level:
module:
title:
objectives:
vocabulary:
grammar:
input:
dialogue:
audio:
reading:
exercises:
production:
speaking:
writing:
interaction:
mediation:
review_items:
assessment:
estimated_minutes:
```
