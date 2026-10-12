<!-- Джерело: Croatia_survival_UPDATED.docx (ТЗ). Розділи збережені з оригінальною нумерацією. Редагуйте тут — це тепер джерело правди. -->

# Рушій навчання: вправи, SRS, mastery, адаптивність

Exercise engine, складність, AI-генерація вправ, retrieval modes, SRS, mastery, skill model, adaptive learning, daily plans.

## 34. Exercise Engine

Support:

- 1\. Flashcards
- 2\. Multiple choice
- 3\. Audio recognition
- 4\. Translation
- 5\. Reverse translation
- 6\. Cloze
- 7\. Fill gaps
- 8\. Sentence ordering
- 9\. Sentence construction
- 10\. Dictation
- 11\. Listening comprehension
- 12\. Grammar correction
- 13\. Free response
- 14\. Speaking
- 15\. Writing
- 16\. Role-play
- 17\. Matching
- 18\. Categorization
- 19\. Pronunciation imitation
- 20\. Information-gap task

## 35. Exercise Difficulty

Each exercise has:

- level
- difficulty
- target_skill
- target_lexemes
- target_grammar
- expected_answer
- acceptable_answers
- distractors
- feedback

## 36. AI Exercise Generation

AI can generate exercises only from approved:

- vocabulary
- grammar
- phrases
- lesson context
- CEFR constraints

AI must not introduce arbitrary advanced vocabulary into A0 exercises.

## 37. Retrieval Modes

System must support:

HR → UA

UA → HR

Audio → meaning

Meaning → HR

Situation → HR

HR → situation

Sentence → missing word

Conversation → response

## 38. SRS Engine

Each learning item has:

- stability
- difficulty
- retrievability
- last_review
- next_review
- review_count
- success_count
- failure_count
- lapses
- response_time

## 39. SRS Scheduling

The scheduler must consider:

- grade
- stability
- difficulty
- retrievability
- review history
- lapses
- time since last review
- learning direction
- item importance

Do not implement a naïve:

- 1 day
- 2 days
- 4 days
- 8 days

scheduler as the final system.

The implementation should be benchmarked and tuned using learning data.

## 40. Initial SRS Algorithm

Initial grading:

- 0 = Again
- 1 = Hard
- 2 = Good
- 3 = Easy

Internally convert to:

- retrieval_success
- difficulty
- stability_update

The system should support future migration to more sophisticated scheduling without changing the user model.

## 41. Mastery

States:

- UNSEEN
- INTRODUCED
- RECOGNIZED
- RECALLED
- PRODUCED
- CONTEXTUAL
- STABLE
- MASTERED

## 42. Mastery Criteria

Recommended:

≥3 successful retrievals + ≥2 sessions + ≥1 delayed retrieval + ≥1 production event

For high-frequency functional vocabulary: + listening recognition

## 43. Skill Model

Track independently:

- Vocabulary
- Grammar
- Listening
- Reading
- Speaking
- Writing
- Pronunciation
- Interaction
- Mediation

User can therefore have:

- Reading: B1
- Listening: A2
- Speaking: A2
- Vocabulary: B1

instead of one misleading global score.

## 44. Adaptive Learning

Input:

- user level
- skill profile
- SRS queue
- recent errors
- time available
- learning goals
- recent lessons
- conversation history

Output:

- today's lesson
- review queue
- new vocabulary
- weak grammar
- listening
- speaking

## 45. Daily Plans

**5 minutes**

SRS + 1 micro-production

**15 minutes**

SRS + new material + listening + production

**30 minutes**

SRS + lesson + listening + speaking + reading

**60 minutes**

Full learning session + conversation + extensive reading
