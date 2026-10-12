/**
 * Прогрес користувача (екран «Профіль»): чиста логіка без БД.
 * Слова: user_progress; активність: srs_reviews; уроки: lesson_progress.
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
