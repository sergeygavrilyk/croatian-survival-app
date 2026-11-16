/**
 * Офлайн-черга в браузері (офлайн без втрат, 2026-11-16): хто користувач, покласти дію в чергу,
 * повідомити значок. Логіка черги — lib/offline-queue.ts, відправлення — components/OfflineSync.tsx.
 * Ніколи не кидає помилок: черга — запасний шлях, вона не повинна ламати урок.
 */
import { browserStorage } from './offline-copy.ts';
import {
  enqueueOp, isNetworkError, newOp, QUEUE_CHANGED_EVENT, readUserIdCookie, type OfflineOpKind,
} from './offline-queue.ts';
import type { EventName, EventProps } from './analytics.ts';

export interface QueueChangedDetail {
  /** Що сталося: дію покладено в чергу / черга відправлена */
  reason: 'queued' | 'synced';
  /** Скільки дій сервер щойно прийняв */
  synced?: number;
}

/** id користувача з cookie `cs_uid` (ставить proxy.ts) або null — гість, сервер, cookie недоступні. */
export function currentUserId(): string | null {
  try {
    return typeof document === 'undefined' ? null : readUserIdCookie(document.cookie);
  } catch {
    return null;
  }
}

/** Браузер точно знає, що мережі немає. */
export function isBrowserOffline(): boolean {
  return typeof navigator !== 'undefined' && navigator.onLine === false;
}

/** Чи помилку виклику сервера спричинила відсутність мережі (тоді — у чергу). */
export function failedForNetwork(error: unknown): boolean {
  return isNetworkError(error, typeof navigator === 'undefined' ? undefined : navigator.onLine);
}

export function notifyQueueChanged(detail: QueueChangedDetail): void {
  try {
    window.dispatchEvent(new CustomEvent<QueueChangedDetail>(QUEUE_CHANGED_EVENT, { detail }));
  } catch {
    // значок оновиться пізніше
  }
}

function put(kind: OfflineOpKind, payload: Record<string, unknown>): boolean {
  const userId = currentUserId();
  if (!userId) return false;
  const res = enqueueOp(browserStorage(), newOp(kind, userId, payload));
  if (!res.ok) return false;
  notifyQueueChanged({ reason: 'queued' });
  return true;
}

/** Подію навчання — у чергу (без мережі). */
export function queueEvent(name: EventName, props: EventProps): boolean {
  return put('event', { name, props });
}

/**
 * Дію прогресу (урок, текст, слово) — у чергу. true — збережено на телефоні.
 * Плюс подія offline_queued (теж через чергу — мережі ж немає).
 */
export function queueProgress(kind: Exclude<OfflineOpKind, 'event'>, payload: Record<string, unknown>): boolean {
  const ok = put(kind, payload);
  if (ok) queueEvent('offline_queued', { kind });
  return ok;
}
