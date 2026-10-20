<!-- Джерело: Croatia_survival_UPDATED.docx (ТЗ). Розділи збережені з оригінальною нумерацією. Редагуйте тут — це тепер джерело правди. -->

# Аналітика і метрики

Події, властивості, North Star Metric, облік витрат на AI.

## 71. Analytics

Events:

- app_open
- onboarding_started
- onboarding_completed
- placement_started
- placement_completed
- lesson_started
- lesson_completed
- exercise_started
- exercise_completed
- review_started
- review_completed
- speaking_started
- speaking_completed
- conversation_started
- conversation_completed
- reading_started
- reading_completed
- word_saved
- word_mastered
- what_to_say_used
- what_did_i_hear_used
- subscription_started
- subscription_cancelled

## 72. Analytics Properties

Every event should include where relevant:

- user_id
- session_id
- level
- module
- lesson
- skill
- lexeme_id
- exercise_type
- difficulty
- duration
- success
- attempt
- device
- app_version

## 73. North Star Metric

**Successful Learning Session**

Session qualifies when user completes meaningful learning activity containing:

retrieval + production + feedback/review

Supporting metrics:
- D1;
- D7;
- D30;
- vocabulary retention;
- listening improvement;
- speaking improvement;
- assessment progression;
- real-life scenario success.

## 74. AI Cost Analytics

Track:

- AI tokens
- AI requests
- speech minutes
- TTS minutes
- STT minutes
- AI cost/session
- AI cost/user
- AI cost/retained user
- content generation cost

---

# Реалізація (2026-10-12, VS-001 / VS-002)

Таблиця `public.analytics_events` (міграція M4): append-only, RLS — користувач пише і читає лише свої події, змінювати й видаляти не може ніхто. Поширені властивості §72 — окремими колонками (`session_id`, `lesson_id`, `lexeme_id`, `level`, `success`, `duration_ms`, `device`, `app_version`), решта — у `properties` (jsonb).

Код: `lib/analytics.ts` (перелік подій і валідація), `lib/analytics-client.ts` (`track()` у браузері, сесія = вкладка), `app/actions/analytics.ts` (запис від імені користувача). Аналітика ніколи не ламає навчання: некоректна подія або збій бази просто не записуються.

| Подія | Де | Властивості |
|---|---|---|
| `app_open` | будь-яка сторінка, раз на сесію | path |
| `lesson_started` | сторінка уроку, після завантаження | lesson_id, level |
| `word_saved` | урок → «Додати в мій словник» | lexeme_id, lesson_id, source |
| `exercise_completed` | урок, правильна відповідь | lesson_id, exercise_id, exercise_type, success, attempt (спроб до правильної), duration_ms |
| `exercise_completed` | тренажер «Написати», кожна відповідь | lexeme_id, level, exercise_type = `type_word`, source = `trainer`, success, verdict (exact / diacritics / typo / wrong), duration_ms |
| `lesson_completed` | сервер, `completeLesson` | lesson_id, level, duration_ms, count (слів у уроці), added_to_review |
| `review_started` | тренажер, картки завантажені | level, count, source (`review` / `new` / `write`) |
| `review_completed` | тренажер, оцінено всі картки | level, count, correct_count, duration_ms, source |
| `exercise_completed` | «Ситуації» → «Перевір себе», кожна фраза | exercise_type = `phrase_recall`, source = `situation`, situation, phrase_id, level, success (Знав / Ще ні), duration_ms |
| `onboarding_started` | `/onboarding`, відкриття | source (`first` / `repeat`) |
| `onboarding_completed` | сервер, `completeOnboarding` | goals, daily_goal_minutes, level (рівень старту), self_level, source (`placement` / `self`) |
| `placement_started` | початок тесту рівня | count (питань), self_level |
| `speaking_started` | сервер, `startSpeakingSession` (вибрано режим) | source (`situation`), situation, exercise_type (`repeat` / `produce`) |
| `speaking_completed` | сервер, `finishSpeakingSession` (кінець заняття) | situation, exercise_type, count (фраз), correct_count (зрозуміли), attempt (спроб), duration_ms, success |
| `conversation_started` | сервер, `startRoleplay` | source = `roleplay`, situation, level |
| `conversation_completed` | сервер, `finishRoleplay` | source = `roleplay`, situation, level, count (реплік користувача), attempt (помилок збережено), success (завдання виконано) |
| `placement_completed` | сервер, `submitPlacement` | estimated_level, recommended_start, confidence, count, correct_count, duration_ms, success |
| `exercise_completed` | сервер, `answerTypicalError` («Типові помилки», кожна відповідь) | exercise_type = `typical_error`, source = `interference`, skill (категорія помилки), success, duration_ms |
| `review_started` / `review_completed` | «Типові помилки», початок / кінець серії з 8 питань | source = `typical_errors`, count, correct_count, duration_ms |
| `reading_started` | `/reading/<id>`, текст відкрито | source = `reading`, skill = `reading`, level, count (слів у тексті) |
| `reading_completed` | сервер, `completeReading` («Перевірити») | source = `reading`, skill = `reading`, level, count (питань), correct_count, success (≥ 2 з 3), duration_ms |
| `word_saved` | сервер, `saveReadingWord` (слово з тексту → тренажер) | lexeme_id, source = `reading` |
| `assessment_started` | `/assessment/<slug>`, «Почати» (§60) | level, assessment_kind (`module` / `mid` / `final`), assessment_slug (`a0-m01`…), count (завдань) |
| `assessment_completed` | сервер, `submitAssessment` | level, module_id, assessment_kind, assessment_slug, score (0…1), count (зараховано завдань, без пропущеного говоріння), correct_count, success (пройдено), duration_ms |

Кожна оцінка картки окремо записується в `srs_reviews` (результат, інтервали, ease, `response_time_ms`) — це і є детальна історія повторень, тому окремої події на кожну картку немає.

Ще не реалізовано: `word_mastered` (потрібні критерії §42: продукування + кілька сесій), «What Do I Say?», підписки — додаються разом з відповідними зрізами. Облік витрат AI — див. нижче.

## Облік викликів AI (§74) — реалізація (M4b, 2026-10-12)

Таблиця `public.ai_usage_events`: одна подія на виклик AI / TTS / STT — `feature`, `provider`, `model`, `input_tokens`, `output_tokens`, `characters`, `audio_ms`, `latency_ms`, `cost_usd` (коли відома), `success`, `error_code`, `properties`. RLS: користувач додає й читає лише свої події, адмін (`is_admin()`) читає всі; змінювати й видаляти не може ніхто.

Код: `lib/ai-usage.ts` (перелік функцій, перевірка рядка + тести), `lib/ai-usage-server.ts` → `recordAiUsage()` (лише сервер; збій обліку не ламає дію).

| `feature` | Де записується | Стан |
|---|---|---|
| `quick_translate` | `app/actions/translate.ts` («Мені потрібно сказати…» на головній), через `AIProvider` (з 2026-10-12): токени, затримка, помилки | ✅ |
| `tts` | `app/api/tts` | ще ні — неофіційний безкоштовний TTS; додати разом із `SpeechProvider` (§79) |
| `roleplay` | `app/actions/roleplay.ts` через `AIProvider` (`lib/ai-gemini.ts`): кожна репліка AI і підсумкова оцінка | ✅ |
| `what_do_i_say`, `what_did_i_hear`, `chat`, `stt`, `pronunciation`, `content_generation` | відповідні зрізи VS-005…VS-006 і генерація контенту | ще ні |

`cost_usd` поки порожній: ціни провайдерів змінюються, тож вартість рахуємо звітом з токенів за актуальним тарифом, а не зашиваємо в код.

```sql
-- Витрати AI за 7 днів (SQL Editor, від імені власника)
select feature, provider, model, count(*) as calls,
       count(*) filter (where not success) as errors,
       sum(input_tokens) as input_tokens, sum(output_tokens) as output_tokens,
       round(avg(latency_ms)) as avg_latency_ms
from public.ai_usage_events
where occurred_at > now() - interval '7 days'
group by 1, 2, 3 order by calls desc;
```

## North Star — формула (затверджено власником 2026-10-20)

**Успішна навчальна сесія** (один захід у застосунок, `session_id`) — у ній є **обидві** частини:

1. **Retrieval + production** — хоча б одна **правильна** вправа, де людина **сама створює** відповідь:
   `exercise_completed` з `success = true` і `exercise_type` ∈ `type_answer` («напишіть»), `type_word` (тренажер «Написати»),
   `sentence_builder` («складіть»), `listening` («прослухайте і складіть»), `speaking` («скажіть уголос»), `fix_mistake` («виправте помилку»);
   **або** `speaking_completed` / `conversation_completed` (говоріння, рольова гра).
2. **Feedback / review** — завершений урок або повторення: `lesson_completed` або `review_completed`.

**Не рахуються** як production: вибір із варіантів (`multiple_choice`, `fill_in_the_blank`, `typical_error`) і **картки без письма**
(свайпи «Знаю / Не знаю» в тренажері не пишуть `exercise_completed`). Тобто сесія лише з картками — не успішна,
навіть якщо картки завершено (`review_completed`).

Рішення власника 2026-10-20: «суворіший варіант плюс „картки без письма не рахуються“». Нова вправа, де людина сама пише чи говорить, —
додати її `exercise_type` у список вище (і сюди, і в SQL).

```sql
-- Успішні навчальні сесії за днями (North Star)
with s as (
  select user_id, session_id, min(occurred_at)::date as day,
         bool_or(event_name = 'exercise_completed' and success
                 and properties->>'exercise_type' in ('type_answer', 'type_word', 'sentence_builder', 'listening', 'speaking', 'fix_mistake')) as produced,
         bool_or(event_name in ('speaking_completed', 'conversation_completed')) as spoke,
         bool_or(event_name in ('lesson_completed', 'review_completed')) as reviewed
  from public.analytics_events
  where session_id is not null
  group by user_id, session_id
)
select day,
       count(*) filter (where (produced or spoke) and reviewed) as successful_sessions,
       count(*) as all_sessions,
       count(distinct user_id) filter (where (produced or spoke) and reviewed) as users_with_success
from s
group by day
order by day desc;
```

Перший замір (робоча база, 2026-10-12 … 2026-10-20): 26 сесій, успішних — 3 (2 користувачі — тестові).
