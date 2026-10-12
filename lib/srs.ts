/**
 * Планувальник повторень (SRS) — чиста логіка без бази даних.
 *
 * Адаптований SM-2 під бінарний свайп («Знаю» / «Не знаю»).
 * Це стартовий алгоритм (§40 ТЗ). Адаптивний планувальник зі stability /
 * difficulty / retrievability (§120) замінить його пізніше — інтерфейс
 * функції залишиться тим самим.
 */

export const DEFAULT_EASE = 2.5;
export const MIN_EASE = 1.3;
export const MAX_EASE = 3.5;

export interface SrsState {
  easeFactor: number;
  intervalDays: number;
  repetitionCount: number;
  lapses: number;
}

export interface SrsResult extends SrsState {
  nextReviewDate: Date;
}

export const NEW_CARD: SrsState = {
  easeFactor: DEFAULT_EASE,
  intervalDays: 0,
  repetitionCount: 0,
  lapses: 0,
};

/**
 * @param prev поточний стан картки (або NEW_CARD для нової)
 * @param isCorrect true — «Знаю» (свайп вправо), false — «Не знаю» (свайп вліво)
 * @param now момент відповіді (параметр — для тестів)
 */
export function scheduleReview(prev: SrsState, isCorrect: boolean, now: Date = new Date()): SrsResult {
  let { easeFactor, intervalDays, repetitionCount, lapses } = prev;

  if (!isCorrect) {
    // Помилка: картка повертається в чергу сьогодні, стає «складнішою»
    if (repetitionCount > 0) lapses += 1;
    repetitionCount = 0;
    intervalDays = 0;
    easeFactor = Math.max(MIN_EASE, easeFactor - 0.2);
  } else {
    if (repetitionCount === 0) intervalDays = 1;       // перший успіх — завтра
    else if (repetitionCount === 1) intervalDays = 3;  // другий — через 3 дні
    else intervalDays = Math.max(intervalDays + 1, Math.round(intervalDays * easeFactor));
    repetitionCount += 1;
    easeFactor = Math.min(MAX_EASE, easeFactor + 0.1);
  }

  const nextReviewDate = new Date(now);
  if (intervalDays > 0) {
    nextReviewDate.setDate(nextReviewDate.getDate() + intervalDays);
    nextReviewDate.setHours(0, 0, 0, 0); // початок доби — картка стає доступною зранку
  }

  return {
    easeFactor: Number(easeFactor.toFixed(3)),
    intervalDays,
    repetitionCount,
    lapses,
    nextReviewDate,
  };
}

/** Нижній регістр без хорватських діакритик: «Kožna jakna» → «kozna jakna». */
export function normalizeCroatian(text: string): string {
  return text
    .trim()
    .toLowerCase()
    .replace(/[čć]/g, 'c')
    .replace(/đ/g, 'd')
    .replace(/š/g, 's')
    .replace(/ž/g, 'z');
}
