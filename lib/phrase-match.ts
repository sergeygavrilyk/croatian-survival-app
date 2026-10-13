/**
 * Пошук готового перекладу в перевіреному контенті застосунку (чиста логіка, без БД).
 *
 * «Мені потрібно сказати…»: перш ніж питати AI, шукаємо українську фразу серед
 * опублікованих фраз (phrases) і слів (lexemes). Знайшли — показуємо перевірений
 * переклад: швидко, безкоштовно і без помилок AI. Тести — phrase-match.test.ts.
 */

export interface VerifiedCandidate {
  /** Хорватський текст (phrases.text_hr або lexemes.lemma) */
  hr: string;
  /** Український переклад з бази; може мати кілька значень через «;» або «/» */
  ua: string;
  kind: 'phrase' | 'lexeme';
  /** Менше — частіше вживане (lexemes.frequency_rank); фразам — 0 */
  rank?: number | null;
}

export interface VerifiedMatch {
  hr: string;
  ua: string;
  kind: 'phrase' | 'lexeme';
}

/** Нормалізація українського тексту для порівняння: регістр, апострофи, розділові знаки, пробіли. */
export function normalizeUa(text: string): string {
  return text
    .toLowerCase()
    .replace(/[’ʼ`´']/g, '’')
    .replace(/\([^)]*\)/g, ' ')            // «прошу (вам)» → «прошу»
    .replace(/[.,!?…:;«»"„“”()\[\]—–-]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

/** Окремі значення перекладу: «допоможіть!; на допомогу!» → ['допоможіть', 'на допомогу']. */
export function translationAlternatives(ua: string): string[] {
  return ua
    .split(/[;/|]/)
    .map(normalizeUa)
    .filter((s) => s.length > 0);
}

/**
 * Точний збіг запиту з одним зі значень перекладу.
 * Пріоритет: фраза → слово з меншим frequency_rank. Часткових збігів не повертаємо:
 * краще запитати AI, ніж показати переклад іншої фрази.
 */
export function findVerifiedMatch(query: string, candidates: VerifiedCandidate[]): VerifiedMatch | null {
  const q = normalizeUa(query);
  if (!q) return null;
  const hits = candidates.filter((c) => c.hr.trim() && translationAlternatives(c.ua).includes(q));
  if (hits.length === 0) return null;
  hits.sort((a, b) => {
    if (a.kind !== b.kind) return a.kind === 'phrase' ? -1 : 1;
    return (a.rank ?? Number.MAX_SAFE_INTEGER) - (b.rank ?? Number.MAX_SAFE_INTEGER);
  });
  const best = hits[0];
  return { hr: best.hr.trim(), ua: best.ua, kind: best.kind };
}

/**
 * Найдовше слово запиту — для попереднього відбору кандидатів у БД (ilike '%слово%').
 * Екрануємо % і _, щоб текст користувача не став шаблоном.
 */
export function searchKeyword(query: string): string | null {
  const words = normalizeUa(query).split(' ').filter((w) => w.length >= 2);
  if (words.length === 0) return null;
  const longest = words.reduce((a, b) => (b.length > a.length ? b : a));
  return longest.replace(/[\\%_]/g, (c) => '\\' + c);
}

/** Ключ кешу перекладів: нормалізований текст, не довший за 300 символів. */
export function cacheKey(query: string): string {
  return normalizeUa(query).slice(0, 300);
}
