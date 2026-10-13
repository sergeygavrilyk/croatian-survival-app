/**
 * «Мої помилки» — повторення помилок з рольової гри (і пізніше — з говоріння й письма).
 * Чиста логіка без БД; тести — mistakes.test.ts.
 *
 * Вправа: «Ви сказали: <помилка>» → скласти правильний варіант із плиток.
 * Серед плиток — слова правильної відповіді + неправильні слова, які сказав сам користувач
 * (найкорисніші «пастки»: jedna/kava vs jednu/kavu).
 *
 * Розклад: помилка вважається засвоєною після двох правильних відповідей у різні дні
 * (перша правильна → наступна перевірка завтра; помилка → знову сьогодні).
 */

export const MASTERY_STREAK = 2;
export const SESSION_SIZE = 10;
const MAX_DISTRACTORS = 3;

export interface MistakeState {
  correctStreak: number;
  reviewCount: number;
}

export interface MistakeSchedule extends MistakeState {
  nextReviewAt: Date;
  resolvedAt: Date | null;
}

const DIACRITICS: Record<string, string> = { č: 'c', ć: 'c', đ: 'd', š: 's', ž: 'z' };

/** Для порівняння: нижній регістр, без розділових знаків і зайвих пробілів. */
export function normalizeSentence(s: string): string {
  return s.toLowerCase().replace(/[^\p{L}\p{N}]+/gu, ' ').trim();
}

const foldDiacritics = (s: string) => s.replace(/[čćđšž]/g, (c) => DIACRITICS[c]);

export type SentenceVerdict = 'exact' | 'diacritics' | 'wrong';

/** Порівняння складеного речення з правильним: розділові знаки й регістр не важать. */
export function checkSentence(answer: string, expected: string): SentenceVerdict {
  const a = normalizeSentence(answer);
  const e = normalizeSentence(expected);
  if (!a) return 'wrong';
  if (a === e) return 'exact';
  if (foldDiacritics(a) === foldDiacritics(e)) return 'diacritics';
  return 'wrong';
}

/** Плитки слів правильної відповіді (як написано, з розділовими знаками). */
export function answerTiles(corrected: string): string[] {
  return corrected.trim().split(/\s+/).filter(Boolean);
}

/**
 * Пастки: слова з помилкової репліки, яких немає в правильній відповіді
 * («jedna kava molim» vs «Jednu kavu, molim.» → jedna, kava).
 */
export function distractorTiles(original: string, corrected: string): string[] {
  const correctWords = new Set(answerTiles(corrected).map(normalizeSentence));
  const out: string[] = [];
  for (const raw of original.trim().split(/\s+/)) {
    const w = raw.replace(/[^\p{L}\p{N}]+/gu, '');
    const n = normalizeSentence(w);
    if (!n || correctWords.has(n) || out.some((x) => normalizeSentence(x) === n)) continue;
    out.push(w.toLowerCase());
    if (out.length >= MAX_DISTRACTORS) break;
  }
  return out;
}

/** Перемішування (Фішер — Єйтс); random — для тестів. */
export function shuffleTiles<T>(items: readonly T[], random: () => number = Math.random): T[] {
  const a = [...items];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

/** Наступна перевірка помилки після відповіді. */
export function scheduleMistake(prev: MistakeState, correct: boolean, now: Date = new Date()): MistakeSchedule {
  const reviewCount = prev.reviewCount + 1;
  if (!correct) {
    return { correctStreak: 0, reviewCount, nextReviewAt: new Date(now), resolvedAt: null };
  }
  const correctStreak = prev.correctStreak + 1;
  if (correctStreak >= MASTERY_STREAK) {
    return { correctStreak, reviewCount, nextReviewAt: new Date(now), resolvedAt: new Date(now) };
  }
  const next = new Date(now);
  next.setDate(next.getDate() + 1);
  next.setHours(0, 0, 0, 0); // з початку наступної доби
  return { correctStreak, reviewCount, nextReviewAt: next, resolvedAt: null };
}

/** Чи помилка чекає повторення зараз. */
export function isDue(row: { resolved_at: string | null; next_review_at: string | null }, now: Date = new Date()): boolean {
  if (row.resolved_at) return false;
  return !row.next_review_at || new Date(row.next_review_at).getTime() <= now.getTime();
}
