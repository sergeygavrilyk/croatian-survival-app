/**
 * Озвучення хорватського тексту через наш /api/tts. Лише для клієнта.
 *
 * Одночасно грає лише один звук (баг 2026-10-21: кілька натискань ▶ запускали стільки ж копій одночасно).
 * Новий звук зупиняє попередній; перед слуханням мікрофона звук теж зупиняємо (stopCroatianAudio) —
 * у Safari активне відтворення заважає розпізнаванню мовлення.
 */

export interface PlayHandlers {
  /** Не прибирати маркер ролі (довгі тексти для читання озвучуємо як є) */
  raw?: boolean;
  /** Звук дограв до кінця */
  onEnded?: () => void;
  /** Не вдалося завантажити або відтворити */
  onError?: () => void;
  /** Звук зупинили (новим звуком, мікрофоном або stopCroatianAudio) */
  onStop?: () => void;
}

let current: { audio: HTMLAudioElement; handlers: PlayHandlers } | null = null;
/** Чи грав на цій сторінці хоч один звук (для діагностики мікрофона в Safari) */
let playedAny = false;

export function hasPlayedAudio(): boolean {
  return playedAny;
}

/** Прибрати маркер ролі в діалогах («Daša: …») */
function cleanText(text: string): string {
  return text.replace(/^[A-Za-zА-Яа-яЄ-юІ-іҐ-ґ\s]+:\s*/, '').trim();
}

/** Зупинити звук, що грає зараз (якщо є). Повертає true, якщо щось грало. */
export function stopCroatianAudio(): boolean {
  const playing = current;
  if (!playing) return false;
  current = null;
  const { audio, handlers } = playing;
  audio.onended = null;
  audio.onerror = null;
  try {
    audio.pause();
    // звільняємо аудіосесію (важливо для iPhone: інакше мікрофон може не стартувати)
    audio.removeAttribute('src');
    audio.load();
  } catch {
    /* уже зупинено */
  }
  handlers.onStop?.();
  return true;
}

/** Відтворити хорватський текст; попередній звук зупиняється. */
export function playCroatian(text: string, handlers: PlayHandlers = {}): void {
  if (typeof window === 'undefined' || !text) return;
  const clean = handlers.raw ? text.trim() : cleanText(text);
  if (!clean) return;

  stopCroatianAudio();

  playedAny = true;
  const audio = new Audio(`/api/tts?text=${encodeURIComponent(clean)}`);
  const entry = { audio, handlers };
  current = entry;
  const done = (cb?: () => void) => {
    if (current !== entry) return;
    current = null;
    cb?.();
  };
  audio.onended = () => done(handlers.onEnded);
  audio.onerror = () => done(handlers.onError);
  audio.play().catch((error: unknown) => {
    // AbortError — нас перервав новий звук, це не помилка
    if ((error as { name?: string })?.name === 'AbortError') return;
    console.error('Не вдалося відтворити аудіо:', error);
    done(handlers.onError);
  });
}

export function speakCroatian(text: string): void {
  playCroatian(text);
}
