/**
 * Кеш сторінок PWA (§76, рішення власника 2026-11-16).
 *
 * Стандартні налаштування @ducanh2912/next-pwa зберігають сторінку лише 24 години й не більше 32 сторінок:
 * урок, відкритий учора, сьогодні без мережі не відкривався. Тут — власні правила для трьох кешів сторінок
 * (`pages-rsc-prefetch`, `pages-rsc`, `pages`); решту стандартних правил бібліотека додає сама
 * (`extendDefaultRuntimeCaching: true`), а однойменні стандартні — прибирає.
 *
 * Важливо:
 * - власні правила стають ПЕРЕД стандартними, тому правило `pages` ловить лише відкриття сторінки
 *   (`request.mode === 'navigate'`), а не скрипти, стилі й картинки — їх кешують стандартні правила;
 * - Workbox переносить `urlPattern` у service worker як текст функції, тому функції — без зовнішніх змінних;
 * - `networkTimeoutSeconds`: на слабкій мережі (метро) сторінка відкривається з кешу за 5 с замість «висіти»;
 *   якщо копії в кеші немає — чекаємо мережу далі. Свіжа сторінка з мережі все одно оновлює кеш;
 * - уроки й ситуації наперед (lib/offline-prefetch.ts) — звичайний запит із заголовком `X-Offline-Prefetch: page`;
 *   четверте правило кладе його в той самий кеш `pages`, і без мережі сторінка відкривається, як щойно відвідана.
 *   Лише відповіді 200: переадресація на вхід (сесія скінчилась) у кеш не потрапляє.
 */

/** Скільки зберігаємо сторінку в кеші: 30 днів. */
export const PAGE_CACHE_MAX_AGE_SECONDS = 30 * 24 * 60 * 60;
/** Скільки сторінок (уроків, текстів, екранів) тримаємо: 200 (~100 КБ кожна, разом ≤ ~20 МБ). */
export const PAGE_CACHE_MAX_ENTRIES = 200;
/** Скільки чекати мережу, перш ніж показати копію з кешу. */
export const PAGE_NETWORK_TIMEOUT_SECONDS = 5;

type UrlPatternArgs = { request: Request; url: URL; sameOrigin: boolean };

export type PageCacheRule = {
  urlPattern: (args: UrlPatternArgs) => boolean;
  handler: 'NetworkFirst';
  options: {
    cacheName: 'pages-rsc-prefetch' | 'pages-rsc' | 'pages';
    networkTimeoutSeconds?: number;
    expiration: { maxEntries: number; maxAgeSeconds: number };
    /** Які відповіді класти в кеш (за замовчуванням Workbox бере 0 і 200) */
    cacheableResponse?: { statuses: number[] };
  };
};

/** Кеші сторінок — їх чистимо, коли людина виходить з акаунта (там її «Сьогодні», прогрес, ім'я). */
export const PAGE_CACHE_NAMES = ['pages-rsc-prefetch', 'pages-rsc', 'pages'] as const;

export const pageCacheRules: PageCacheRule[] = [
  {
    // Попереднє завантаження сторінки роутером Next.js (посилання на екрані)
    urlPattern: ({ request, url, sameOrigin }) =>
      sameOrigin &&
      !url.pathname.startsWith('/api/') &&
      request.headers.get('RSC') === '1' &&
      request.headers.get('Next-Router-Prefetch') === '1',
    handler: 'NetworkFirst',
    options: {
      cacheName: 'pages-rsc-prefetch',
      expiration: { maxEntries: PAGE_CACHE_MAX_ENTRIES, maxAgeSeconds: PAGE_CACHE_MAX_AGE_SECONDS },
    },
  },
  {
    // Перехід усередині застосунку (дані сторінки для роутера Next.js)
    urlPattern: ({ request, url, sameOrigin }) =>
      sameOrigin && !url.pathname.startsWith('/api/') && request.headers.get('RSC') === '1',
    handler: 'NetworkFirst',
    options: {
      cacheName: 'pages-rsc',
      networkTimeoutSeconds: PAGE_NETWORK_TIMEOUT_SECONDS,
      expiration: { maxEntries: PAGE_CACHE_MAX_ENTRIES, maxAgeSeconds: PAGE_CACHE_MAX_AGE_SECONDS },
    },
  },
  {
    // Відкриття сторінки (адреса, оновлення, нова вкладка, перехід без роутера)
    urlPattern: ({ request, url, sameOrigin }) =>
      sameOrigin && request.mode === 'navigate' && !url.pathname.startsWith('/api/'),
    handler: 'NetworkFirst',
    options: {
      cacheName: 'pages',
      networkTimeoutSeconds: PAGE_NETWORK_TIMEOUT_SECONDS,
      expiration: { maxEntries: PAGE_CACHE_MAX_ENTRIES, maxAgeSeconds: PAGE_CACHE_MAX_AGE_SECONDS },
    },
  },
  {
    // Сторінка наперед для офлайну (lib/offline-prefetch.ts): той самий кеш, що й відкриття сторінки
    urlPattern: ({ request, url, sameOrigin }) =>
      sameOrigin && !url.pathname.startsWith('/api/') && request.headers.get('X-Offline-Prefetch') === 'page',
    handler: 'NetworkFirst',
    options: {
      cacheName: 'pages',
      expiration: { maxEntries: PAGE_CACHE_MAX_ENTRIES, maxAgeSeconds: PAGE_CACHE_MAX_AGE_SECONDS },
      cacheableResponse: { statuses: [200] },
    },
  },
];
