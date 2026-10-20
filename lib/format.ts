/** Українські форми множини: pluralUk(5, ['фраза', 'фрази', 'фраз']) → «фраз». */
export function pluralUk(n: number, forms: readonly [string, string, string]): string {
  const abs = Math.abs(Math.trunc(n));
  const mod10 = abs % 10;
  const mod100 = abs % 100;
  if (mod10 === 1 && mod100 !== 11) return forms[0];
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return forms[1];
  return forms[2];
}

/** «9 фраз», «1 діалог». */
export function countUk(n: number, forms: readonly [string, string, string]): string {
  return `${n} ${pluralUk(n, forms)}`;
}

/** Частина мови для словника — українською (у базі англійською: noun, verb…). Невідома / «word» → null (не показуємо). */
const POS_UK: Record<string, string> = {
  noun: 'іменник', verb: 'дієслово', adjective: 'прикметник', adverb: 'прислівник', pronoun: 'займенник',
  preposition: 'прийменник', conjunction: 'сполучник', particle: 'частка', interjection: 'вигук',
  number: 'числівник', numeral: 'числівник', phrase: 'вираз', chunk: 'вираз', formulaic: 'вираз', collocation: 'вираз',
};

export function posLabelUk(pos: string | null | undefined): string | null {
  return pos ? POS_UK[pos.trim().toLowerCase()] ?? null : null;
}

/**
 * Пошуковий рядок словника для ilike у PostgREST (.or(...)): без символів, що ламають фільтр
 * (кома, дужки, лапки, %, _, *, \). Апостроф (' ’ ʼ) → «_» (будь-який один символ): «комп'ютер» знайде й «комп’ютер».
 * Порожній після очищення → null (показуємо весь словник).
 */
export function dictionarySearchTerm(query: string): string | null {
  const term = query
    .replace(/[,()"%_*\\]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim()
    .slice(0, 60)
    .replace(/['’ʼ]/g, '_');
  return term.replace(/_/g, '').trim().length > 0 ? term : null;
}
