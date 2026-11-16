/**
 * Аналітика в браузері: ідентифікатор сесії + «вистрілив і забув».
 * Подія відправляється через server action, тож user_id ставить сервер, а не клієнт.
 */
import { trackEvent } from '@/app/actions/analytics';
import type { EventName, EventProps } from '@/lib/analytics';
import { failedForNetwork, isBrowserOffline, queueEvent } from '@/lib/offline-client';

const SESSION_KEY = 'cs_analytics_session';
let memorySessionId: string | null = null;

function newId(): string {
  if (typeof crypto !== 'undefined' && 'randomUUID' in crypto) return crypto.randomUUID();
  // Запасний варіант для старих браузерів
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16);
  });
}

/** Сесія = вкладка браузера (sessionStorage). Якщо сховище недоступне — тримаємо в пам'яті. */
export function getSessionId(): string {
  try {
    const existing = sessionStorage.getItem(SESSION_KEY);
    if (existing) return existing;
    const id = newId();
    sessionStorage.setItem(SESSION_KEY, id);
    return id;
  } catch {
    memorySessionId ??= newId();
    return memorySessionId;
  }
}

/**
 * Відправити подію. Не чекає відповіді і не кидає помилок.
 * Без мережі подія йде в чергу на телефоні (lib/offline-client.ts) з часом, коли людина вчилася,
 * і відправиться, щойно з'явиться інтернет — «Успішна навчальна сесія» рахується за справжнім днем.
 */
export function track(name: EventName, props: EventProps = {}): void {
  try {
    const full = { ...props, session_id: getSessionId() };
    if (isBrowserOffline()) {
      queueEvent(name, full);
      return;
    }
    void trackEvent(name, full).catch((error: unknown) => {
      if (failedForNetwork(error)) queueEvent(name, full);
    });
  } catch {
    // аналітика ніколи не ламає інтерфейс
  }
}
