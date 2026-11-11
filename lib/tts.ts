/**
 * Озвучення через /api/tts: перевірка тексту й денний ліміт (рішення власника 2026-11-11).
 * Чиста логіка без БД. Лічильник за добу веде база: функція public.consume_tts_quota()
 * (міграція M22); там той самий ліміт — тест у lib/tts.test.ts звіряє числа.
 */

/** Найдовший текст одного запиту. Тексти для читання озвучуються шматками до 180 символів (lib/reading.ts). */
export const TTS_MAX_CHARS = 300;

/** Скільки запитів озвучення на добу (UTC) може зробити один користувач. */
export const TTS_DAILY_LIMIT = 300;

export type TtsTextCheck =
  | { ok: true; text: string }
  | { ok: false; status: 400 | 413; error: string };

/** Перевірити текст із запиту: не порожній і не довший за TTS_MAX_CHARS (після обрізання пробілів). */
export function checkTtsText(raw: string | null | undefined): TtsTextCheck {
  const text = (raw ?? '').replace(/\s+/g, ' ').trim();
  if (!text) return { ok: false, status: 400, error: 'Text is required' };
  if (text.length > TTS_MAX_CHARS) {
    return { ok: false, status: 413, error: `Text is longer than ${TTS_MAX_CHARS} characters` };
  }
  return { ok: true, text };
}

/** Скільки секунд до наступної півночі UTC — для заголовка Retry-After, коли ліміт вичерпано. */
export function secondsUntilUtcMidnight(now: Date): number {
  const next = Date.UTC(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate() + 1);
  return Math.max(1, Math.ceil((next - now.getTime()) / 1000));
}

export interface TtsQuotaRow {
  allowed: boolean | null;
  used: number | null;
  daily_limit: number | null;
}

/**
 * Відповідь consume_tts_quota() → чи можна озвучувати.
 * Якщо база не відповіла (помилка, функції ще немає до Approve міграції) — пропускаємо:
 * вхід уже обов'язковий, а озвучення не повинно ламати навчання через збій лічильника.
 */
export function quotaAllows(data: unknown, error: unknown): boolean {
  if (error) return true;
  const row = (Array.isArray(data) ? data[0] : data) as TtsQuotaRow | null | undefined;
  if (!row || typeof row.allowed !== 'boolean') return true;
  return row.allowed;
}
