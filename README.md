# Croatia survival

PWA-застосунок для вивчення хорватської мови україномовними (A0 → B2).

- **Специфікація і стан проєкту:** [`docs/README.md`](docs/README.md)
- **Інструкції для Claude:** [`CLAUDE.md`](CLAUDE.md)
- **Схема бази даних:** [`supabase/migrations/`](supabase/migrations/)

## Запуск

```bash
npm install
npm run dev
```

Відкрийте http://localhost:3000. Тестовий урок: http://localhost:3000/lesson/c0000000-0000-0000-0000-000000000001

Потрібен файл `.env.local` (у git не потрапляє):

```
NEXT_PUBLIC_SUPABASE_URL=...
NEXT_PUBLIC_SUPABASE_ANON_KEY=...
GEMINI_API_KEY=...
```

## Стек

Next.js 16 (App Router) · React 19 · TypeScript · Tailwind CSS 4 · Supabase · PWA
