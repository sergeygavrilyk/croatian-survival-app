/**
 * Браузерна частина «уроки й фрази наперед» (§76, 2026-11-16): перевірки, запит сторінок, чистка кешу при виході.
 * Логіка без браузера — lib/offline-prefetch.ts.
 */
import { PREFETCH_HEADER, PREFETCH_HEADER_VALUE, shouldPrefetch } from './offline-prefetch.ts';
import { PAGE_CACHE_NAMES } from './pwa-cache.ts';

type NavigatorWithConnection = Navigator & { connection?: { saveData?: boolean } };

/** Чи можна зараз зберігати наперед (мережа є, service worker керує сторінкою, без економії трафіку). */
export function canPrefetchNow(): boolean {
  if (typeof navigator === 'undefined' || typeof window === 'undefined') return false;
  return shouldPrefetch({
    online: navigator.onLine,
    saveData: Boolean((navigator as NavigatorWithConnection).connection?.saveData),
    hasController: Boolean(navigator.serviceWorker?.controller) && typeof caches !== 'undefined',
  });
}

/**
 * Зберегти сторінки по одній. Сторінку, що вже є в кеші, не чіпаємо: відвідану онлайн (повну, з діалогами) не
 * переписуємо, а кеш і так оновлюється, коли людина її відкриває. Збій однієї сторінки не зупиняє інших.
 */
export async function prefetchPages(urls: readonly string[]): Promise<{ fetched: number; skipped: number; failed: number }> {
  const result = { fetched: 0, skipped: 0, failed: 0 };
  let cache: Cache;
  try {
    cache = await caches.open('pages');
  } catch {
    return { ...result, failed: urls.length };
  }
  for (const url of urls) {
    if (!navigator.onLine) {
      result.failed++;
      continue;
    }
    try {
      if (await cache.match(url)) {
        result.skipped++;
        continue;
      }
      // redirect: 'manual' — сесія скінчилась → переадресація не стане «уроком» у кеші (правило бере лише 200)
      const res = await fetch(url, {
        headers: { [PREFETCH_HEADER]: PREFETCH_HEADER_VALUE },
        credentials: 'same-origin',
        redirect: 'manual',
        cache: 'no-store',
      });
      if (res.status === 200) result.fetched++;
      else result.failed++;
    } catch {
      result.failed++;
    }
  }
  return result;
}

/** Вихід з акаунта: прибрати збережені сторінки (там «Сьогодні», ім'я, прогрес). Черга й копії уроків лишаються. */
export async function clearPageCaches(): Promise<void> {
  if (typeof caches === 'undefined') return;
  await Promise.all(PAGE_CACHE_NAMES.map((name) => caches.delete(name).catch(() => false)));
}
