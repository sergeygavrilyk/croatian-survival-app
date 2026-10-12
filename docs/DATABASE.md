<!-- Джерело: Croatia_survival_UPDATED.docx (ТЗ). Розділи збережені з оригінальною нумерацією. Редагуйте тут — це тепер джерело правди. -->

# База даних

> **Рішення власника (2026-10-12):** роль канонічної таблиці словника `vocabulary` виконує наявна таблиця **`lexemes`**; `vocabulary_forms` → `lexeme_forms`, `vocabulary_id` → `lexeme_id`. Реальна схема — `supabase/migrations/`, звірка з ТЗ — `DB_GAP_ANALYSIS.md`.

**Пріоритет:** розділи 112–132 (Database Architecture Alignment Addendum v2) — нормативні. Вони замінюють і уточнюють початкові розділи 17 і 67–70, які наведені в кінці файлу лише для історії.

STATUS / PRECEDENCE This addendum is a normative extension to “Croatia survival(1).pdf”. It specifically supersedes and clarifies the database section wherever the existing implementation is incomplete or conflicts with the product/learning requirements. Product vision, CEFR scope, learning methodology, UX/PWA direction, AI architecture, API direction, vertical-slice strategy and release principles remain unchanged unless this addendum explicitly states otherwise.

## 112. Database Alignment Principle

The existing Supabase schema is treated as an implementation baseline, not as the specification itself. Existing data and working flows must be preserved where possible, but the canonical data model must satisfy the product requirements. New requirements must not be weakened simply because the current schema cannot represent them.

Compatibility strategy: preserve the existing tables; extend them where appropriate; add normalized domain tables where a new capability needs a first-class entity; migrate incrementally; use adapters/views at API boundaries when necessary to keep legacy reads working. No destructive replacement is part of this change.

## 113. What is reusable from the existing schema

- profiles.id is already tied to auth.users(id), which remains the canonical user identity boundary. 
- topics already provides a lightweight taxonomy with Croatian/Ukrainian titles and a level attribute. 
- vocabulary already stores Croatian text, Ukrainian translation, audio URL, level, frequency rank and extensible details JSONB.
- user_progress already stores per-user/per-vocabulary review timing and legacy repetition/ease/interval fields. These remain compatibility fields.
- conversations already stores reusable dialogue lines with speaker, Croatian text, Ukrainian translation, ordering and audio.
- exercises already supports basic topic/conversation/vocabulary references and a minimum exercise object. 
- topic_progress can remain as compatibility progress for the current topic-based UI while richer lesson/skill progress is introduced.

## 114. Existing-schema gaps that must NOT constrain the ТЗ

| Area | Current limitation | Canonical ТЗ decision |
|---|---|---|
| Curriculum | topics only; no level/module/unit/lesson hierarchy | Add levels → modules → units → lessons → lesson_items. topics remains reusable taxonomy. |
| Vocabulary | item_type is limited to word/phrase/dialogue_line; inflections are not modeled | One row represents a lexical concept; forms, phrases, collocations, examples and word families get first-class structures. |
| Grammar | No grammar entities | Add grammar_topics, grammar_rules, lesson_grammar. |
| Ukrainian interference | No persistent error model | Add linguistic_errors / user_errors and error examples. |
| SRS | Legacy simple scheduler fields only | Keep legacy fields, add adaptive SRS state + immutable review history. |
| Skills | No independent skill progress | Add skill_progress for 9 skill dimensions. |
| Exercises | Only 4 exercise types | ТЗ requires an extensible engine supporting 20 exercise modes. |
| Speaking | No speech session/attempt model | Add speaking_sessions and speaking_attempts. |
| AI | conversations is static content, not runtime AI state | Keep conversations as reusable content; add ai_conversations / ai_messages. |
| What Do I Say / Hear | No persistence | Add assistant_requests. |
| Reading | No reading model | Add reading_documents / reading_words. |
| Writing | No writing model | Add writing_attempts. |
| Mediation | No mediation model | Add mediation_tasks / mediation_attempts. |
| Assessment | No placement/module/mid/final model | Add assessments / assessment_items / assessment_attempts. |
| Analytics | No event table | Add append-only analytics_events and AI cost usage. |
| Content governance | No publication/review/version lifecycle | Add content_versions / content_reviews and published-only public reads. |
| Offline sync | No idempotent server contract | Add sync_operations plus timestamps/version fields. |
| Subscriptions / notifications | Absent | Add subscriptions / notifications because the ТЗ lists these entities. |
| Admin RLS | Hard-coded email-based write policy | Use app_admins/role claims and trusted server operations. |

## 115. Canonical domain model

The canonical model separates content, user learning state, runtime sessions, assessment, governance and analytics. This avoids using JSONB as a substitute for relational entities needed by API contracts, joins, indexing, RLS and analytics.

**Curriculum: levels, modules, units, lessons, lesson_items**

**Learning content: topics, vocabulary, vocabulary_forms, word_families, phrases, collocations, examples, grammar_topics, grammar_rules, lesson_grammar**

**Scenario content: scenarios, scenario_turns**

**Media / reading: reading_documents, reading_words**

**User learning state: profiles, user_progress, srs_reviews, skill_progress, learning_sessions, exercise_attempts, user_errors, topic_progress**

**Runtime: speaking_sessions, speaking_attempts, ai_conversations, ai_messages, assistant_requests, ai_usage_events, writing_attempts, mediation_attempts**

**Assessment: assessments, assessment_items, assessment_attempts**

**Governance: content_versions, content_reviews, app_admins**

**Operations: analytics_events, subscriptions, notifications, sync_operations**

## 116. Existing table compatibility contract

| Existing table | Keep? | Canonical interpretation / additions |
|---|---|---|
| profiles | YES | User profile and personalization context. Add native_language, target_language, current_level, daily_goal_minutes, learning_goal, timezone, onboarding_completed, updated_at. |
| topics | YES | Reusable taxonomy only. Add slug, parent_topic_id, status, updated_at. Do not use topics as a replacement for modules/units/lessons. |
| vocabulary | YES | Canonical lexical concept record. Add lemma/normalized_lemma/part_of_speech/gender/number/aspect/transitivity/frequency_score/register/regionality/word_family_id/ukrainian_explanation/status/version/source/review_status/updated_at/published_at. |
| user_progress | YES | Current per-user lexical mastery/SRS state. Keep repetition_count/ease_factor/interval_days as legacy compatibility. Add adaptive fields and strengths. |
| conversations | YES | Static reusable dialogue lines/content. Add level/register/scenario_id/status/version/source/review_status/updated_at. It must not become runtime AI chat storage. |
| exercises | YES | Canonical exercise content. Add lesson_id, target_skill, difficulty, target_grammar, expected_answer, acceptable_answers, distractors, feedback, status/version/review metadata. |
| topic_progress | YES | Compatibility progress. Add optional lesson/unit linkage and progress_percent. Add unique(user_id,topic_id). Rich progress is in skill_progress and lesson/session records. |

## 117. Curriculum and lesson schema

The ТЗ defines the learning hierarchy as Level → Module → Unit → Lesson → Learning Objectives → Input → Practice → Production → Assessment. The database must represent that hierarchy directly. A topic may classify many objects, but it is not a curriculum container.

| Table | Required fields / purpose |
|---|---|
| levels | code PK (A0/A1/A2/B1/B2), title_ua, title_hr, order_index, status, timestamps |
| modules | id, level_code FK, title, description, order_index, status, timestamps |
| units | id, module_id FK, title, objectives JSONB, order_index, status, timestamps |
| lessons | id, unit_id FK, level_code, title, objectives JSONB, estimated_minutes,status, version, review_status, source, change_reason, timestamps, published_at |
| lesson_items | id, lesson_id FK, item_type, item_id, order_index, required, skill |

## 118. Vocabulary model

- One vocabulary record represents one learning concept or reusable lexical unit. It must not count every inflected form as a separate concept.
- item_type is an extensible taxonomy: core_vocabulary, function_word, formulaic, collocation, chunk, proper_noun, phrase. The current implementation values are therefore not the final ТЗ contract. 
- vocabulary_forms stores inflected forms such as radim/radio/radila while linking them to one parent lexical concept.
- word_families groups related lexical concepts.
- phrases and collocations are first-class content because the ТЗ explicitly requires formulaic language, collocations and chunks.
- examples stores contextual usage and can link to vocabulary or phrase.

| Entity | Purpose |
|---|---|
| word_families | Lexical-family grouping; avoids counting forms as new concepts. |
| vocabulary_forms | Inflected/derived forms with grammatical metadata. |
| phrases | Formulaic / multiword expressions. |
| collocations | Preferred word combinations. |
| examples | Context examples, translations, audio and content metadata. |

## 119. Grammar and Ukrainian interference

| Table | Purpose |
|---|---|
| grammar_topics | Grammar topic taxonomy with CEFR level and status. |
| grammar_rules | Ukrainian explanations, patterns and validated examples. |
| lesson_grammar | Many-to-many link between lessons and grammar topics. |
| linguistic_errors | Canonical error taxonomy and examples, including Ukrainian interference categories. |
| user_errors | User-specific error history used by adaptive learning. |

Grammar remains contextual: Context → Examples → Pattern discovery → Short explanation → Controlled practice → Production. The database must support this sequence rather than making grammar a detached textbook entity.

## 120. SRS and mastery - canonical model

The current user_progress model is retained because it contains live-compatible review data. However, the ТЗ requires a richer scheduler. Therefore user_progress becomes the current state, while srs_reviews becomes immutable history/evidence.

| Entity | Purpose |
|---|---|
| user_progress | Current state for one user + one vocabulary concept: mastery_state, stability, difficulty, retrievability, counts, next review and directional/context strengths. |
| srs_reviews | Append-only review events: result, grade, direction, response time, old/new stability/difficulty, scheduled_for, source. |
| learning_sessions | Session-level learning evidence needed for the Successful Learning Session metric. |
| exercise_attempts | Per-attempt evidence for retrieval, production, response time and feedback. |

| Entity | Purpose |
|---|---|
| skill_progress | Independent state for Vocabulary, Grammar, Listening, Reading, Speaking, Writing, Pronunciation, Interaction, Mediation. |

The legacy repetition_count/ease_factor/interval_days fields remain readable during migration but are not the final scheduling contract. The scheduler must use stability, difficulty, retrievability, review history, lapses, time since review, learning direction and item importance, and must be benchmarked against real learning data.

## 121. Exercise engine

The existing four-type CHECK constraint is too narrow for the ТЗ and therefore must not become an architectural limitation. The canonical exercise engine must support the following types:

- flashcards
- multiple_choice
- audio_recognition
- translation
- reverse_translation
- cloze
- fill_gaps
- sentence_ordering
- sentence_construction
- dictation
- listening_comprehension
- grammar_correction
- free_response
- speaking
- writing
- role_play
- matching
- categorization
- pronunciation_imitation
- information_gap

An implementation may initially activate only a subset, but the data model must be extensible so adding a new exercise type does not require a breaking migration. Exercise schema stores level, difficulty, target skill, target lexemes, target grammar, expected answer, acceptable answers, distractors and feedback.

## 122. Speaking, scenarios and AI runtime

| Table | Purpose / key fields |
|---|---|
| scenarios | Real-life scenario library: category, level, title_ua/title_hr, objective, register, difficulty, status/version. |
| scenario_turns | Ordered scenario turns, role, prompts, expected intent, allowed response patterns, feedback. |
| speaking_sessions | User speaking session, link to scenario/lesson, target prompt and level, timestamps. |
| speaking_attempts | Audio, transcript, expected meaning, meaning/comprehensibility signals, grammar/pronunciation feedback, retry number, provider. |
| ai_conversations | Runtime user↔︎AI conversation state: user, scenario, mode, level, module, status, timestamps. |
| ai_messages | Individual AI/user messages with role, content, audio, provider/model metadata. |
| assistant_requests | One-shot What Do I Say? / What Did I Hear? requests and structured outputs. |
| ai_usage_events | Token/STT/TTS/latency/cost measurements. |
| CRITICAL SEPARATION Existing conversations is content, not a runtime chat session. Static dialogue lines may be reused by scenario/lesson content; user conversations must be stored in ai_conversations and ai_messages. This preserves the current table while avoiding semantic overload. |  |

## 123. Reading, writing, mediation and assessment

| Table | Purpose |
|---|---|
| reading_documents | Levelled reading content and text. |
| reading_words | Token-level index linking a word/form to vocabulary for tap-to inspect and SRS. |
| writing_attempts | User submissions and AI feedback for grammar, vocabulary, clarity, register and naturalness. |
| mediation_tasks | CEFR-style mediation tasks with source/target languages and key points. |
| mediation_attempts | User mediation response and feedback. |
| assessments | Diagnostic/module/mid/final assessments. |
| assessment_items | Ordered weighted skill-linked assessment items. |
| assessment_attempts | Estimated CEFR, confidence, skill profile, recommended start and is_official=false by default. |

## 124. Content governance and versioning

- Content lifecycle remains DRAFT → AI_GENERATED → AUTO_VALIDATED → NEEDS_REVIEW → APPROVED → PUBLISHED → DEPRECATED.
- No AI-generated content goes directly to production; the database must store review status, version, source and change reason.
- Public read policies must expose only PUBLISHED content.
- content_versions stores snapshots; content_reviews stores validation and human-review findings. 
- app_admins replaces the hard-coded administrator email as the authorization model. The email may identify the current operator operationally, but must not be the database security boundary.

| Table | Purpose |
|---|---|
| content_versions | Versioned content payload / audit trail. |
| content_reviews | Validation/review records. |
| app_admins | Trusted admin role mapping. |

## 125. Analytics, subscriptions, notifications and offline sync

| Table | Purpose |
|---|---|
| analytics_events | Append-only product/learning events including lesson, exercise, review, speaking, conversation, reading, word_saved/mastered, What Do I Say/Hear, subscription events. |
| subscriptions | User subscription state and provider identifiers. |
| notifications | User notification schedule/read state. |
| sync_operations | Idempotent queue for offline mutations and server reconciliation. |

A Successful Learning Session contains retrieval + production + feedback/review. learning_sessions and analytics_events must provide sufficient evidence to calculate this metric without reconstructing it from UI clicks.

## 126. RLS and security contract

The current public SELECT policies on topics, vocabulary, conversations and exercises cannot remain the canonical production security model because they do not encode the content publication state. They may be tolerated only for a temporary migration state. The target model is:

| Data class | SELECT | Write |
|---|---|---|
| Published content | anon/authenticated only where status = PUBLISHED | Trusted server/admin only |
| User-owned learning | auth.uid() = user_id | auth.uid() = user_id |
| Runtime AI/speech | auth.uid() = user_id | auth.uid() = user_id |
| History/events | user-scoped reads where needed | INSERT only; no client UPDATE/DELETE |
| Governance/admin | admin/service only | admin/service only |
| Subscriptions | user-scoped read | server/provider sync |
| Notifications | user-scoped read/update read-state | server for scheduling/content |

All new tables must have RLS enabled. User-owned rows use auth.uid()-scoped policies. Content writes do not originate from ordinary client sessions. Analytics/history tables should be append-only from the client-facing perspective.

## 127. Data integrity and indexes

- unique(user_id, vocabulary_id) on user_progress.
- unique(user_id, skill) on skill_progress.
- unique(lesson_id, order_index) on lesson_items.
- unique(module_id, order_index) on units; unique(level_code, order_index) on modules. 
- Indexes for user_id + next_review_date, user_id + review timestamp, vocabulary normalized_lemma, level + frequency_rank, conversation_id + created_at, event_name + occurred_at, user_id + occurred_at. 
- FKs are required for core ownership and curriculum relations; polymorphic lesson_items is intentionally limited to content composition and should be validated at the application/domain layer.

## 128. Migration strategy - backward compatible

1\. Add new tables and nullable extension columns first.

2\. Validate existing data and add non-destructive indexes/FKs.

3\. Backfill profiles and CEFR levels.

4\. Create curriculum hierarchy alongside topics.

5\. Normalize vocabulary metadata and inflected forms while retaining details JSONB for extension fields. 6. Populate rich SRS state from legacy user_progress where possible; retain legacy values for compatibility. 7. Introduce lesson_items and route the new Lesson API through the canonical curriculum hierarchy. 8. Add scenarios, speaking and AI runtime tables.

9\. Add reading, writing, mediation and assessment tables.

10\. Add content governance and PUBLISHED-only RLS.

11\. Add analytics, subscriptions, notifications and sync operations.

12\. Only after validation may legacy-only fields/policies be deprecated; this document does not authorize destructive cleanup.

## 129. Explicit conflict resolutions

| Conflict | Final ТЗ rule |
|---|---|
| topics vs modules/units/lessons | topics is taxonomy; curriculum hierarchy is separate. |
| conversation content vs AI runtime | conversations is reusable content; ai_conversations/ai_messages is runtime. |
| word vs inflected form | vocabulary is concept; vocabulary_forms is form. |
| legacy SRS scheduler | legacy fields are compatibility only; adaptive scheduler is canonical. |
| four exercise types | exercise_type must be extensible to the full exercise engine. |
| public content SELECT | only published content is public. |
| email-based admin | role-based admin authorization is canonical. |
| topic_progress as all progress | retain compatibility, but lesson/skill/session data is canonical. |
| JSONB | extension mechanism, not a replacement for required relational entities. |

## 130. Updated database section - normative replacement text

USE THIS TEXT IN THE MAIN ТЗ The database section below is the canonical wording to use in the main Croatia survival specification. It replaces the earlier database wording where there is any mismatch.

Database: hybrid relational model, additive migration. Existing tables are preserved for compatibility. New normalized tables are added for curriculum, grammar, SRS history, skills, runtime AI/speech, reading, writing, mediation, assessment, content governance, analytics and offline synchronization.

Users: profiles extends the auth.users identity with native language, target language, current CEFR level, daily goal, learning goal, timezone and onboarding state.

Curriculum: levels → modules → units → lessons → lesson_items.

Vocabulary: one row per lexical concept. Inflected forms, word families, phrases, collocations and examples are modeled separately. The target is approximately 10,000 high-value lexical concepts, not 10,000 surface forms.

SRS: user_progress stores current state; srs_reviews stores immutable review history. The scheduler uses stability, difficulty, retrievability, review history, lapses, elapsed time, learning direction and item importance. Legacy repetition/ease/interval fields remain only for compatibility during migration.

Skills: progress is tracked independently for Vocabulary, Grammar, Listening, Reading, Speaking, Writing, Pronunciation, Interaction and Mediation.

Exercises: the schema is extensible and supports the complete exercise engine required by the specification. Each exercise contains level, difficulty, target skill, target lexemes, target grammar, expected/acceptable answers, distractors and feedback.

Speaking/AI: runtime sessions are user-owned and separated from static dialogue content. Speech attempts store transcript and evaluation evidence. AI conversations/messages store runtime turns. One-shot assistant requests support What Do I Say? and What Did I Hear?.

Reading/Writing/Mediation/Assessment: each is persisted as a first-class domain so the product can measure transfer, production, interaction and mediation rather than lesson completion alone.

Content governance: all content is versioned/reviewed and public reads expose only PUBLISHED content. Admin authorization is role-based.

Analytics: append-only event data supports the Successful Learning Session North Star Metric and supporting learning/retention metrics. AI usage/cost is tracked separately.

Offline: lesson/content/progress writes may originate offline and synchronize idempotently through sync_operations. AI and speech services remain online.

RLS: enabled on every user-owned/new table. User rows are scoped by auth.uid(). Content writes are trusted server/admin operations.

## 131. Acceptance criteria - database is aligned when

- A0 through B2 can be represented without treating topics as the curriculum hierarchy. 
- One lexical concept can have many forms without inflating the concept count.
- SRS supports immediate and delayed review evidence and adaptive scheduling inputs. 
- All 9 skills can have independent progress.
- 20 exercise modes can be represented without schema redesign.
- Speaking supports prompt → recording → transcription → evaluation → correction → retry. 
- AI runtime is separated from static dialogue content.
- What Do I Say? and What Did I Hear? can be persisted and linked to learning context. 
- Reading allows token/word lookup and SRS linking.
- Writing and mediation attempts are measurable.
- Placement and assessment distinguish app estimates from official certification.
- Content QA/versioning is enforceable and public content is PUBLISHED-only.
- RLS prevents cross-user data access and direct client content mutation.
- Offline learning progress can synchronize idempotently.
- VS-001 can execute end-to-end with DB + API + UI + Content + SRS + Analytics + Tests.

## 132. Architecture decision

Adopt the hybrid, additive, backward-compatible database architecture in this addendum. The existing schema is retained as a compatibility layer and useful MVP core, but the canonical ТЗ data model is defined by the product requirements. Where the current schema cannot represent those requirements, the ТЗ is not reduced; the database is expanded.

This preserves the original architecture principle that the product evolves from validated learning data and that one complete vertical slice must include database, API, UI, content, SRS, analytics and tests.

---

# Додаток: початкові схеми з основного ТЗ (замінені розділами 112–132)

## 17. Vocabulary Database

```yaml
lexeme:
id:
lemma:
normalized:
language: hr
part_of_speech:
gender:
number:
aspect:
transitivity:
cefr:
frequency_rank:
frequency_score:
ukrainian_translation:
ukrainian_explanation:
register:
regionality:
topic:
subtopics:
word_family_id:
forms:
nominative:
genitive:
dative:
accusative:
locative:
instrumental:
collocations:
phrases:
examples:
pronunciation:
audio:
common_errors:
ukrainian_interference:
learning_units:
prerequisites:
status:
version:
```

## 67. Database

Core:

- users
- user_profiles
- levels
- modules
- units
- lessons
- lexemes
- lexeme_forms
- word_families
- translations
- collocations
- phrases
- examples
- grammar_topics
- grammar_rules
- exercises
- exercise_options
- scenarios
- scenario_turns
- user_lexemes
- reviews
- srs_states
- user_skills
- assessments
- assessment_attempts
- conversations
- conversation_turns
- speech_attempts
- reading_documents
- reading_words
- analytics_events
- content_versions
- content_reviews
- subscriptions
- notifications

## 68. User Schema

users

-----

- id UUID PK
- email
- auth_provider
- status
- created_at
- last_login_at
- user_profiles

-------------

- user_id
- native_language
- target_language
- current_level
- daily_goal_minutes
- learning_goal
- timezone
- onboarding_completed

## 69. Lexeme Schema

lexemes

-------

- id
- lemma
- normalized_lemma
- pos
- gender
- aspect
- transitivity
- cefr
- frequency_rank
- frequency_score
- register
- regionality
- status
- version

## 70. User Lexeme Schema

user_lexemes

------------

- user_id
- lexeme_id
- mastery_state
- stability
- difficulty
- retrievability
- review_count
- success_count
- failure_count
- lapse_count
- last_reviewed_at
- next_review_at
- hr_ua_strength
- ua_hr_strength
- audio_strength
- production_strength
- context_strength
