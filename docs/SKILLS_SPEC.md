<!-- Джерело: Croatia_survival_UPDATED.docx (ТЗ). Розділи збережені з оригінальною нумерацією. Редагуйте тут — це тепер джерело правди. -->

# Навички: аудіювання, говоріння, AI-тьютор, читання, письмо

Listening, shadowing, speaking, AI tutor і його обмеження, role-play, «What Do I Say?», «What Did I Hear?», reading, writing, mediation.

## 46. Listening System

Levels:

**A0**

Very slow, clear speech.

**A1**

Short natural phrases.

**A2**

Normal everyday speech with controlled vocabulary. **B1**

Natural conversations.

**B2**

Natural speed + different speakers + contextual ambiguity.

## 47. Listening Features

- normal speed;
- slow speed;
- replay;
- sentence replay;
- transcript;
- translation;
- hide transcript;
- dictation;
- shadowing;
- comprehension questions.

## 48. Shadowing

User hears:

Dobro jutro, kako ste?

User repeats.

AI analyzes:
- transcription;
- omitted words;
- pronunciation issues;
- rhythm;
- comprehensibility.

The system should avoid presenting pronunciation scoring as medically/linguistically exact measurement.

## 49. Speaking System

Flow:

Prompt → User speaks → Speech-to-text → Expected meaning → AI evaluation → Correction → Retry

Feedback priority:

- Meaning
- \>
- Comprehensibility
- \>
- Important grammar
- \>
- Pronunciation
- \>
- Minor errors

## 50. AI Tutor

Modes:

**Explain**

Explain a word/grammar point in Ukrainian.

**Practice**

Ask questions according to level.

**Conversation**

Natural conversation.

**Role-play**

Real-life simulation.

**Correct me**

User speaks freely; AI identifies important errors.

## 51. AI Tutor Constraint

AI must know:

- user_level
- known_vocabulary
- target_vocabulary
- known_grammar
- weak_areas
- recent_errors
- current_module

AI should not suddenly speak at B2 with an A0 user.

## 52. Role-play Engine

Examples:

**A0–A1**
- café;
- restaurant;
- supermarket;
- bus station;
- pharmacy;
- directions.

**A2**
- landlord;
- doctor;
- bank;
- workplace;
- government office;
- customer service.

**B1**
- job interview;
- workplace disagreement;
- explaining a problem;
- social conversation;
- travel issue.

**B2**
- negotiation;
- presentation;
- discussion;
- professional meeting;
- expressing nuanced opinion;
- defending an argument.

## 53. "What Do I Say?"

Input:

"Мені потрібно перенести зустріч на завтра" Output:

Natural Croatian + Alternative phrasing + Formality + Audio + Explanation + Practice + Save

## 54. "What Did I Hear?"

Input:

"Ma nema veze, čujemo se sutra."

Output:

- Literal meaning
- Natural Ukrainian meaning
- Register
- Context
- Important vocabulary
- Grammar
- Audio
- Practice

## 55. Extensive Reading

From A1:
- microtexts.

A2:
- short stories;
- chats;
- instructions;
- simple news.

B1:
- articles;
- interviews;
- blogs;
- workplace texts.

B2:
- authentic texts;
- essays;
- opinion articles;
- professional texts.

## 56. Reading Interface

User can tap any word:

- word
- translation
- lemma
- grammar
- pronunciation
- save
- add to SRS

Unknown-word density must be controlled.

## 57. Writing System

**A0**

Forms and short sentences.

**A1**

Messages.

**A2**

Emails and descriptions.

**B1**

Structured texts.

**B2**

Arguments, reports, formal communication.

AI checks:

- grammar
- vocabulary
- clarity
- register
- naturalness

## 58. Mediation

The system must include CEFR-style mediation tasks.

Example:

Read Croatian information and explain the key point in Ukrainian. Later:

Read Ukrainian information and explain it in Croatian.

This reflects the CEFR's explicit treatment of mediation as a communication mode.
