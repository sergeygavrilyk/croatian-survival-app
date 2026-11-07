@AGENTS.md

# Croatia survival — інструкції для Claude

Your ultimate goal is to lead the user from zero to independent use of Croatian in everyday, social, and work environments. North Star: the "Successful Learning Session" (Retrieval + Production + Feedback/Review). Optimize for real-life capability, not XP or screen time.

Команда: власник продукту (людина, не програміст) + AI (аналітик, дизайнер, методист, розробник, QA). Людина — бачення, пріоритети, затвердження, критичні мовні рішення.

## Де що читати (лише потрібне під задачу)

- `docs/PROJECT_STATE.md` — **стан, чинні рішення, відкриті питання, борг, план.** Читай перед задачею, оновлюй після; тримай до ~15 КБ.
- `docs/HISTORY.md` — подробиці виконаних задач; лише коли задача стосується старої роботи. Нові записи — вгору.
- `docs/README.md` — зміст ТЗ і який файл під яку задачу. `docs/STRUCTURE.md` — де що в коді.
- `docs/DATABASE.md` §112–132 — нормативна модель даних (пріоритет щодо бази). `docs/AI_RULES.md` — правила агента.
- `docs/DESIGN_SYSTEM.md` — UI (перед новим екраном). `docs/TESTING.md` — тести й чеклісти. `docs/CONTENT_PIPELINE.md` — контент, статуси, формат SQL-батчів.
- Skills проєкту: `pr-workflow-croatia` (гілка → PR → мерж власником; замінює `device-sync-croatia`), `content-sql-pack` (SQL-пакети контенту), `lesson-topic-rebuild` (уроки за темою), `croatian-lexeme-batch`, `croatian-content-review`.

## Спілкування з власником

- **Українською**, простими словами. Після змін — **як побачити результат** (після мержу і `git pull`: команда, сторінка `http://localhost:3000/...`).
- SQL — новий файл у `supabase/migrations/` (схема) або `supabase/data_fixes/` (дані) у PR. Після мержу його запускає workflow «Apply SQL (production)» лише після **Approve** власника (`docs/SQL_AUTOMATION.md`); журнал `ops.sql_journal` — кожен файл один раз. Уже запущений файл не міняти — зміна новим файлом. `sql_journal_baseline.txt` не чіпати.
- Власник на Windows, проєкт — `D:\New app\croatian-survival-app`. Тестовий урок: `/lesson/c0000000-0000-0000-0000-000000000001`.
- **Робота через PR** (рішення 2026-11-07), GitHub `sergeygavrilyk/croatian-survival-app` (**публічний**): Claude — гілка від свіжого `main` (`feat/`, `fix/`, `content/`, `docs/`, `chore/`), коміти, push гілки, PR через REST API, перевірка CI. У `main` Claude не пушить, не мерджить, історію `main` не переписує; не робить PR на PR. **Мерж, Approve SQL і `git pull` — власник.** На комп'ютер власника файли не копіювати (лише `git pull`).
- Коміти — англійською, Conventional Commits, автор `Serhii Havryliuk <22850502+sergeygavrilyk@users.noreply.github.com>` + attribution-рядки сесії. Опис PR — українською: що зроблено; що видалено чи спрощено (навіть «нічого»); **послаблені тести** (старе → нове, причина — лише з «ок» власника); які SQL запустяться після мержу і що змінять; перевірки (CI); `git diff --stat`. Ніколи не додавай `.env*`, ключі, дампи даних, email власника.

## Стек і команди

Next.js 16 (App Router; middleware = `proxy.ts`; звіряйся з `node_modules/next/dist/docs/`) + React 19 + TypeScript + Tailwind CSS 4 + Supabase (`@supabase/ssr`) + PWA (`@ducanh2912/next-pwa`, вимкнено в dev).

```bash
npm run dev        # http://localhost:3000
npm run build      # у хмарі недоступно — перевіряє CI на кожному PR
npm run lint && npm run typecheck
npm test           # node --test, Node 22.6+: lib/*.test.ts
npm run e2e        # Playwright (e2e/): збірка + :3100; з входом — лише в власника (E2E_EMAIL/E2E_PASSWORD у .env.local)
```

- CI (`.github/workflows/ci.yml`) на кожному PR і push: lint, unit, збірка, типи, smoke E2E, SQL-тести (`scripts/dev/sqltests.sh`); PR — лише з зеленим CI. Нова сторінка / сценарій → E2E у `e2e/` (без входу — `smoke.spec.ts`). Новий SQL-пакет → рядок у `scripts/dev/curdb.sh`, інакше його тест у CI впаде.
- Логіка — у `lib/` (без БД, імпорти з `.ts`), server actions лише авторизують і викликають її; нова логіка → тест у `lib/*.test.ts` + у скрипт `test`.
- SQL-тести — `supabase/tests/*.test.sql` (транзакція + `ROLLBACK`); нова таблиця з даними користувача → тест ізоляції. Локальна БД і перевірка типів без `node_modules` — `scripts/dev/README.md`.
- **Наявні тести не послаблювати** (знизити поріг, прибрати перевірку, додати виняток, «рівно N» → «щонайменше N») — лише з дозволу власника щоразу: старе → нове і чому (рішення 2026-11-07). Точні кількості, що змінились за погодженим планом (уроків A0 47 → 51), — оновлювати й називати в описі PR.
- Нова фіча → події §71 через `track()` / `trackEvent()` (`docs/ANALYTICS.md`); аналітика ніколи не ламає навчання.

## Правила коду (§75)

- Server Components беруть дані, Client Components — інтерактив (`page.tsx` → `components/*View.tsx`). Сервер: `createClient()` з `utils/supabase/server.ts`.
- RLS для кожної нової таблиці (`auth.uid()`); `SUPABASE_SERVICE_ROLE_KEY` — лише на сервері, ніколи `NEXT_PUBLIC_`.
- AI — лише через `AIProvider` (`lib/ai-provider.ts`, `getAIProvider()`), мовлення — через `SpeechProvider`; кожен виклик AI/TTS/STT → `recordAiUsage()`. Відповідь AI — через перевірку (строгий JSON, хорватське без кирилиці), денний ліміт, мітка «AI». Аудіо користувача не зберігаємо.
- Офлайн (§76): уроки, словник, вправи, SRS, прогрес; AI і мовлення — онлайн.
- UI: семантичні токени (`bg-primary`, `text-ink`…), примітиви `components/ui/`, `lucide-react`, хорватське — в `<Hr>` з 🔊, доступність §98. Деталі — `DESIGN_SYSTEM.md`.
- Інтерфейс українською, ідентифікатори англійською. Нова залежність, таблиця, помітна зміна UX — спершу запропонувати.
- Файли з CRLF (частина файлів власника) — зберігай закінчення рядків при правці.

## База даних

- Supabase **«New app for learning»** (ref `mhdgozragkkogvxpjksp`). Проєкт «sergeygavrilyk's Project» — не чіпати.
- **Не вгадуй таблиці й колонки**: схема — `supabase/migrations/` (baseline + міграції) або `list_tables`. Словник — `lexemes` (`lexeme_id`), таблиці `vocabulary` немає.
- Зміна схеми — нова адитивна ідемпотентна міграція з RLS; дані — `supabase/data_fixes/`. `id` — справжні UUID.
- Видалення, `drop`, зміна контрактів — **лише з дозволу власника** і після копії в схему `backup`.
- Робоча база — **лише читання** (`select`). Запис — лише через workflow «Apply SQL» (Approve власника). Будь-який інший запит, що змінює дані чи схему, навіть пробний прогін з відкатом (`raise exception` у кінці), — **лише з дозволу власника на кожен запуск**: спершу показати, що саме запускаю і навіщо (рішення власника 2026-11-06). Workflow «Apply SQL» Claude сам не запускає.
- Адміни — `app_admins` / `is_admin()`, не email. Статуси контенту (7, CHECK): у застосунку завжди `.eq('status', 'PUBLISHED')`. Старі версії — `content_versions`, перевірки — `content_reviews`, видалення контенту — лише `DEPRECATED`.
- SECURITY DEFINER — з `set search_path = ''` і `revoke`; після міграції — Security Advisor.

## Хорватський контент (найвищий ризик продукту)

- **Жодних заглушок** і прикладів-шаблонів; краще менше рядків. Кожен приклад — природне правильне речення.
- **Слова уроку — за темою уроку**, 20–25 слів і виразів, діалоги під тему (рішення 2026-10-15).
- **Імена в діалогах:** частіше Даша (*Daša*, кличний *Dašo*) / Дар'я (*Darja*).
- **Авторські тексти** (пісні, вірші, книжки) не копіюємо, крім суспільного надбання (до 1929 р.): лише назва, опис, слова, посилання.
- Діакритики в `lemma` обов'язкові; `normalized` — без діакритики, малими. Рід / вид — у `forms`. Переклад — справжній, значення через `; `.
- Лема — слово або сталий вираз; фрази — `phrases`, діалоги — `conversations`. Леми лише латиницею.
- Непевне — позначити для перевірки, не вигадувати (§81). AI-контент: `AI_GENERATED` → перевірка → `PUBLISHED`; виняток — бета A0/A1 за рішенням власника. Батч не перезаписує опубліковане.
- Великі батчі — скриптом у файл з перевіркою унікальності, діакритик, заглушок (формат — `docs/CONTENT_PIPELINE.md`).

## Як працювати (§80, §83)

1. `PROJECT_STATE.md` + потрібні файли `docs/`, код і схема.
2. Нетривіальне — короткий план; PROPOSE / HUMAN — чекати «ок». Класи: **AUTO** (реалізація), **PROPOSE** (архітектура, залежності, таблиці, UX), **HUMAN** (продукт, методика, рівні, видалення даних).
3. Вертикальний зріз: БД + логіка + UI + контент + SRS + аналітика + тести.
4. Перевірка: тести, типи, збірка (CI на PR), сценарій у браузері (власник після мержу).
5. Оновити `PROJECT_STATE.md` (коротко) і запис у `HISTORY.md`; контракти — у профільному `docs/`.
6. Звіт: PR № і посилання, що зроблено, які SQL запустяться після мержу, як перевірити, обмеження, 3 наступні задачі.
