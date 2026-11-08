/**
 * Мета навчання → модулі, з яких середина й фінал рівня беруть до ⅓ завдань (рішення власника 2026-11-07).
 * Кількість завдань і поділ за навичками від мети не залежать — лише з яких модулів частина завдань.
 * Номер модуля = modules.order_index у рівні. A2 — коли з'являться тематичні модулі (план на погодженні).
 */
import type { LearningGoal } from './onboarding.ts';

export type GoalLevel = 'A0' | 'A1';

export const GOAL_MODULES: Record<LearningGoal, Record<GoalLevel, readonly number[]>> = {
  daily_life: { A0: [6, 7, 8], A1: [2, 3, 4, 5] },
  work: { A0: [], A1: [6, 7] },
  documents: { A0: [10], A1: [7, 12] },
  social: { A0: [2, 5], A1: [9, 12] },
  travel: { A0: [7, 9, 10], A1: [4, 10, 11] },
  study: { A0: [2], A1: [12] },
};

/** Частка завдань середини / фіналу з модулів мети */
export const GOAL_SHARE = 1 / 3;

/** Модулі рівня для мет користувача (без повторів, за зростанням); порожньо — завдання рівномірно з усіх модулів. */
export function goalModules(goals: readonly string[], level: string): number[] {
  if (level !== 'A0' && level !== 'A1') return [];
  const out = new Set<number>();
  for (const g of goals) {
    const map = GOAL_MODULES[g as LearningGoal];
    if (map) for (const m of map[level]) out.add(m);
  }
  return [...out].sort((a, b) => a - b);
}
