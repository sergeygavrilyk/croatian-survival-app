'use client';

import { useEffect } from 'react';
import { track } from '@/lib/analytics-client';
import { browserStorage } from '@/lib/offline-copy';
import { BUILD_KEY, buildAction } from '@/lib/offline-refresh';
import { canPrefetchNow, refreshCachedPages } from '@/lib/offline-prefetch-client';

/** Номер збірки (next.config.ts → env): інший, ніж запам'ятований, — застосунок оновився. */
const BUILD_ID = process.env.NEXT_PUBLIC_BUILD_ID ?? '';
/** Почекати, поки сторінка відкриється: оновлення не має гальмувати навчання. */
const START_DELAY_MS = 8000;
/** Скільки чекати, поки нова версія service worker візьме керування. */
const WORKER_WAIT_MS = 60_000;

/**
 * Після оновлення застосунку тихо оновити збережені для офлайну сторінки (§76, рішення 2026-11-16: «а»).
 * Нічого не показує; у кореневому layout.
 */
export default function OfflineRefresh() {
  useEffect(() => {
    let cancelled = false;
    const timer = window.setTimeout(async () => {
      if (cancelled || !canPrefetchNow()) return;
      const storage = browserStorage();
      let stored: string | null = null;
      try {
        stored = storage?.getItem(BUILD_KEY) ?? null;
      } catch {
        return;
      }
      const action = buildAction(stored, BUILD_ID);
      if (action === 'none') return;
      const remember = () => {
        try {
          storage?.setItem(BUILD_KEY, BUILD_ID);
        } catch {
          // сховище переповнене — спробуємо наступного разу
        }
      };
      if (action === 'record') return remember();

      await workerSettled();
      if (cancelled || !canPrefetchNow()) return;
      try {
        const result = await refreshCachedPages();
        if (result.complete) remember();
        if (result.updated + result.gone + result.failed > 0) {
          track('offline_prefetched', { source: 'update', kind: 'refresh', count: result.updated, failed: result.failed });
        }
      } catch {
        // мережа пропала посеред — спробуємо наступного разу
      }
    }, START_DELAY_MS);
    return () => {
      cancelled = true;
      window.clearTimeout(timer);
    };
  }, []);

  return null;
}

/** Якщо нова версія service worker ще встановлюється — дочекатися, поки вона візьме керування (або до хвилини). */
async function workerSettled(): Promise<void> {
  try {
    const reg = await navigator.serviceWorker.getRegistration();
    if (!reg || (!reg.installing && !reg.waiting)) return;
    await new Promise<void>((resolve) => {
      const done = () => {
        navigator.serviceWorker.removeEventListener('controllerchange', done);
        resolve();
      };
      navigator.serviceWorker.addEventListener('controllerchange', done);
      window.setTimeout(done, WORKER_WAIT_MS);
    });
  } catch {
    // немає service worker — оновлювати нічого
  }
}
