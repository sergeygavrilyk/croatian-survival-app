/**
 * Стан навичок (skill_progress, ТЗ §120 / DATABASE.md) після перевірки рівня — чиста логіка без бази.
 *
 * Рішення власника 2026-11-15:
 *   - бал навички (xp_or_score) — результат цієї навички в останній перевірці рівня (модуль, середина чи фінал), 0–100 %;
 *   - рівень навички (level_estimate) — найвищий рівень, де навичка ≥ 70 % (поріг перевірки) у фінальній перевірці;
 *     рівень не знижується (слабший фінал чи перевірка модуля його не забирають).
 * Навички — з поля skill завдання (listening, reading, interaction, mediation, writing, speaking…);
 * пропущене говоріння не рахується (як у балі перевірки).
 */
import { isLevelCode, levelRank } from './levels.ts';
import type { GradableItem, GradedItem } from './assessment.ts';

export const SKILLS = ['vocabulary', 'grammar', 'reading', 'listening', 'speaking', 'writing', 'interaction', 'mediation'] as const;
export type Skill = (typeof SKILLS)[number];

export function isSkill(v: unknown): v is Skill {
  return typeof v === 'string' && (SKILLS as readonly string[]).includes(v);
}

export interface SkillScore {
  correct: number;
  total: number;
}

/** Бали за навичками перевірки: правильні / усього (без пропущеного говоріння). */
export function skillScores(
  items: ReadonlyArray<Pick<GradableItem, 'id' | 'skill'>>,
  graded: ReadonlyArray<Pick<GradedItem, 'item_id' | 'correct' | 'skipped'>>,
): Map<Skill, SkillScore> {
  const skillOf = new Map(items.map((i) => [i.id, i.skill]));
  const out = new Map<Skill, SkillScore>();
  for (const g of graded) {
    const skill = skillOf.get(g.item_id);
    if (!isSkill(skill) || g.skipped) continue;
    const s = out.get(skill) ?? { correct: 0, total: 0 };
    s.total += 1;
    if (g.correct) s.correct += 1;
    out.set(skill, s);
  }
  return out;
}

export interface SkillProgressRow {
  skill: string;
  level_estimate: string | null;
  xp_or_score: number;
}

/** Вищий з двох рівнів (за порядком LEVEL_CODES); невідомий рівень не враховується. */
export function higherLevel(a: string | null | undefined, b: string | null | undefined): string | null {
  const ok = (x: string | null | undefined): x is string => typeof x === 'string' && isLevelCode(x);
  if (!ok(a)) return ok(b) ? b : null;
  if (!ok(b)) return a;
  return levelRank(b) > levelRank(a) ? b : a;
}

/**
 * Рядки skill_progress після перевірки: бал — останній результат навички; рівень — з фіналу (≥ passRatio), не знижується.
 * existing — теперішні рядки користувача (для рівня, який не можна знизити).
 */
export function skillProgressRows(
  kind: string,
  cefr: string,
  scores: ReadonlyMap<Skill, SkillScore>,
  existing: ReadonlyArray<{ skill: string; level_estimate: string | null }>,
  passRatio = 0.7,
): SkillProgressRow[] {
  const prev = new Map(existing.map((r) => [r.skill, r.level_estimate]));
  const rows: SkillProgressRow[] = [];
  for (const skill of SKILLS) {
    const s = scores.get(skill);
    if (!s || s.total <= 0) continue;
    const ratio = s.correct / s.total;
    const confirmed = kind === 'final' && isLevelCode(cefr) && ratio + 1e-9 >= passRatio ? cefr : null;
    rows.push({
      skill,
      level_estimate: higherLevel(prev.get(skill) ?? null, confirmed),
      xp_or_score: Math.round(ratio * 100),
    });
  }
  return rows;
}
