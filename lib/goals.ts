/**
 * Мета навчання → модулі, з яких середина й фінал рівня беруть до ⅓ завдань (рішення власника 2026-11-07).
 * Кількість завдань і поділ за навичками від мети не залежать — лише з яких модулів частина завдань.
 * Номер модуля = modules.order_index у рівні. A2 — 14 тематичних модулів A2 v2 (2026-11-15).
 */
import type { LearningGoal } from './onboarding.ts';
import type { LevelCode } from './levels.ts';

/** Рівень → модулі мети. Рівня немає в таблиці — завдання рівномірно з усіх модулів (новий рівень — лише дописати дані). */
type LevelModules = Partial<Record<LevelCode, readonly number[]>>;

export const GOAL_MODULES = {
  daily_life: { A0: [6, 7, 8], A1: [2, 3, 4, 5], A2: [6, 7, 8, 9] },
  work: { A0: [], A1: [6, 7], A2: [5] },
  documents: { A0: [10], A1: [7, 12], A2: [6, 8, 12] },
  social: { A0: [2, 5], A1: [9, 12], A2: [4, 10, 13] },
  travel: { A0: [7, 9, 10], A1: [4, 10, 11], A2: [1, 11] },
  study: { A0: [2], A1: [12], A2: [2] },
} satisfies Record<LearningGoal, LevelModules>;

/** Частка завдань середини / фіналу з модулів мети */
export const GOAL_SHARE = 1 / 3;

/** Модулі рівня для мет користувача (без повторів, за зростанням); порожньо — завдання рівномірно з усіх модулів. */
export function goalModules(goals: readonly string[], level: string): number[] {
  const out = new Set<number>();
  for (const g of goals) {
    const map: LevelModules | undefined = GOAL_MODULES[g as LearningGoal];
    for (const m of map?.[level as LevelCode] ?? []) out.add(m);
  }
  return [...out].sort((a, b) => a - b);
}
