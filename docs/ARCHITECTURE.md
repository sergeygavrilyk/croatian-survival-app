<!-- Джерело: Croatia_survival_UPDATED.docx (ТЗ). Розділи збережені з оригінальною нумерацією. Редагуйте тут — це тепер джерело правди. -->

# Технічна архітектура

Стек (Next.js + Supabase + PWA), offline, API, абстракції AI і Speech провайдерів, безпека, доступність, структура репозиторію, архітектура продукту.

## 75. Mobile Architecture

**Жорсткий стек:** Next.js (App Router), React, TailwindCSS, Supabase, PWA. **Правила Next.js:** Вимоги щодо розділення Server Components (отримання даних) та Client Components (інтерактивність, хуки).

**Правила Supabase:** Використання @supabase/ssr для серверних дій та createBrowserClient для клієнтських, обов'язковий RLS для всіх нових таблиць. **Патерн Container/Presentational:** Як ми домовилися раніше (наприклад, page.tsx лише витягує дані, а LessonView.tsx малює UI).

## 76. Offline

Offline:
- lessons;
- vocabulary;
- exercises;
- SRS;
- downloaded audio;
- progress.

Online:
- AI;
- speech recognition;
- speech evaluation;
- synchronization.

## 77. API

```
POST /auth/login
GET /me
GET /curriculum
GET /levels
GET /modules
GET /lessons/{id}
GET /reviews/due
POST /reviews
GET /progress
POST /speech/session
POST /speech/evaluate
POST /conversation
POST /conversation/{id}/message
POST /what-to-say
POST /what-did-i-hear
GET /reading
GET /reading/{id}
POST /analytics/events
```

## 78. AI API Layer

AI functionality must be behind an abstraction:

- AIProvider
- ├── chat()
- ├── structured_output()
- ├── evaluate()
- ├── generate_content()
- └── classify()

This allows changing AI provider without rewriting the product.

## 79. Speech Provider Abstraction

- SpeechProvider
- ├── transcribe()
- ├── synthesize()
- ├── detect_language()
- └── pronunciation_analysis()

## 97. Security

Required:
- encrypted communication;
- secure authentication;
- secure token storage;
- rate limiting;
- API authorization;
- secure audio storage;
- deletion mechanisms;
- privacy controls.

## 98. Accessibility

Support:
- VoiceOver;
- TalkBack;
- dynamic text;
- screen reader labels;
- sufficient contrast;
- captions;
- transcripts;
- keyboard/accessibility navigation where applicable.

## 103. Repository

- /hvatski-ua
- /docs
- PRODUCT_SPEC.md
- LEARNING_SPEC.md
- AI_RULES.md
- ARCHITECTURE.md
- ANALYTICS.md
- /docs/adr
- ADR-001-mobile.md
- ADR-002-database.md
- ADR-003-srs.md
- ADR-004-ai.md
- ADR-005-speech.md
- /content
- curriculum.yaml
- vocabulary.csv
- phrases.csv
- grammar.yaml
- scenarios.yaml
- exercises/
- /app
- /backend
- /ai
- /tests
- /scripts

## 109. Product Architecture

```
                 HUMAN PRODUCT OWNER
                         │
                         ↓
                      AI AGENT
                         │
      ┌──────────────────┼──────────────────┐
      ↓                  ↓                  ↓
   PRODUCT            LEARNING             TECH
   SYSTEM              SYSTEM             SYSTEM
      │                  │                  │
      ├── UX             ├── Curriculum     ├── Mobile
      ├── Analytics      ├── Vocabulary     ├── Backend
      └── Business       ├── Grammar        ├── Database
                         ├── SRS            ├── AI
                         ├── Listening      └── Speech
                         └── Speaking
      │                  │                  │
      └──────────────────┼──────────────────┘
                         ↓
         QA → RELEASE → ANALYTICS → LEARN → ITERATE
```
