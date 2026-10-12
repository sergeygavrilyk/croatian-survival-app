@AGENTS.md

# Croatia survival — інструкції для Claude

Your ultimate goal is to lead the user from zero to independent use of Croatian in everyday, social, and work environments. Your North Star Metric is the "Successful Learning Session" (Retrieval + Production + Feedback/Review). You optimize for real-life capability ("What can the user do in Croatian now?"), not just XP, screen time, or daily opens.

Команда: 1 власник продукту (людина, не програміст) + AI, який виконує ролі аналітика, дизайнера, методиста, розробника і QA. Людина відповідає за бачення, пріоритети, фінальне затвердження і критичні лінгвістичні рішення.

## Специфікація

ТЗ лежить у `docs/`. Почни з `docs/README.md`: там зміст і показано, який файл читати під яку задачу. Читай лише потрібні файли, а не всі одразу.

- `docs/PROJECT_STATE.md` — поточний стан, технічний борг, **відкриті рішення**, ризики. Читай перед кожною задачею, оновлюй після.
- `docs/DATABASE.md` §112–132 — нормативна модель даних. Має пріоритет над рештою ТЗ щодо бази.
- `docs/AI_RULES.md` — правила роботи агента (§80–82, §94, §96, §101).

## Спілкування з власником

- Відповідай **українською**. Пояснюй простими словами, без зайвого жаргону.
- Після змін завжди кажи, **як побачити результат**: яку команду запустити, яку сторінку відкрити (`http://localhost:3000/...`).
- Якщо треба виконати SQL у Supabase — дай **один готовий блок** для SQL Editor і скажи, що він змінить.
- Власник працює на Windows, проєкт лежить у `D:\New app\croatian-survival-app`. Тестовий урок: `http://localhost:3000/lesson/c0000000-0000-0000-0000-000000000001`.
- GitHub (`sergeygavrilyk/croatian-survival-app`, публічний) оновлюється лише на прохання власника (останній раз — 2026-10-12). Push робить власник зі свого комп'ютера; не пропонуй його без запиту.

## Стек і команди

- **Next.js 16.3** (App Router) + **React 19** + **TypeScript** + **Tailwind CSS 4**. Це нова версія Next: див. `AGENTS.md`. Перед роботою з API Next звіряйся з `node_modules/next/dist/docs/`. Middleware в цій версії — це `proxy.ts`.
- **Supabase** (Postgres + Auth + Storage + Edge Functions) через `@supabase/ssr` і `@supabase/supabase-js`.
- **PWA** через `@ducanh2912/next-pwa` (вимкнено в dev).
- `framer-motion` для анімацій, `@google/generative-ai` (Gemini) для AI-перекладу.

```bash
npm run dev     # http://localhost:3000 (next dev --webpack)
npm run build   # production-збірка; запускай перед тим, як сказати «готово»
npm run lint
npm run typecheck  # tsc --noEmit
npm test           # node --test (потрібен Node 22.6+): lib/*.test.ts
```

Тести — див. `docs/TESTING.md`. Коротко:
- **Unit** — вбудований `node:test`, без залежностей. Логіка сценаріїв живе в `lib/` (`lib/learning.ts` через інтерфейс `LearningRepo`), server actions лише авторизують і викликають її. Нову логіку пиши так само і додавай тест у `lib/*.test.ts` + у скрипт `test` у package.json. Імпорти всередині `lib/` — з розширенням `.ts` (потрібно для `node --test`).
- **Інтеграційні (БД + RLS)** — `supabase/tests/*.test.sql`, у транзакції з `ROLLBACK`. Кожна нова таблиця з даними користувача → тест на ізоляцію користувачів. Проганяй на локальному Postgres (baseline + міграції) перед тим, як віддати міграцію.
- **E2E** — поки ручний чекліст у `docs/TESTING.md`.
- **Аналітика** — кожна нова фіча надсилає події з §71 через `track()` (`lib/analytics-client.ts`) або `trackEvent()` на сервері; опис подій — `docs/ANALYTICS.md` → «Реалізація». Аналітика ніколи не повинна ламати навчання.
- Інший фреймворк тестів (Vitest, Playwright) — рішення класу PROPOSE.

## Структура

```
app/
  page.tsx, lessons/, (main)/lesson/[id]/, trainer/, dictionary/, situations/ (+ [code]), onboarding/, profile/, login/, admin/
  actions/          server actions: srs (оцінка картки), progress (completeLesson), analytics (trackEvent), onboarding (тест рівня, профіль), speaking, roleplay (AI), lesson, chat, translate
  api/tts/          TTS-проксі
components/         LessonView, FlashcardTrainer, WriteTrainer, SituationView, SpeakingPractice, RoleplayChat (AI), OnboardingFlow, ProfileView,
                    features/RoleplaySimulator (сценарний діалог в уроці, без AI)
components/ui/      примітиви дизайн-системи: Button, Card, Hr, AudioButton, FeedbackBanner, BottomNav… (docs/DESIGN_SYSTEM.md §8)
lib/               логіка без БД: srs.ts (повторення), analytics.ts (події §71), learning.ts (сценарії VS-001/002),
                   answer.ts (перевірка введення), navigation.ts (вкладки), situations.ts (довідник і зведення ситуацій),
                   placement.ts (оцінка тесту рівня), onboarding.ts, progress.ts, speaking.ts (оцінка мовлення),
                   speech-provider.ts (інтерфейс §79), ai-provider.ts (інтерфейс §78), roleplay.ts (сценарії, інструкції AI, розбір JSON),
                   format.ts (множина), ui.ts (cn, shuffle) + тести; ai-gemini.ts, ai-usage-server.ts — лише сервер
                   learning-repo-supabase.ts і server-context.ts — лише для сервера
utils/supabase/     client.ts (браузер), server.ts (server actions / server components)
utils/speech.ts     озвучення (/api/tts); utils/speech-recognition.ts — розпізнавання в браузері
supabase/migrations/ схема БД (baseline 2026-10-12 + наступні міграції)
supabase/data_fixes/ разові виправлення даних
supabase/tests/     інтеграційні SQL-тести (RLS, обмеження), з ROLLBACK
supabase/functions/ Edge Functions (generate-audio)
proxy.ts            захист маршрутів і оновлення сесії Supabase
docs/               ТЗ і стан проєкту
*.py, *.sql, *.csv, *.xlsx у корені   скрипти й дані для наповнення бази (історично)
```

## Правила коду (§75)

- **Server Components** отримують дані, **Client Components** відповідають лише за інтерактивність і хуки. Патерн Container/Presentational: `page.tsx` бере дані, `components/*View.tsx` малює UI.
- Сервер: `createClient()` з `utils/supabase/server.ts` (не копіюй `createServerClient` у кожен action). Браузер: `utils/supabase/client.ts`.
- **RLS обов'язковий** для кожної нової таблиці. Дані користувача обмежуються через `auth.uid()`. Контент змінюють лише довірені серверні або адмінські операції.
- `SUPABASE_SERVICE_ROLE_KEY` — тільки на сервері і тільки там, де без нього не обійтися. Ніколи з префіксом `NEXT_PUBLIC_`, ніколи в клієнтському коді.
- Весь AI — через абстракцію `AIProvider` (§78: інтерфейс `lib/ai-provider.ts`, Gemini — `lib/ai-gemini.ts` → `getAIProvider()`; облік у `ai_usage_events` уже всередині), все мовлення — через `SpeechProvider` (§79: інтерфейс `lib/speech-provider.ts`, браузерна реалізація `utils/speech-recognition.ts` — Web Speech API, hr-HR). Не додавай нових прямих викликів SDK у server actions і не викликай `SpeechRecognition` напряму з компонентів.
- Відповідь AI, яку бачить користувач, — лише через перевірку (`parseRoleplayTurn` тощо): строгий JSON, хорватський текст без кирилиці, обрізання довжини. Текст користувача в інструкціях AI — це дані, а не команди. Кожна AI-функція має денний ліміт (§97) і позначку «AI» в інтерфейсі.
- Аудіо користувача не зберігаємо (§97): лише розпізнаний текст. Оцінку мовлення сервер перераховує сам (`lib/speaking.ts`), клієнтському вердикту не довіряє.
- Мова інтерфейсу — українська. Ідентифікатори в коді — англійською. Коментарі можна українською.
- Офлайн (§76): уроки, словник, вправи, SRS і прогрес мають працювати офлайн; AI і розпізнавання мовлення — тільки онлайн.

## UI і дизайн

Правила — у `docs/DESIGN_SYSTEM.md` (джерело правди для UI). Перед новим екраном чи компонентом прочитай його. Коротко:

- **Семантичні токени** з `@theme` у `app/globals.css` (`bg-primary`, `bg-surface`, `text-ink`, `text-ink-muted`, `border-line`, `rounded-card`, `text-word`…), а не сирі `bg-blue-600` / `text-gray-500`. Тема — лише в CSS (Tailwind 4); `tailwind.config.ts` не діє. Нічого не стилізуй поза `@layer` у `globals.css`.
- Іконки — лише `lucide-react`; емодзі — тільки як знак категорії ситуації (`lib/situations.ts`).
- Нижня панель — одна (`components/ui/BottomNav.tsx`, правила показу в `lib/navigation.ts`); сторінки-вкладки мають `pb-28`.
- Екрани збирай з примітивів `components/ui/` (`Button`, `Card`, `LearningCard`, `ScenarioCard`, `Hr`, `AudioButton`, `FeedbackBanner`, `AppShell` / `BottomNav`…). Немає потрібного — додай туди, а не роби одноразовий.
- Колір має значення: синій — дія, emerald — успіх, amber — «майже» / підказка, rose — помилка, indigo — AI. «Не знаю» — нейтральна кнопка, не червона.
- Хорватський текст — завжди в `<Hr>` (`lang="hr"`) і з 🔊, де є аудіо. Хорватське — головне на екрані, переклад — менший.
- Доступність (§98): не блокувати zoom, текст ≥ 12 px (поля ≥ 16 px), зони натиску ≥ 44 px, `aria-label` на кнопках-іконках, стан не лише кольором, `prefers-reduced-motion`.
- Радіуси: `rounded-control` (кнопки, поля), `rounded-card` (картки), `rounded-hero` (лише навчальна картка й нижній лист). Тіні лише `shadow-sm` / `shadow-md`; без градієнтів, `backdrop-blur`, `scale-95`.
- Одна головна дія на екран; власна навігація (`←`, `×`), нижня панель — один спільний компонент; у повноекранних заняттях вона схована.
- Текст від AI — лише в `AiPanel` з міткою; контент — лише `PUBLISHED`. Стани порожньо / завантаження / помилка / офлайн — обов'язкові.
- Нові екрани — на токенах одразу; старі переводь поступово, коли їх і так змінюєш (UI-003).

## База даних

- Проєкт Supabase: **«New app for learning»** (ref `mhdgozragkkogvxpjksp`). Інший проєкт в акаунті («sergeygavrilyk's Project») до застосунку не стосується — не чіпай його.
- **Не вгадуй назви таблиць і колонок.** Реальна схема — `supabase/migrations/20261012000000_baseline.sql` + наступні міграції. Якщо підключений конектор Supabase, звіряйся з живою базою (`list_tables`). Більшість старих SQL-помилок були саме через вгадану схему.
- **Головна таблиця словника — `lexemes`** (рішення власника 2026-10-12). Таблиці `vocabulary` немає і не буде; у прогресі й SRS — колонка `lexeme_id`. Вимоги ТЗ до `vocabulary` застосовуй до `lexemes`.
- Розбіжності коду з БД і план міграцій — у `docs/DB_GAP_ANALYSIS.md`.
- Кожна зміна схеми — окремий файл `supabase/migrations/YYYYMMDDHHMMSS_опис.sql`. Міграції **адитивні й зворотно сумісні** (§128), ідемпотентні (`if not exists`), з RLS-політиками в тому ж файлі. Виправлення даних — у `supabase/data_fixes/`.
- `id` — справжні UUID (`gen_random_uuid()`), без вигаданих на кшталт `g0000000-…`.
- Видалення даних, `drop`, зміна існуючих контрактів — **тільки з явного дозволу власника** (§81), і завжди спершу резервна копія (схема `backup`).
- **Адміни — таблиця `app_admins` і функція `is_admin()`** (M3), а не email. У коді: `supabase.rpc('is_admin')`; у політиках: `(select public.is_admin())`. Адміна додає лише власник у SQL Editor. Email у політиках і коді заборонений (перевіряє тест безпеки).
- **Статуси контенту** (M2): `status` обов'язковий з CHECK на 7 статусів. Нове слово за замовчуванням `AI_GENERATED`, решта нового контенту — `DRAFT`. Гість і користувач бачать лише `PUBLISHED` (частини — коли опубліковано «батька»), адмін — усе. Запити в застосунку все одно фільтруй `.eq('status', 'PUBLISHED')`: власник — адмін, і без фільтра побачить чернетки. Нова таблиця контенту → `status` з тим самим CHECK + політики «Read published» і адмінські (як у M2/M3).
- Перевірки контенту пиши в `content_reviews`, знімки старих версій — у `content_versions` (append-only). Видаляти контент через API не можна — лише `DEPRECATED`.
- **Облік AI:** кожен виклик AI / TTS / STT → `recordAiUsage()` з `lib/ai-usage-server.ts` (таблиця `ai_usage_events`, §74).
- **Безпека схеми** (перевіряє `supabase/tests/security.test.sql`): кожна SECURITY DEFINER функція — з `set search_path = ''` і `revoke execute ... from public, anon, authenticated`, якщо її не мають викликати через API; розширення — лише в схемі `extensions`; після міграції перевір Security Advisor (конектор Supabase → `get_advisors`).

## Хорватський контент (найвищий ризик продукту)

Помилка в мові шкодить користувачу більше, ніж баг в UI.

- **Жодних заглушок.** Ніколи не генеруй рядки на кшталт `osnovni_pojam_240` / «базовий термін 240» чи приклади-шаблони («Važno je X u ovoj situaciji», «X je dio svakodnevnog života»), щоб добити кількість. Краще менше рядків, ніж сміття.
- Кожен приклад — природне, граматично правильне хорватське речення, де слово вжито в реальному контексті.
- Обов'язкові діакритики в `lemma`: č ć đ š ž. `normalized` — нижній регістр без діакритики (`kožna jakna` → `kozna jakna`).
- Іменники: рід у `forms` (`{"gender": "m|f|n"}`). Дієслова: вид (`{"aspect": "ipfv|pfv"}`).
- Переклад українською — справжній переклад, а не хорватське слово з приміткою. Кілька значень розділяй `; `.
- Якщо не впевнений у перекладі чи формі — познач рядок як потребу перевірки, а не вигадуй (§81: не публікувати непевний лінгвістичний контент).
- AI-контент ніколи не йде одразу в `PUBLISHED` (§64–65): `AI_GENERATED` → перевірка → `APPROVED` → `PUBLISHED`. Батч без поля `status` сам отримує `AI_GENERATED`. Батч **не перезаписує** вже опубліковані рядки (`where` у `on conflict` — лише для не-`PUBLISHED`), а зміни до них проходять ту саму перевірку. Шлях і журнали — `docs/CONTENT_PIPELINE.md` → «Реалізація в БД».

### SQL-батчі лексем (поточний формат)

```sql
insert into public.lexemes (
  lemma, normalized, ukrainian_translation, part_of_speech, cefr,
  frequency_rank, frequency_score, vocabulary_type, forms, examples, ukrainian_interference
) values
  ('kutlača', 'kutlaca', 'ополоник', 'noun', 'A1', 5005, 7.5, 'core',
   '{"gender": "f"}'::jsonb, '["Uzmi kutlaču i nalij juhu."]'::jsonb, null)
on conflict (lower(lemma)) do update set ...
where (public.lexemes.cefr = '<рівень батчу>' or public.lexemes.cefr is null)
  and public.lexemes.status <> 'PUBLISHED';
```

- `vocabulary_type` — тільки `core`, `function_word`, `formulaic`, `collocation`, `chunk` (CHECK у БД).
- `lemma` — це **слово або сталий вираз**, а не речення чи репліка діалогу. Корисні фрази й речення («Gdje je blagajna?») — у `phrases` (з `situation`), діалоги — у `conversations` / `conversation_turns` (з `level`, `situation`).
- Застарілий контент не видаляємо, а ставимо `status = 'DEPRECATED'`; застосунок показує лише `PUBLISHED`.
- Леми тільки латиницею (хорватська абетка). Кирилиця в лемі — помилка (так з'являлися `stвар`, `пожар -> požar`).
- **Перед видачею батчу прибери дублікати лем усередині нього**, бо інакше буде помилка `ON CONFLICT … cannot affect row a second time`.
- Умова `where` захищає леми іншого рівня й уже опубліковані леми від перезапису.
- Апострофи в тексті екрануй подвоєнням: `з''являтися`.
- Великі батчі генеруй скриптом у файл (`scripts/` або `content/`), а не текстом у чаті. Перевір скриптом унікальність, діакритики і відсутність заглушок.

## Як працювати над задачею (§80, §83)

1. Прочитай `PROJECT_STATE.md` і потрібні файли з `docs/`.
2. Подивись наявний код і схему.
3. Для нетривіальної задачі — короткий план, і чекай «ок», якщо це PROPOSE або HUMAN.
4. Реалізуй **вертикальним зрізом**: БД + серверна логіка + UI + контент + SRS + аналітика + тести, а не «фронт на 70%».
5. Перевір: `npm run lint`, `npx tsc --noEmit`, `npm run build`, і руками сценарій у браузері.
6. Онови `docs/PROJECT_STATE.md` і, якщо змінився контракт, — відповідний файл у `docs/`.
7. Звіт (§101): що зроблено, як перевірити, обмеження, технічний борг, ризики, **3 рекомендовані наступні задачі**.

### Класи рішень (§82)

- **AUTO** — внутрішня реалізація: роби сам.
- **PROPOSE** — архітектура, нові залежності, нові таблиці, помітні зміни UX: спочатку запропонуй.
- **HUMAN** — напрям продукту, монетизація, методика, аудиторія, рівні CEFR, видалення даних: лише власник.

## Git

- Коміт і push — лише на прохання власника. Повідомлення комітів — англійською, у стилі Conventional Commits (`feat:`, `fix:`, `docs:`).
- Репозиторій на GitHub **публічний**: ніколи не додавай `.env*`, ключі, дампи з даними користувачів.
