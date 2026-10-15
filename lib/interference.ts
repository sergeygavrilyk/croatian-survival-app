/**
 * Типові помилки українців (§19 ТЗ «Ukrainian Interference Engine»). Чиста логіка без БД;
 * тести — interference.test.ts. Каталог — таблиця linguistic_errors (M14), контент — scripts/interference_data.py.
 *
 * Де використовується:
 *  - урок: картка «Українці часто помиляються» на етапі граматики (помилки теми граматики й слів уроку);
 *  - «Практика» → «Помилки» → «Типові помилки»: вправа «Яке речення правильне?».
 *    Неправильна відповідь додає помилку в особисті (user_errors) — вона повториться в «Моїх помилках».
 */

export const INTERFERENCE_CATEGORIES = [
  'cases', 'gender', 'aspect', 'word_order', 'prepositions', 'false_friends',
  'pronunciation', 'verb_patterns', 'plural', 'articles', 'stress', 'collocations',
] as const;
export type InterferenceCategory = (typeof INTERFERENCE_CATEGORIES)[number];

export const CATEGORY_LABEL: Record<InterferenceCategory, string> = {
  cases: 'Відмінки',
  gender: 'Рід',
  aspect: 'Вид дієслова',
  word_order: 'Порядок слів',
  prepositions: 'Прийменники',
  false_friends: 'Оманливі слова',
  pronunciation: 'Вимова',
  verb_patterns: 'Дієслівні конструкції',
  plural: 'Множина',
  articles: 'Артиклі',
  stress: 'Наголос',
  collocations: 'Сталі сполучення',
};

export interface TypicalError {
  id: string;
  code: string;
  category: string;
  cefr: string;
  title_ua: string;
  incorrect_text: string;
  correct_text: string;
  explanation_ua: string;
  examples: Array<{ hr: string; ua: string }>;
  grammar_topic_id?: string | null;
  lexeme_id?: string | null;
}

export function isCategory(v: unknown): v is InterferenceCategory {
  return typeof v === 'string' && (INTERFERENCE_CATEGORIES as readonly string[]).includes(v);
}

export function categoryLabel(v: string): string {
  return isCategory(v) ? CATEGORY_LABEL[v] : 'Інше';
}

/** Вимова й наголос: «неправильно / правильно» — підказка кирилицею, а не речення. */
export function isSpoken(category: string): boolean {
  return category === 'pronunciation' || category === 'stress';
}

export function quizQuestion(category: string): string {
  return isSpoken(category) ? 'Як правильно вимовляти?' : 'Яке речення правильне?';
}

/** Тип особистої помилки (user_errors.error_type) для категорії ТЗ. */
export function errorTypeFor(category: string): 'grammar' | 'vocabulary' | 'word_order' | 'pronunciation' {
  if (category === 'word_order') return 'word_order';
  if (category === 'false_friends' || category === 'collocations') return 'vocabulary';
  if (isSpoken(category)) return 'pronunciation';
  return 'grammar';
}

/** Чи можна додати помилку в «Мої помилки» (там вправа — скласти правильне речення з плиток). */
export function canPractiseAsSentence(e: Pick<TypicalError, 'category' | 'correct_text'>): boolean {
  return !isSpoken(e.category) && e.correct_text.trim().split(/\s+/).length >= 2;
}

/** Пояснення для user_errors.explanation_ua (до 300 символів). */
export function shortExplanation(e: Pick<TypicalError, 'title_ua' | 'explanation_ua'>, max = 300): string {
  const full = `${e.title_ua}. ${e.explanation_ua}`;
  return full.length <= max ? full : full.slice(0, max - 1).trimEnd() + '…';
}

/** Перемішування (Фішер — Єйтс); random — для тестів. */
export function shuffle<T>(items: readonly T[], random: () => number = Math.random): T[] {
  const a = [...items];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

/** Два варіанти відповіді в довільному порядку. */
export function quizOptions(e: Pick<TypicalError, 'incorrect_text' | 'correct_text'>, random: () => number = Math.random) {
  return shuffle(
    [
      { text: e.correct_text, correct: true },
      { text: e.incorrect_text, correct: false },
    ],
    random,
  );
}

const LEVEL_ORDER = ['A0', 'A1', 'A2', 'B1', 'B2'];

/** Помилки до рівня користувача включно (невідомий рівень — A1). */
export function upToLevel<T extends Pick<TypicalError, 'cefr'>>(items: readonly T[], level: string | null | undefined): T[] {
  const max = LEVEL_ORDER.indexOf(level && LEVEL_ORDER.includes(level) ? level : 'A1');
  return items.filter((e) => {
    const i = LEVEL_ORDER.indexOf(e.cefr);
    return i >= 0 && i <= max;
  });
}

/**
 * Набір для вправи: спершу ті, яких користувач ще не має в «Моїх помилках», у випадковому порядку;
 * якщо їх мало — доповнюємо рештою. category — лише одна категорія (null — усі).
 */
export function pickQuiz<T extends Pick<TypicalError, 'id' | 'category'>>(
  items: readonly T[],
  opts: { category?: string | null; exclude?: ReadonlySet<string>; size?: number; random?: () => number } = {},
): T[] {
  const size = opts.size ?? 8;
  const random = opts.random ?? Math.random;
  const pool = opts.category ? items.filter((e) => e.category === opts.category) : [...items];
  const fresh = shuffle(pool.filter((e) => !opts.exclude?.has(e.id)), random);
  const seen = shuffle(pool.filter((e) => opts.exclude?.has(e.id)), random);
  return [...fresh, ...seen].slice(0, size);
}

/** Скільки помилок у кожній категорії (у порядку ТЗ, лише непорожні). */
export function countByCategory(items: ReadonlyArray<Pick<TypicalError, 'category'>>): Array<{ category: InterferenceCategory; count: number }> {
  return INTERFERENCE_CATEGORIES.map((category) => ({ category, count: items.filter((e) => e.category === category).length })).filter(
    (c) => c.count > 0,
  );
}

/**
 * Картки для уроку: спершу помилки, пов'язані зі словами уроку (оманливі слова), потім — з темою граматики;
 * без повторів, не більше max.
 */
export function lessonPitfalls<T extends Pick<TypicalError, 'id' | 'code' | 'grammar_topic_id' | 'lexeme_id'>>(
  items: readonly T[],
  grammarIds: readonly string[],
  lexemeIds: readonly string[],
  max = 3,
): T[] {
  const g = new Set(grammarIds);
  const w = new Set(lexemeIds);
  const byCode = (a: T, b: T) => a.code.localeCompare(b.code);
  const forGrammar = items.filter((e) => e.grammar_topic_id && g.has(e.grammar_topic_id)).sort(byCode);
  const forWords = items.filter((e) => e.lexeme_id && w.has(e.lexeme_id)).sort(byCode);
  const out: T[] = [];
  for (const e of [...forWords, ...forGrammar]) {
    if (out.length >= max) break;
    if (!out.some((x) => x.id === e.id)) out.push(e);
  }
  return out;
}

/** Приклади з БД (jsonb) → лише коректні пари. */
export function examplesFrom(v: unknown): Array<{ hr: string; ua: string }> {
  if (!Array.isArray(v)) return [];
  return v
    .filter((x): x is { hr: string; ua: string } => !!x && typeof x === 'object' && typeof (x as { hr?: unknown }).hr === 'string' && typeof (x as { ua?: unknown }).ua === 'string')
    .map(({ hr, ua }) => ({ hr, ua }));
}
