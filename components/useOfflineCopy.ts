'use client';

import { useEffect, useMemo, useSyncExternalStore } from 'react';
import {
  browserStorage, offlineKey, parseOfflineCopy, purgeLegacyCache, readOfflineRaw, saveOfflineCopy, type OfflineKind,
} from '@/lib/offline-copy';

const noSubscribe = () => () => {};

/**
 * Офлайн-копія сторінки (§76) для екранів, чиї дані бере сервер (урок, текст для читання).
 * - є свіжі дані з сервера → зберегти копію (перезаписує стару, версій кешу немає) і показати їх;
 * - сервер не відповів → показати останню копію з цього браузера, якщо вона є і має правильний формат.
 * `checked` — копію вже перевірено (на сервері й під час гідратації сховища ще не видно).
 */
export function useOfflineCopy<T>(
  kind: OfflineKind,
  id: string,
  fresh: T | null,
  isValid: (data: unknown) => data is T,
  { useCopy = true }: { useCopy?: boolean } = {},
): { data: T | null; checked: boolean } {
  const key = offlineKey(kind, id);

  useEffect(() => {
    const storage = browserStorage();
    purgeLegacyCache(storage);
    if (fresh) saveOfflineCopy(storage, key, fresh);
  }, [key, fresh]);

  // undefined — сервер / гідратація (копії ще не видно); null — копії немає
  const raw = useSyncExternalStore(
    noSubscribe,
    () => (fresh || !useCopy ? null : readOfflineRaw(browserStorage(), key)),
    () => undefined,
  );
  const copy = useMemo(() => (raw ? parseOfflineCopy(raw, isValid) : null), [raw, isValid]);

  return { data: fresh ?? copy?.data ?? null, checked: fresh !== null || raw !== undefined };
}
