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

// ---------------------------------------------------------------------------
// Без мережі (офлайн, етап 2, 2026-11-16): правильно виправлені помилки — позначка на телефоні
// ---------------------------------------------------------------------------
// Без мережі сторінку «Помилки» віддає кеш застосунку — з тими помилками, що були на момент останнього
// відкриття. Щоб уже правильно виправлена (відповідь чекає в черзі) не трапилась знову, телефон пам'ятає,
// коли її виправили, і ховає, якщо сторінку зібрано раніше. Неправильні не ховаємо: онлайн вони теж
// повертаються одразу. Свіжа сторінка з сервера (зібрана пізніше) показує все, що каже сервер.

/** Скільки пам'ятаємо позначку — стільки ж, скільки дія чекає в черзі (14 днів). */
export const DONE_MARK_MAX_AGE_MS = 14 * 24 * 60 * 60 * 1000;
const DONE_MARK_MAX = 300;
const DONE_PREFIX = 'cs_mistakes_done_';

type MarkStorage = Pick<Storage, 'getItem' | 'setItem'>;

export function doneMarksKey(userId: string): string {
  return `${DONE_PREFIX}${userId}`;
}

/** Розібрати позначки { id помилки: мс }; пошкоджене — порожньо. */
export function parseDoneMarks(raw: string | null | undefined): Record<string, number> {
  if (!raw) return {};
  try {
    const parsed = JSON.parse(raw) as unknown;
    if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) return {};
    const out: Record<string, number> = {};
    for (const [id, at] of Object.entries(parsed as Record<string, unknown>)) {
      if (typeof at === 'number' && Number.isFinite(at)) out[id] = at;
    }
    return out;
  } catch {
    return {};
  }
}

/** Позначити помилку виправленою зараз. Старші за 14 днів позначки прибираємо, не більше 300. */
export function markMistakeDone(storage: MarkStorage | null | undefined, userId: string | null | undefined, errorId: string, now: number = Date.now()): boolean {
  if (!storage || !userId) return false;
  try {
    const marks = parseDoneMarks(storage.getItem(doneMarksKey(userId)));
    marks[errorId] = now;
    const kept = Object.entries(marks)
      .filter(([, at]) => now - at <= DONE_MARK_MAX_AGE_MS)
      .sort((a, b) => b[1] - a[1])
      .slice(0, DONE_MARK_MAX);
    storage.setItem(doneMarksKey(userId), JSON.stringify(Object.fromEntries(kept)));
    return true;
  } catch {
    return false;
  }
}

/** Які помилки сховати: виправлені на телефоні після того, як сторінку зібрав сервер. */
export function hiddenMistakeIds(raw: string | null | undefined, renderedAtMs: number): Set<string> {
  const hidden = new Set<string>();
  if (!Number.isFinite(renderedAtMs)) return hidden;
  for (const [id, at] of Object.entries(parseDoneMarks(raw))) if (at > renderedAtMs) hidden.add(id);
  return hidden;
}
