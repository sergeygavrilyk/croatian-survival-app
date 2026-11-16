/**
 * Браузерна частина підказки «Додати на початковий екран» (логіка — lib/install-hint.ts).
 *
 * - Android / комп'ютер (Chrome, Edge): браузер шле `beforeinstallprompt`, коли застосунок можна встановити.
 *   Ловимо подію на рівні всього застосунку (components/InstallPromptCapture.tsx у кореневому layout), бо вона
 *   приходить один раз і може прийти раніше, ніж відкриється «Сьогодні»; кнопка «Встановити» показує системне вікно.
 * - Застосунок відкрито з іконки — просимо браузер не видаляти збережене (`navigator.storage.persist()`;
 *   встановленим застосункам браузери дають це без запитань).
 */
import { browserStorage } from './offline-copy.ts';
import {
  INSTALL_HINT_STORAGE_KEY,
  detectPlatform,
  installHintKind,
  isStandalone,
  parseDismissal,
  serializeDismissal,
  type InstallDismissReason,
  type InstallHintKind,
} from './install-hint.ts';

type BeforeInstallPromptEvent = Event & {
  prompt(): Promise<void>;
  userChoice: Promise<{ outcome: 'accepted' | 'dismissed' }>;
};

export const INSTALL_HINT_CHANGED_EVENT = 'install-hint-changed';

let deferredPrompt: BeforeInstallPromptEvent | null = null;

function notify() {
  window.dispatchEvent(new Event(INSTALL_HINT_CHANGED_EVENT));
}

function standaloneNow(): boolean {
  try {
    const displayMode = window.matchMedia?.('(display-mode: standalone)').matches ?? false;
    return isStandalone(displayMode, (navigator as Navigator & { standalone?: unknown }).standalone);
  } catch {
    return false;
  }
}

/** Запам'ятати відкладання / встановлення. */
export function rememberInstallHint(reason: InstallDismissReason): void {
  try {
    browserStorage()?.setItem(INSTALL_HINT_STORAGE_KEY, serializeDismissal(reason, Date.now()));
  } catch {
    // сховище заборонене — підказка просто покажеться ще раз
  }
  notify();
}

/** Підписка для useSyncExternalStore. */
export function subscribeInstallHint(onChange: () => void): () => void {
  window.addEventListener(INSTALL_HINT_CHANGED_EVENT, onChange);
  window.addEventListener('storage', onChange);
  return () => {
    window.removeEventListener(INSTALL_HINT_CHANGED_EVENT, onChange);
    window.removeEventListener('storage', onChange);
  };
}

/** Яку підказку показати зараз (рядок або null — стабільний знімок для useSyncExternalStore). */
export function currentInstallHint(lessonsDone: number): InstallHintKind | null {
  try {
    return installHintKind({
      standalone: standaloneNow(),
      platform: detectPlatform(navigator.userAgent, navigator.maxTouchPoints ?? 0),
      canPrompt: deferredPrompt !== null,
      dismissal: parseDismissal(browserStorage()?.getItem(INSTALL_HINT_STORAGE_KEY) ?? null),
      lessonsDone,
      now: Date.now(),
    });
  } catch {
    return null;
  }
}

/** Показати системне вікно встановлення (Android / комп'ютер). */
export async function promptInstall(): Promise<'accepted' | 'dismissed' | 'unavailable'> {
  const event = deferredPrompt;
  if (!event) return 'unavailable';
  deferredPrompt = null; // подію можна використати лише раз
  try {
    await event.prompt();
    const { outcome } = await event.userChoice;
    return outcome;
  } catch {
    return 'unavailable';
  } finally {
    notify();
  }
}

/** Слухати браузер (кореневий layout). Повертає функцію відписки. */
export function captureInstallPrompt(): () => void {
  const onPrompt = (e: Event) => {
    e.preventDefault(); // своє вікно браузера покажемо кнопкою «Встановити» на «Сьогодні»
    deferredPrompt = e as BeforeInstallPromptEvent;
    notify();
  };
  const onInstalled = () => {
    deferredPrompt = null;
    rememberInstallHint('installed');
  };
  window.addEventListener('beforeinstallprompt', onPrompt);
  window.addEventListener('appinstalled', onInstalled);

  if (standaloneNow()) {
    try {
      const storage = navigator.storage;
      void storage
        ?.persisted?.()
        .then((persisted) => (persisted ? undefined : storage.persist?.()))
        .catch(() => undefined);
    } catch {
      // старий браузер без StorageManager — нічого
    }
  }

  return () => {
    window.removeEventListener('beforeinstallprompt', onPrompt);
    window.removeEventListener('appinstalled', onInstalled);
  };
}
