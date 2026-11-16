'use client';

import { useEffect } from 'react';
import { getOfflinePlan } from '@/app/actions/offline';
import { track } from '@/lib/analytics-client';
import { browserStorage } from '@/lib/offline-copy';
import { PLAN_RECORD_KEY, isPlanDue, parsePlanRecord, planKey, rememberPlan } from '@/lib/offline-prefetch';
import { canPrefetchNow, prefetchPages } from '@/lib/offline-prefetch-client';

/** Чекаємо, поки сторінка відкриється й заспокоїться: збереження наперед не має гальмувати урок. */
const START_DELAY_MS = 3000;

/** Плани, що вже йдуть у цій вкладці (повторний рендер не запускає вдруге). */
const running = new Set<string>();

/**
 * Тихо зберегти на телефоні сторінки наперед (§76, 2026-11-16): нічого не показує.
 * Урок → наступні уроки модуля й тексти; «Сьогодні» → урок «Продовжити» з наступними і ситуації з фразами.
 */
export default function OfflinePrefetch({
  lessonId,
  includeCurrent = false,
  situations = false,
  source,
}: {
  lessonId?: string | null;
  includeCurrent?: boolean;
  situations?: boolean;
  source: 'lesson' | 'today';
}) {
  useEffect(() => {
    if (!lessonId && !situations) return;
    const key = planKey(source, lessonId, situations);
    let cancelled = false;
    const timer = window.setTimeout(async () => {
      if (cancelled || running.has(key) || !canPrefetchNow()) return;
      const storage = browserStorage();
      const record = parsePlanRecord(readRecord(storage));
      if (!isPlanDue(record, key, Date.now())) return;
      running.add(key);
      try {
        const { urls } = await getOfflinePlan({ lessonId, includeCurrent, situations });
        if (urls.length === 0) return;
        const result = await prefetchPages(urls);
        if (result.failed === 0) writeRecord(storage, rememberPlan(record, key, Date.now()));
        if (result.fetched > 0 || result.failed > 0) {
          track('offline_prefetched', { source, count: result.fetched, failed: result.failed, kind: situations ? 'lessons_situations' : 'lessons' });
        }
      } catch {
        // мережа пропала посеред — спробуємо наступного разу
      } finally {
        running.delete(key);
      }
    }, START_DELAY_MS);
    return () => {
      cancelled = true;
      window.clearTimeout(timer);
    };
  }, [lessonId, includeCurrent, situations, source]);

  return null;
}

function readRecord(storage: ReturnType<typeof browserStorage>): string | null {
  try {
    return storage?.getItem(PLAN_RECORD_KEY) ?? null;
  } catch {
    return null;
  }
}

function writeRecord(storage: ReturnType<typeof browserStorage>, record: Record<string, number>) {
  try {
    storage?.setItem(PLAN_RECORD_KEY, JSON.stringify(record));
  } catch {
    // сховище переповнене — не біда, план просто повториться
  }
}
