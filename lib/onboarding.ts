/**
 * Онбординг: варіанти відповідей і перевірка введених даних (§44–45, §116).
 * Значення збігаються з CHECK-обмеженнями в міграції M7.
 */
import { CEFR_ORDER } from './situations.ts';
import type { Cefr } from './placement.ts';

export const LEARNING_GOALS = [
  { key: 'daily_life', label: 'Побут і повсякденне життя', hint: 'магазин, житло, транспорт, лікар' },
  { key: 'work', label: 'Робота', hint: 'колеги, зустрічі, листування' },
  { key: 'documents', label: 'Документи й установи', hint: 'MUP, банк, податкова, обрт' },
  { key: 'social', label: 'Спілкування з людьми', hint: 'сусіди, друзі, діти в школі' },
  { key: 'travel', label: 'Подорожі', hint: 'дорога, готель, кордон' },
] as const;

export type LearningGoal = (typeof LEARNING_GOALS)[number]['key'];

/** Щоденна ціль і що входить у заняття (§45) */
export const DAILY_GOALS = [
  { minutes: 5, label: '5 хв', hint: 'повторення + одна коротка вправа' },
  { minutes: 15, label: '15 хв', hint: 'повторення, нове, аудіювання, практика' },
  { minutes: 30, label: '30 хв', hint: 'урок, аудіювання, говоріння, читання' },
  { minutes: 60, label: '60 хв', hint: 'повне заняття з розмовою' },
] as const;

/** Самооцінка рівня; test — чи пропонувати тест після неї */
export const SELF_LEVELS = [
  { key: 'zero', label: 'Починаю з нуля', level: 'A0', test: false },
  { key: 'basics', label: 'Знаю кілька слів і фраз', level: 'A0', test: true },
  { key: 'simple', label: 'Можу просту розмову', level: 'A1', test: true },
  { key: 'confident', label: 'Можу пояснити, що мені треба, у більшості ситуацій', level: 'A2', test: true },
  { key: 'fluent', label: 'Вільно спілкуюся, зокрема на роботі', level: 'B1', test: true },
] as const satisfies ReadonlyArray<{ key: string; label: string; level: Cefr; test: boolean }>;

export interface OnboardingInput {
  goals: unknown;
  dailyGoalMinutes: unknown;
  level: unknown;
  timezone?: unknown;
}

export interface OnboardingData {
  learning_goals: LearningGoal[];
  daily_goal_minutes: number;
  current_level: Cefr;
  timezone: string | null;
}

const TZ_RE = /^[A-Za-z_]+(\/[A-Za-z0-9_+-]+){0,2}$/;
const GOAL_KEYS = LEARNING_GOALS.map((g) => g.key) as readonly string[];

/** Перевіряє відповіді онбордингу. Повертає дані для profiles або текст помилки. */
export function validateOnboarding(input: OnboardingInput): { ok: true; data: OnboardingData } | { ok: false; error: string } {
  if (!Array.isArray(input.goals) || input.goals.length === 0) return { ok: false, error: 'Оберіть хоча б одну мету.' };
  const goals = [...new Set(input.goals)];
  if (!goals.every((g): g is LearningGoal => typeof g === 'string' && GOAL_KEYS.includes(g))) {
    return { ok: false, error: 'Невідома мета.' };
  }
  const minutes = input.dailyGoalMinutes;
  if (typeof minutes !== 'number' || !DAILY_GOALS.some((d) => d.minutes === minutes)) {
    return { ok: false, error: 'Оберіть щоденну ціль.' };
  }
  const level = input.level;
  if (typeof level !== 'string' || !(CEFR_ORDER as readonly string[]).includes(level)) {
    return { ok: false, error: 'Невідомий рівень.' };
  }
  const tz = typeof input.timezone === 'string' && TZ_RE.test(input.timezone) ? input.timezone : null;
  return {
    ok: true,
    data: { learning_goals: goals, daily_goal_minutes: minutes, current_level: level as Cefr, timezone: tz },
  };
}
