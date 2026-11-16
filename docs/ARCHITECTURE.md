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

**Прогрес без мережі** (рішення власника 2026-11-16): без мережі завершення уроку й тексту, слово в повторення й події навчання (етап 1), оцінки тренажера й «Помилок» (етап 2) кладуться в чергу на телефоні й відправляються самі, щойно є мережа; сервер приймає кожну дію рівно один раз (журнал `client_ops`, M28). Черга чекає до **14 днів** (не більше 200 дій), старше — відкидається з повідомленням. Серія 🔥 і «повторити завтра» рахуються за **днем, коли людина вчилася**, а не коли з'явилась мережа. Посеред уроку нічого не перезавантажується. План — `docs/proposals/2026-11-16_offline_sync.md`.

**Що ще для офлайну** (рішення власника 2026-11-16, вечір):
- **Кеш сторінок** — 30 днів і до 200 сторінок (замість стандартних 24 годин і 32); на слабкій мережі сторінка відкривається з кешу через 5 с (`lib/pwa-cache.ts`).
- **Підказка «Додати на початковий екран»**: без іконки на початковому екрані Safari на iPhone видаляє збережене (кеш, копії, чергу) після 7 днів без відкриття сайту.
- **Словник без мережі** — пошук серед слів, що вже є на телефоні (тренажер, відкриті уроки); повний словник на телефоні — ні.
- **Звук (озвучення) — лише з мережею**; вправи на слух і говоріння без мережі можна пропустити. Пункт «downloaded audio» вище поки не робимо.
- **Перевірки рівня — лише з мережею** (оцінює сервер); відповіді без мережі лишаються на екрані.

**Уроки й фрази наперед** (рішення власника 2026-11-16, вечір: «3–5 наступних уроків поточного модуля разом з їхніми текстами», «всі фрази всіх ситуацій»):
- Відкрили урок з мережею → за кілька секунд телефон тихо зберігає **5 наступних уроків цього модуля** і **до 4 текстів модуля** (тексти — за рівнем і номером модуля). На «Сьогодні» — урок «Продовжити» з наступними, список ситуацій і **кожну ситуацію лише з фразами**; діалоги — лише з інтернетом («Діалоги відкриються з інтернетом»).
- Сторінки лягають у той самий кеш сторінок (30 днів, ≤ 200): запит з заголовком `X-Offline-Prefetch: page`, лише відповіді 200 (`lib/offline-prefetch.ts`, `lib/pwa-cache.ts`). Відвідану онлайн сторінку (повну) не переписуємо. Не частіше ніж раз на 12 год на план; без мережі, з економією трафіку чи до старту service worker — нічого.
- **Усі рівні без змін коду:** уроки, тексти й ситуації беруться з опублікованого контенту бази, тож B1 / B2 підхопляться, щойно їх опублікують. Обсяг на телефоні обмежений планом, а не рівнем: ≤ 9 сторінок за урок (~1–1,5 МБ), ситуації з фразами ~0,5 МБ (самі фрази ~11 КБ).
- **Копії уроків і текстів у браузері** (localStorage, ~5 МБ на сайт) — не більше 40 найсвіжіших кожного виду; переповнилось — старші прибираються.
- **Вихід з акаунта** прибирає збережені сторінки (там «Сьогодні», ім'я, прогрес); черга прогресу й копії уроків лишаються.

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
