/**
 * Підказка «Додати на початковий екран» (§76, рішення власника 2026-11-16: «Робимо підказки»).
 *
 * Навіщо: Safari на iPhone видаляє все, що сайт зберіг (кеш уроків, офлайн-копії, черга прогресу), після 7 днів
 * користування Safari без відкриття сайту; застосунок на початковому екрані має власний лічильник. Android і
 * комп'ютер (Chrome, Edge) дають кнопку встановлення (`beforeinstallprompt`).
 *
 * Коли показуємо (на «Сьогодні»): застосунок ще не встановлено, людина вже пройшла хоча б один урок (просимо
 * після першої користі, а не з порога), і підказку не відкладено. «Не зараз» відкладає на 14 днів, «Готово»
 * (iPhone: людина виконала кроки, але Safari не може дізнатися, що застосунок додано) — на 60 днів.
 * Логіка — без браузера; браузерні частини — `components/InstallHint.tsx`.
 */

export type InstallPlatform = 'ios' | 'android' | 'other';
/** native — кнопка браузера «Встановити»; ios — кроки «Поширити → На початковий екран». */
export type InstallHintKind = 'native' | 'ios';
export type InstallDismissReason = 'later' | 'done' | 'installed';

export const INSTALL_HINT_STORAGE_KEY = 'install-hint-v1';
export const SNOOZE_DAYS: Record<InstallDismissReason, number> = { later: 14, done: 60, installed: 3650 };
const DAY_MS = 24 * 60 * 60 * 1000;

/** iPhone, iPod, iPad (iPadOS 13+ називає себе Mac, але має сенсорний екран). */
export function detectPlatform(userAgent: string, maxTouchPoints = 0): InstallPlatform {
  const ua = userAgent || '';
  if (/iPhone|iPad|iPod/i.test(ua)) return 'ios';
  if (/Macintosh/i.test(ua) && maxTouchPoints > 1) return 'ios';
  if (/Android/i.test(ua)) return 'android';
  return 'other';
}

/** Застосунок уже відкрито з іконки (Android / комп'ютер — display-mode, iPhone — navigator.standalone). */
export function isStandalone(displayModeStandalone: boolean, navigatorStandalone: unknown): boolean {
  return displayModeStandalone || navigatorStandalone === true;
}

export type StoredDismissal = { reason: InstallDismissReason; at: number };

export function parseDismissal(raw: string | null): StoredDismissal | null {
  if (!raw) return null;
  try {
    const v = JSON.parse(raw) as Partial<StoredDismissal>;
    if (!v || typeof v.at !== 'number' || !Number.isFinite(v.at)) return null;
    if (v.reason !== 'later' && v.reason !== 'done' && v.reason !== 'installed') return null;
    return { reason: v.reason, at: v.at };
  } catch {
    return null;
  }
}

export function serializeDismissal(reason: InstallDismissReason, now: number): string {
  return JSON.stringify({ reason, at: now } satisfies StoredDismissal);
}

export function isSnoozed(dismissal: StoredDismissal | null, now: number): boolean {
  if (!dismissal) return false;
  if (dismissal.at > now) return false; // годинник перевели назад — не ховаємо назавжди
  return now - dismissal.at < SNOOZE_DAYS[dismissal.reason] * DAY_MS;
}

export type InstallHintInput = {
  standalone: boolean;
  platform: InstallPlatform;
  /** браузер дав подію beforeinstallprompt (можна показати системне вікно встановлення) */
  canPrompt: boolean;
  dismissal: StoredDismissal | null;
  lessonsDone: number;
  now: number;
};

/** Яку підказку показати, або null. */
export function installHintKind(input: InstallHintInput): InstallHintKind | null {
  if (input.standalone) return null;
  if (input.lessonsDone < 1) return null;
  if (isSnoozed(input.dismissal, input.now)) return null;
  // iPhone: системного вікна встановлення не буває — лише кроки в Safari
  if (input.platform === 'ios') return 'ios';
  if (input.canPrompt) return 'native';
  return null;
}
