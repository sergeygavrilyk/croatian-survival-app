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

- perfekt;
- future;
- dative;
- instrumental;
- genitive expansion;
- aspect;
- reflexive verbs;
- subordinate clauses;
- conditional;
- comparative structures;
- pronoun patterns.

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

10 modules:

- 1\. Experiences
- 2\. Travel
- 3\. Work
- 4\. Administration
- 5\. Health
- 6\. Relationships
- 7\. Problems
- 8\. Plans
- 9\. Opinions
- 10\. A2 integration

## 30. B1 Curriculum

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
