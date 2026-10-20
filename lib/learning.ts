/**
 * Сценарії навчання VS-001 / VS-002 без прив'язки до Supabase.
 *
 * Уся робота з базою — через інтерфейс LearningRepo. У застосунку його реалізує
 * lib/learning-repo-supabase.ts, у тестах — проста реалізація в пам'яті.
 * Так логіку можна перевіряти тестами без бази і без мережі.
 */
import { scheduleReview, NEW_CARD, type SrsState, type SrsResult } from './srs.ts';
import { buildAnalyticsRow, type AnalyticsRow, type EventName, type EventProps } from './analytics.ts';
import { DEFAULT_TIME_ZONE, learningStreak } from './progress.ts';

export interface ReviewHistoryEntry {
  userId: string;
  lexemeId: string;
  result: 0 | 1;
  responseTimeMs: number | null;
  prev: SrsState;
  next: SrsResult;
}

export interface LearningRepo {
  getCardState(userId: string, lexemeId: string): Promise<SrsState | null>;
  saveCardState(userId: string, lexemeId: string, next: SrsResult, now: Date): Promise<void>;
  addReviewHistory(entry: ReviewHistoryEntry): Promise<void>;
  markLessonCompleted(userId: string, lessonId: string, now: Date): Promise<void>;
  getLessonLexemeIds(lessonId: string): Promise<string[]>;
  /** Додає слова в повторення, якщо їх там ще немає. Повертає кількість доданих. */
  addToReviewIfAbsent(userId: string, lexemeIds: string[], dueAt: Date): Promise<number>;
  logEvent(userId: string, row: AnalyticsRow): Promise<void>;
  /**
   * Моменти навчання з `since` (події LEARNING_EVENTS + історія повторень карток) і часовий пояс профілю —
   * для серії днів 🔥 на святковому екрані після уроку (так само, як на «Сьогодні»).
   */
  getLearningActivity(userId: string, since: Date): Promise<{ timestamps: string[]; timeZone: string | null }>;
}

export type Logger = (message: string, error: unknown) => void;
const defaultLogger: Logger = (message, error) => console.error(message, error);

/** Другорядні кроки (історія, аналітика) не повинні ламати основну дію. */
async function softly<T>(label: string, fallback: T, fn: () => Promise<T>, log: Logger): Promise<T> {
  try {
    return await fn();
  } catch (error) {
    log(label, error);
    return fallback;
  }
}

// ---------------------------------------------------------------------------
// Аналітика
// ---------------------------------------------------------------------------

/** Записує подію. Повертає false, якщо подія некоректна або не записалась. Ніколи не кидає. */
export async function trackEvent(
  repo: LearningRepo,
  userId: string,
  name: EventName | string,
  props: EventProps = {},
  now: Date = new Date(),
  log: Logger = defaultLogger
): Promise<boolean> {
  const row = buildAnalyticsRow(name, props, now);
  if (!row) {
    log('Некоректна подія аналітики:', { name, props });
    return false;
  }
  return softly('Помилка запису події аналітики:', false, async () => {
    await repo.logEvent(userId, row);
    return true;
  }, log);
}

// ---------------------------------------------------------------------------
// VS-001: оцінка картки в тренажері
// ---------------------------------------------------------------------------

export interface RateCardInput {
  userId: string;
  lexemeId: string;
  rating: number;            // 1 — «Знаю», 0 — «Не знаю»
  responseTimeMs?: number;
  now?: Date;
}

export async function rateCard(repo: LearningRepo, input: RateCardInput, log: Logger = defaultLogger) {
  const { userId, lexemeId, rating } = input;
  if (rating !== 0 && rating !== 1) throw new Error('Оцінка має бути 0 або 1');
  const now = input.now ?? new Date();

  const prev = (await repo.getCardState(userId, lexemeId)) ?? NEW_CARD;
  const next = scheduleReview(prev, rating === 1, now);

  await repo.saveCardState(userId, lexemeId, next, now);

  await softly('Помилка запису в srs_reviews:', undefined, () =>
    repo.addReviewHistory({
      userId,
      lexemeId,
      result: rating,
      responseTimeMs: typeof input.responseTimeMs === 'number' ? Math.round(input.responseTimeMs) : null,
      prev,
      next,
    }), log);

  return {
    success: true as const,
    nextReviewDate: next.nextReviewDate.toISOString(),
    intervalDays: next.intervalDays,
  };
}

// ---------------------------------------------------------------------------
// VS-002: завершення уроку
// ---------------------------------------------------------------------------

export interface CompleteLessonInput {
  userId: string;
  lessonId: string;
  /** Контекст для аналітики: session_id, duration_ms, level */
  context?: EventProps;
  now?: Date;
}

/** Початок наступної доби — перший повтор слів уроку «завтра». */
export function startOfTomorrow(now: Date): Date {
  const d = new Date(now);
  d.setDate(d.getDate() + 1);
  d.setHours(0, 0, 0, 0);
  return d;
}

export async function completeLesson(repo: LearningRepo, input: CompleteLessonInput, log: Logger = defaultLogger) {
  const { userId, lessonId } = input;
  const now = input.now ?? new Date();

  // Головне: зафіксувати, що урок пройдено. Якщо не вдалось — це помилка для користувача.
  await repo.markLessonCompleted(userId, lessonId, now);

  // Слова уроку → у повторення на завтра (те, що вже вчиться, не чіпаємо)
  const lexemeIds = await softly('Помилка читання слів уроку:', [] as string[], () => repo.getLessonLexemeIds(lessonId), log);
  const uniqueIds = Array.from(new Set(lexemeIds));
  const addedToReview = uniqueIds.length === 0
    ? 0
    : await softly('Помилка додавання слів уроку в повторення:', 0, () =>
        repo.addToReviewIfAbsent(userId, uniqueIds, startOfTomorrow(now)), log);

  await trackEvent(repo, userId, 'lesson_completed', {
    ...input.context,
    lesson_id: lessonId,
    success: true,
    count: uniqueIds.length,
    added_to_review: addedToReview,
  }, now, log);

  // Серія днів 🔥 для святкового екрана. Сьогоднішній урок рахуємо завжди (навіть якщо подія не записалась).
  // Не вдалося прочитати активність — серію не показуємо (null), урок однаково пройдено.
  const streak = await softly('Помилка читання активності для серії:', null as number | null, async () => {
    const since = new Date(now.getTime() - STREAK_LOOKBACK_DAYS * 24 * 60 * 60 * 1000);
    const { timestamps, timeZone } = await repo.getLearningActivity(userId, since);
    return learningStreak([...timestamps, now.toISOString()], now, timeZone ?? DEFAULT_TIME_ZONE);
  }, log);

  return { success: true as const, addedToReview, lessonWords: uniqueIds.length, streak };
}

/** Скільки днів назад дивимось, рахуючи серію (як на «Сьогодні»). */
export const STREAK_LOOKBACK_DAYS = 120;

export type CompleteLessonResult = Awaited<ReturnType<typeof completeLesson>>;
