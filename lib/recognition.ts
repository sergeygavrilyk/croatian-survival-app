/**
 * Слова «лише впізнавати» (LEARNING_SPEC §18, рішення власника 2026-11-13; реалізація 2026-11-16).
 *
 * «Вживати чи лише впізнавати» — властивість уроку, не слова: `lesson_items.target_skill = 'recognition'`.
 * Нецензурні слова (`register = 'vulgar'`, модуль «18+») — завжди лише впізнавати.
 * Таке слово людина бачить, чує, вибирає з варіантів, повторює картками («Знаю / Не знаю»), але
 * не пише й не каже сама: в уроці — без «Напишіть» і «Скажіть уголос», у тренажері — поза «Написати».
 *
 * Логіка без бази; тести — lib/recognition.test.ts. Головна перевірка — під час збирання контенту
 * (SQL-тест supabase/tests/recognition_words.test.sql), тут — запобіжник на екрані.
 */

export const RECOGNITION_SKILL = 'recognition';

/** Вправи, де людина сама пише чи каже слово: для слів «лише впізнавати» їх не показуємо. */
export const PRODUCTION_EXERCISE_TYPES: readonly string[] = ['type_answer', 'speaking'];

export function isProductionExercise(exerciseType: string | null | undefined): boolean {
  return !!exerciseType && PRODUCTION_EXERCISE_TYPES.includes(exerciseType);
}

export interface LessonItemLink {
  item_type: string;
  item_id: string;
  target_skill?: string | null;
}

/** Слова уроку, які в ньому лише впізнають. */
export function recognitionLexemeIds(items: readonly LessonItemLink[]): Set<string> {
  return new Set(items.filter((i) => i.item_type === 'lexeme' && i.target_skill === RECOGNITION_SKILL).map((i) => i.item_id));
}

/** Слова для впізнавання: текст без регістру, діакритики й розділових знаків — послідовність слів. */
function tokens(text: string | null | undefined): string[] {
  return (text ?? '')
    .toLowerCase()
    .replace(/đ/g, 'd')
    .normalize('NFD')
    .replace(/\p{M}/gu, '')
    .split(/[^\p{L}\p{N}]+/u)
    .filter(Boolean);
}

/** Чи є у тексті слово або сталий вираз (цілими словами, без діакритики й регістру). */
export function containsLemma(text: string | null | undefined, lemma: string | null | undefined): boolean {
  const hay = tokens(text);
  const needle = tokens(lemma);
  if (needle.length === 0 || hay.length < needle.length) return false;
  for (let i = 0; i + needle.length <= hay.length; i++) {
    if (needle.every((t, j) => hay[i + j] === t)) return true;
  }
  return false;
}

export interface ExerciseLike {
  id: string;
  exercise_type: string;
  correct_answer?: string | null;
  lexeme_id?: string | null;
}

/**
 * Прибрати з уроку «Напишіть» і «Скажіть уголос» для слів «лише впізнавати»: вправа прив'язана до слова
 * (`exercises.lexeme_id`) або її відповідь містить це слово чи вираз. Решта вправ — у тому самому порядку.
 */
export function withoutProductionFor<T extends ExerciseLike>(
  exercises: readonly T[],
  recognition: ReadonlyArray<{ id: string; lemma: string }>,
): T[] {
  if (recognition.length === 0) return [...exercises];
  const ids = new Set(recognition.map((r) => r.id));
  return exercises.filter((e) => {
    if (!isProductionExercise(e.exercise_type)) return true;
    if (e.lexeme_id && ids.has(e.lexeme_id)) return false;
    return !recognition.some((r) => containsLemma(e.correct_answer, r.lemma));
  });
}

/**
 * Слова, які людина лише впізнає (для тренажера «Написати»): нецензурні, а також ті, що в опублікованих
 * уроках трапляються тільки з `target_skill = 'recognition'`. Якщо хоч один урок вчить слово вживати — його
 * можна писати.
 */
export function recognitionOnlyIds(
  links: ReadonlyArray<{ item_id: string; target_skill?: string | null }>,
  lexemes: ReadonlyArray<{ id: string; register?: unknown }> = [],
): Set<string> {
  const recognized = new Set<string>();
  const productive = new Set<string>();
  for (const l of links) (l.target_skill === RECOGNITION_SKILL ? recognized : productive).add(l.item_id);
  const out = new Set([...recognized].filter((id) => !productive.has(id)));
  for (const l of lexemes) if (l.register === 'vulgar') out.add(l.id);
  return out;
}
