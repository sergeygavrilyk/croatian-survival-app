/**
 * «Уроки»: вибір рівня з адреси й групування програми (рівень → модулі → юніти → уроки).
 * Без запитів до бази — їх робить app/lessons/page.tsx (Server Component, з 2026-10-21).
 */
import { LEVEL_CODES, type LevelCode } from './levels.ts';

/** Рівень за замовчуванням, як і раніше в client-сторінці. */
export const DEFAULT_LESSONS_LEVEL: LevelCode = 'A0';

/** Рівень з адреси (?level=A1); будь-що інше — A0. */
export function pickLessonsLevel(requested: unknown): LevelCode {
  return typeof requested === 'string' && (LEVEL_CODES as readonly string[]).includes(requested)
    ? (requested as LevelCode)
    : DEFAULT_LESSONS_LEVEL;
}

/** Адреса списку уроків рівня (A0 — без параметра). */
export function lessonsHref(level: string | null | undefined): string {
  const l = pickLessonsLevel(level);
  return l === DEFAULT_LESSONS_LEVEL ? '/lessons' : `/lessons?level=${l}`;
}

/**
 * Згрупувати рядки за батьком (юніти — за модулем, уроки — за юнітом), зберігаючи порядок рядків.
 * Кожен батько з `parentIds` має свій (можливо, порожній) список; рядки чужих батьків відкидаємо.
 */
export function groupByParent<T, K extends keyof T>(
  parentIds: readonly string[],
  rows: readonly T[] | null | undefined,
  parentKey: K,
): Record<string, T[]> {
  const out: Record<string, T[]> = {};
  for (const id of parentIds) out[id] = [];
  for (const row of rows ?? []) {
    const parent = row[parentKey];
    if (typeof parent === 'string' && out[parent]) out[parent].push(row);
  }
  return out;
}
