/**
 * Тест рівня (§59): оцінка відповідей. Чиста логіка — рахується на сервері.
 * Результат — завжди «оцінка застосунку», не офіційний сертифікат CEFR.
 */
import { CEFR_ORDER } from './situations.ts';

export type Cefr = (typeof CEFR_ORDER)[number];
export type Confidence = 'low' | 'medium' | 'high';

export interface PlacementItem {
  id: string;
  cefr: string;
  skill: string;
  correct_index: number;
}

export interface PlacementAnswer {
  item_id: string;
  /** Обраний варіант; null — «Не знаю» */
  chosen: number | null;
}

export interface LevelScore {
  correct: number;
  total: number;
}

export interface PlacementResult {
  estimated: Cefr;
  recommendedStart: Cefr;
  confidence: Confidence;
  scoreByLevel: Record<string, LevelScore>;
  skillProfile: Record<string, LevelScore>;
  answers: Array<{ item_id: string; chosen: number | null; correct: boolean }>;
}

/** Рівень «пройдено», якщо правильно щонайменше 75 % (3 з 4, 6 з 8) */
export const PASS_RATIO = 0.75;
/** Найвищий рівень, з якого можна почати (B2 — верхній рівень програми) */
export const MAX_START: Cefr = 'B2';

const rank = (level: string) => (CEFR_ORDER as readonly string[]).indexOf(level);
const isCefr = (level: string): level is Cefr => rank(level) >= 0;

/** Зупиняти тест після рівня, якщо правильно не більше чверті: далі буде лише складніше. */
export function shouldStopAfterLevel(score: LevelScore): boolean {
  return score.total > 0 && score.correct / score.total <= 0.25;
}

export function scorePlacement(items: ReadonlyArray<PlacementItem>, answers: ReadonlyArray<PlacementAnswer>): PlacementResult {
  const byItem = new Map(answers.map((a) => [a.item_id, a.chosen]));
  const scoreByLevel: Record<string, LevelScore> = {};
  const skillProfile: Record<string, LevelScore> = {};
  const scored: PlacementResult['answers'] = [];
  let answered = 0;

  for (const item of items) {
    if (!isCefr(item.cefr)) continue;
    const chosen = byItem.has(item.id) ? byItem.get(item.id)! : null;
    if (chosen !== null && chosen !== undefined) answered += 1;
    const correct = chosen === item.correct_index;
    scored.push({ item_id: item.id, chosen: chosen ?? null, correct });
    (scoreByLevel[item.cefr] ??= { correct: 0, total: 0 }).total += 1;
    (skillProfile[item.skill] ??= { correct: 0, total: 0 }).total += 1;
    if (correct) {
      scoreByLevel[item.cefr].correct += 1;
      skillProfile[item.skill].correct += 1;
    }
  }

  const levels = Object.keys(scoreByLevel).filter(isCefr).sort((a, b) => rank(a) - rank(b));
  const passed = (l: string) => scoreByLevel[l].correct / scoreByLevel[l].total >= PASS_RATIO;

  // Найвищий рівень, до якого всі рівні поспіль пройдено
  let highest: Cefr | null = null;
  for (const l of levels) {
    if (!passed(l)) break;
    highest = l;
  }
  const firstFailed = levels.find((l) => !passed(l));
  const passedAboveFail = firstFailed !== undefined && levels.some((l) => rank(l) > rank(firstFailed) && passed(l));

  const estimated: Cefr = highest ?? 'A0';
  let recommendedStart: Cefr = highest ? CEFR_ORDER[Math.min(rank(highest) + 1, CEFR_ORDER.length - 1)] : 'A0';
  if (rank(recommendedStart) > rank(MAX_START)) recommendedStart = MAX_START;

  let confidence: Confidence;
  if (answered < 4 || passedAboveFail) confidence = 'low';
  else if (firstFailed === undefined || shouldStopAfterLevel(scoreByLevel[firstFailed])) confidence = 'high';
  else confidence = 'medium';

  return { estimated, recommendedStart, confidence, scoreByLevel, skillProfile, answers: scored };
}
