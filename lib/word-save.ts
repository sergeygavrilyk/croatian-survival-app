/**
 * Слово → у повторення (тренажер): спільна логіка для словника і читання. Без БД.
 * Нове слово стає в чергу «на сьогодні» (interval 0); уже збережене не скидаємо (ignoreDuplicates).
 */

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/** Чи схоже значення на id запису (uuid). */
export function isUuid(value: unknown): value is string {
  return typeof value === 'string' && UUID_RE.test(value);
}

export interface NewWordProgress {
  user_id: string;
  lexeme_id: string;
  interval_days: 0;
  repetition_count: 0;
  next_review_date: string;
}

/** Рядок user_progress для нового слова: повторити сьогодні. */
export function newWordProgress(userId: string, lexemeId: string, now: Date): NewWordProgress {
  return {
    user_id: userId,
    lexeme_id: lexemeId,
    interval_days: 0,
    repetition_count: 0,
    next_review_date: now.toISOString(),
  };
}

/** До `max` прикладів слова з поля lexemes.examples (jsonb): лише непорожні рядки, без повторів. */
export function wordExamples(raw: unknown, max = 2): string[] {
  if (!Array.isArray(raw)) return [];
  const out: string[] = [];
  for (const item of raw) {
    if (typeof item !== 'string') continue;
    const text = item.replace(/\s+/g, ' ').trim();
    if (text && !out.includes(text)) out.push(text);
    if (out.length >= max) break;
  }
  return out;
}
