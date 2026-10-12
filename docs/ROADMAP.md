<!-- Джерело: Croatia_survival_UPDATED.docx (ТЗ). Розділи збережені з оригінальною нумерацією. Редагуйте тут — це тепер джерело правди. -->

# Roadmap, вертикальні зрізи, беклог

Принцип vertical slices, VS-001…VS-006, структура беклогу, фази розробки, початковий беклог.

## 83. Vertical Slice Development

Development must be organized around complete capabilities. Bad:

- Frontend 70%
- Backend 70%
- SRS 0%

Good:

One complete working learning capability

## 84. First Vertical Slice

**VS-001 — Learn One Croatian Word** User can:

- 1\. see Croatian word;
- 2\. hear pronunciation;
- 3\. see Ukrainian meaning;
- 4\. see example;
- 5\. answer a retrieval question;
- 6\. produce the Croatian word;
- 7\. receive feedback;
- 8\. add to SRS;
- 9\. receive scheduled review;

10\. see progress.

Includes:

- DB
- API
- Mobile UI
- Content
- SRS
- Analytics
- Tests

## 85. VS-002 — Complete One Lesson

User:

opens lesson

→ learns

→ practices

→ listens

→ produces

→ completes

→ receives review

## 86. VS-003 — Speaking

prompt

→ recording

→ transcription

→ evaluation

→ correction

→ retry

## 87. VS-004 — AI Conversation

scenario

→ AI starts conversation

→ user responds

→ AI responds

→ correction

→ assessment

→ save errors

## 88. VS-005 — What Do I Say?

Complete end-to-end flow.

## 89. VS-006 — What Did I Hear?

Complete end-to-end flow.

## 93. Backlog Structure

Each task:

```yaml
id:
type:
priority:
goal:
requirements:
dependencies:
acceptance_criteria:
files_expected:
database_changes:
api_changes:
ui_changes:
analytics:
tests:
status:
```

## 104. Development Roadmap

**Phase 0**

Foundation.
- repository;
- architecture;
- schemas;
- AI rules;
- CI/CD.

**Phase 1**

Learning engine.
- curriculum;
- vocabulary;
- lessons;
- exercises;
- SRS.

**Phase 2**

A0.
- 500 items;
- complete A0;
- assessment.

**Phase 3**

A1.
- 1,000 additional items;
- listening;
- speaking.

**Phase 4**

AI tutor.
- conversation;
- role-play;
- What Do I Say?;
- What Did I Hear?

**Phase 5**

A2.

**Phase 6**

B1.

**Phase 7**

B2.

**Phase 8**

Optimization through learning data.

## 105. Initial AI Backlog

**P0**

- FOUNDATION-001
- Create repository
- FOUNDATION-002
- Create project documentation
- FOUNDATION-003
- Create database
- FOUNDATION-004
- Create content schemas
- FOUNDATION-005
- Create AI operating rules
- LEARNING-001
- Curriculum engine
- LEARNING-002
- Lesson engine
- LEARNING-003
- Exercise engine
- SRS-001
- SRS state model
- SRS-002
- SRS scheduler
- ANALYTICS-001
- Analytics event system
- UX-001
- Onboarding
- UX-002
- Learning screen
- UX-003
- Review screen

**P1**

- SPEECH-001
- Recording
- SPEECH-002
- STT
- SPEECH-003
- Speech feedback
- AI-001
- Tutor
- AI-002

What Do I Say?

AI-003

What Did I Hear?

AI-004

Role-play

**P2**

- Reading engine
- Writing coach
- Advanced pronunciation
- B2 professional Croatian
- Advanced personalization
