/**
 * Прогрес користувача (екран «Профіль»): чиста логіка без БД.
 * Слова: user_progress; активність: srs_reviews; уроки: lesson_progress.
 * «Сьогодні»: activityWeek / learningStreak — усе навчання (analytics_events + srs_reviews).
 */
import { CEFR_ORDER } from './situations.ts';

export interface ProgressCard {
  interval_days: number | null;
  next_review_date: string | null;
  cefr?: string | null;
}

export interface ProgressInput {
  now: Date;
  timeZone?: string | null;
  cards: ReadonlyArray<ProgressCard>;
  reviews: ReadonlyArray<{ created_at: string }>;
  lessonsCompleted: number;
}

export interface DayActivity {
  date: string;   // YYYY-MM-DD у часовому поясі користувача
  label: string;  // Пн, Вт…
  count: number;
}

export interface ProgressSummary {
  inLearning: number;   // усі слова в повтореннях
  dueNow: number;       // час повторити
  learned: number;      // пам'ятає щонайменше день
  longTerm: number;     // інтервал ≥ 21 дня — засвоєно надовго
  lessonsCompleted: number;
  byLevel: Array<{ level: string; count: number }>;
  activity: DayActivity[];
  activeDays: number;
  reviews7: number;
}

/** Інтервал, з якого слово вважаємо засвоєним надовго (3 тижні) */
export const LONG_TERM_DAYS = 21;
const WEEKDAYS = ['Нд', 'Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб'];

/** Часовий пояс, якщо в профілі його немає. */
export const DEFAULT_TIME_ZONE = 'Europe/Zagreb';

/** Дата YYYY-MM-DD у заданому часовому поясі (невідомий пояс → UTC). */
export function dayKey(date: Date, timeZone?: string | null): string {
  const fmt = (tz: string) =>
    new Intl.DateTimeFormat('en-CA', { timeZone: tz, year: 'numeric', month: '2-digit', day: '2-digit' }).format(date);
  try {
    return fmt(timeZone || 'UTC');
  } catch {
    return fmt('UTC');
  }
}

function shiftKey(key: string, days: number): string {
  const [y, m, d] = key.split('-').map(Number);
  return new Date(Date.UTC(y, m - 1, d + days)).toISOString().slice(0, 10);
}

export function summarizeProgress(input: ProgressInput): ProgressSummary {
  const nowMs = input.now.getTime();
  let dueNow = 0;
  let learned = 0;
  let longTerm = 0;
  const levels = new Map<string, number>();

  for (const c of input.cards) {
    const interval = c.interval_days ?? 0;
    if (c.next_review_date && Date.parse(c.next_review_date) <= nowMs) dueNow += 1;
    if (interval >= 1) learned += 1;
    if (interval >= LONG_TERM_DAYS) longTerm += 1;
    if (c.cefr) levels.set(c.cefr, (levels.get(c.cefr) ?? 0) + 1);
  }

  const today = dayKey(input.now, input.timeZone);
  const keys = Array.from({ length: 7 }, (_, i) => shiftKey(today, i - 6));
  const counts = new Map(keys.map((k) => [k, 0]));
  for (const r of input.reviews) {
    const t = Date.parse(r.created_at);
    if (Number.isNaN(t)) continue;
    const k = dayKey(new Date(t), input.timeZone);
    if (counts.has(k)) counts.set(k, counts.get(k)! + 1);
  }
  const activity = keys.map((k) => ({
    date: k,
    label: WEEKDAYS[new Date(`${k}T12:00:00Z`).getUTCDay()],
    count: counts.get(k)!,
  }));

  return {
    inLearning: input.cards.length,
    dueNow,
    learned,
    longTerm,
    lessonsCompleted: input.lessonsCompleted,
    byLevel: (CEFR_ORDER as readonly string[]).filter((l) => levels.has(l)).map((l) => ({ level: l, count: levels.get(l)! })),
    activity,
    activeDays: activity.filter((d) => d.count > 0).length,
    reviews7: activity.reduce((s, d) => s + d.count, 0),
  };
}

/**
 * Активність для «Сьогодні» (баг 2026-10-20): графік «Останні 7 днів» і 🔥 рахували лише картки
 * (user_progress.last_reviewed_at — лише останнє повторення кожного слова) і дні в UTC.
 * Тепер — будь-яке навчання: події уроків, вправ, повторень, читання, говоріння (analytics_events)
 * і історія повторень карток (srs_reviews); дні — у часовому поясі користувача.
 */
export const LEARNING_EVENTS = [
  'lesson_completed', 'exercise_completed', 'review_completed', 'reading_completed', 'speaking_completed', 'conversation_completed',
] as const;

/** Насиченість клітинки графіка за кількістю дій за день: 0 — нічого, 4 — дуже активно. */
export function activityLevel(count: number): 0 | 1 | 2 | 3 | 4 {
  if (count <= 0) return 0;
  if (count <= 5) return 1;
  if (count <= 15) return 2;
  if (count <= 30) return 3;
  return 4;
}

/** Останні 7 днів (сьогодні — останній) з кількістю навчальних дій і рівнем насиченості. */
export function activityWeek(
  timestamps: ReadonlyArray<string>,
  now: Date,
  timeZone?: string | null,
): Array<DayActivity & { level: 0 | 1 | 2 | 3 | 4 }> {
  const today = dayKey(now, timeZone);
  const keys = Array.from({ length: 7 }, (_, i) => shiftKey(today, i - 6));
  const counts = new Map(keys.map((k) => [k, 0]));
  for (const ts of timestamps) {
    const t = Date.parse(ts);
    if (Number.isNaN(t)) continue;
    const k = dayKey(new Date(t), timeZone);
    if (counts.has(k)) counts.set(k, counts.get(k)! + 1);
  }
  return keys.map((k) => ({
    date: k,
    label: WEEKDAYS[new Date(`${k}T12:00:00Z`).getUTCDay()],
    count: counts.get(k)!,
    level: activityLevel(counts.get(k)!),
  }));
}

/**
 * Серія днів поспіль із навчанням (🔥): рахуємо від сьогодні назад; якщо сьогодні ще не вчилися —
 * серія не згорає, рахуємо від учора.
 */
export function learningStreak(timestamps: ReadonlyArray<string>, now: Date, timeZone?: string | null): number {
  const days = new Set<string>();
  for (const ts of timestamps) {
    const t = Date.parse(ts);
    if (!Number.isNaN(t)) days.add(dayKey(new Date(t), timeZone));
  }
  let day = dayKey(now, timeZone);
  if (!days.has(day)) day = shiftKey(day, -1);
  let streak = 0;
  while (days.has(day)) {
    streak += 1;
    day = shiftKey(day, -1);
  }
  return streak;
}
