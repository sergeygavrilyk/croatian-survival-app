'use client';

import { useEffect } from 'react';
import { syncOfflineOps } from '@/app/actions/offline-sync';
import { browserStorage } from '@/lib/offline-copy';
import { QUEUE_CHANGED_EVENT, readQueue, removeOps, syncBatches, syncRetryDelay } from '@/lib/offline-queue';
import { isSettled } from '@/lib/offline-sync';
import { currentUserId, isBrowserOffline, notifyQueueChanged, type QueueChangedDetail } from '@/lib/offline-client';

const LOCK_NAME = 'cs-offline-sync';

class RetryLater extends Error {}

/** Одна вкладка відправляє за раз (Web Locks; старий браузер — без замка, повтор номера однаково відсіє сервер). */
async function withSyncLock(work: () => Promise<void>): Promise<void> {
  const locks = typeof navigator !== 'undefined' ? navigator.locks : undefined;
  if (!locks?.request) return work();
  await locks.request(LOCK_NAME, { ifAvailable: true }, async (lock) => {
    if (lock) await work();
  });
}

/**
 * Тиха відправка офлайн-черги (рішення власника 2026-11-16, ARCHITECTURE §76). Нічого не малює.
 * Коли: відкриття застосунку, «мережа з'явилась», повернення у вкладку, нова дія в черзі (якщо мережа є).
 * Пакетами по 20, у порядку, як людина вчилася; сервер не відповів — пауза 5 с → 30 с → 2 хв.
 * Нічого не перезавантажує й не перериває урок. Значок «⏳ … чекають на інтернет» — OfflinePendingNote.
 */
export default function OfflineSync() {
  useEffect(() => {
    let timer: ReturnType<typeof setTimeout> | undefined;
    let failures = 0;
    let running = false;
    let stopped = false;

    const schedule = (ms: number) => {
      clearTimeout(timer);
      timer = setTimeout(() => void run(), ms);
    };

    const send = async (userId: string) => {
      const storage = browserStorage();
      let synced = 0;
      try {
        for (const batch of syncBatches(readQueue(storage, userId).ops)) {
          const res = await syncOfflineOps(batch);
          if (!res.ok) throw new RetryLater('unauthenticated'); // вийшли з акаунта — черга чекає входу
          removeOps(storage, userId, res.results.filter((r) => isSettled(r.status)).map((r) => r.op_id));
          synced += res.results.filter((r) => r.status === 'ok' || r.status === 'duplicate').length;
          if (res.results.some((r) => !isSettled(r.status))) throw new RetryLater('retry');
        }
      } finally {
        if (synced > 0) notifyQueueChanged({ reason: 'synced', synced });
      }
    };

    async function run() {
      if (running || stopped || isBrowserOffline()) return;
      const userId = currentUserId();
      if (!userId) return;
      if (readQueue(browserStorage(), userId).ops.length === 0) return;
      running = true;
      try {
        await withSyncLock(() => send(userId));
        failures = 0;
        // поки відправляли, могли з'явитися нові дії
        if (readQueue(browserStorage(), userId).ops.length > 0) schedule(1_000);
      } catch {
        failures += 1;
        schedule(syncRetryDelay(failures));
      } finally {
        running = false;
      }
    }

    const onOnline = () => {
      failures = 0;
      void run();
    };
    const onVisible = () => {
      if (document.visibilityState === 'visible') void run();
    };
    const onQueued = (e: Event) => {
      const detail = (e as CustomEvent<QueueChangedDetail>).detail;
      // дію покладено в чергу, хоча браузер «онлайн» (збій зв'язку) — спробуємо трохи згодом
      if (detail?.reason === 'queued' && !isBrowserOffline()) schedule(syncRetryDelay(1));
    };

    void run();
    window.addEventListener('online', onOnline);
    document.addEventListener('visibilitychange', onVisible);
    window.addEventListener(QUEUE_CHANGED_EVENT, onQueued);
    return () => {
      stopped = true;
      clearTimeout(timer);
      window.removeEventListener('online', onOnline);
      document.removeEventListener('visibilitychange', onVisible);
      window.removeEventListener(QUEUE_CHANGED_EVENT, onQueued);
    };
  }, []);

  return null;
}
