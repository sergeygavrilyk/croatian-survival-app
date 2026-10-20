> Довідник: де що лежить у коді. Перенесено з `CLAUDE.md` 2026-10-19 — читати, коли треба знайти файл. Оновлювати при додаванні нових папок, екранів, модулів `lib/` чи генераторів.

# Структура репозиторію

```
app/
  page.tsx, lessons/ (+ tests/ — перевірки рівня), assessment/[slug]/ (тест §60), (main)/lesson/[id]/, trainer/, mistakes/ (+ typical/), reading/ (+ [id]), dictionary/, situations/ (+ [code]), onboarding/, profile/, login/, admin/
  actions/          server actions: srs (оцінка картки), progress (completeLesson), analytics (trackEvent), onboarding (тест рівня, профіль), speaking, roleplay (AI), interference (типові помилки), reading (читання), assessment (перевірки рівня), lesson, chat, translate
  api/tts/          TTS-проксі
components/         lesson/LessonPlayer + lesson/LessonExercise (урок), FlashcardTrainer, WriteTrainer, SituationView, SpeakingPractice, RoleplayChat (AI), OnboardingFlow, ProfileView,
                    TypicalErrorCard + TypicalErrorsQuiz (типові помилки), ReadingListView + ReadingView (читання),
                    AssessmentListView + AssessmentPlayer + AssessmentResult (перевірки рівня §60),
                    features/RoleplaySimulator (сценарний діалог в уроці, без AI)
components/ui/      примітиви дизайн-системи: Button, Card, Hr, AudioButton, FeedbackBanner, BottomNav… (docs/DESIGN_SYSTEM.md §8)
lib/               логіка без БД: srs.ts (повторення), analytics.ts (події §71), learning.ts (сценарії VS-001/002),
                   answer.ts (перевірка введення), navigation.ts (вкладки), situations.ts (довідник і зведення ситуацій),
                   placement.ts (оцінка тесту рівня), onboarding.ts, progress.ts, speaking.ts (оцінка мовлення),
                   speech-provider.ts (інтерфейс §79), ai-provider.ts (інтерфейс §78), roleplay.ts (сценарії, інструкції AI, розбір JSON),
                   format.ts (множина), ui.ts (cn, shuffle), ai-fallback.ts (запасні моделі AI), phrase-match.ts (пошук перекладу в перевіреному контенті), mistakes.ts (повторення помилок), lesson-flow.ts (етапи й черга вправ уроку), interference.ts (типові помилки українців), reading.ts (читання: слова тексту, питання, озвучення), assessment.ts (перевірки рівня: оцінка за 4 навичками, пороги) + тести; ai-gemini.ts, ai-usage-server.ts — лише сервер
                   learning-repo-supabase.ts і server-context.ts — лише для сервера
utils/supabase/     client.ts (браузер), server.ts (server actions / server components)
utils/speech.ts     озвучення (/api/tts); utils/speech-recognition.ts — розпізнавання в браузері
supabase/migrations/ схема БД (baseline 2026-10-12 + наступні міграції)
supabase/data_fixes/ разові виправлення даних (зокрема пакети програми curriculum_*.sql)
scripts/            генератори програми: full_lessons.py (спільна логіка повного уроку), gen_curriculum_*.py + *_data.py (дані) + *_snapshot.json (знімок перекладів бази);
                    gen_interference.py + interference_data.py (типові помилки), gen_reading.py + reading_data*.py (A0, A1, A2) + reading_lexicon.py + reading_grammar.py (тексти для читання, словничок, граматика);
                    gen_assessment.py + assessment_source_snapshot.json (перевірки рівня A0/A1 з опублікованих уроків)
supabase/tests/     інтеграційні SQL-тести (RLS, обмеження), з ROLLBACK
supabase/functions/ Edge Functions (generate-audio)
proxy.ts            захист маршрутів і оновлення сесії Supabase
docs/               ТЗ і стан проєкту
*.py, *.sql, *.csv, *.xlsx у корені   скрипти й дані для наповнення бази (історично)
```
