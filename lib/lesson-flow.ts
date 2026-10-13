/**
 * Сценарій уроку (екран components/LessonPlayer.tsx). Чиста логіка без БД; тести — lesson-flow.test.ts.
 *
 * Урок іде етапами: вступ → слова → діалоги → граматика (якщо є) → вправи → підсумок.
 * Вправи — від упізнавання до власного мовлення (вибір → вставити → написати → скласти →
 * аудіювання → сказати вголос). Неправильну вправу повторюємо один раз у кінці черги.
 */

export type LessonStage = 'intro' | 'words' | 'dialogue' | 'grammar' | 'practice' | 'summary';

export const EXERCISE_TYPES = [
  'multiple_choice',
  'fill_in_the_blank',
  'type_answer',
  'sentence_builder',
  'listening',
  'speaking',
] as const;
export type ExerciseType = (typeof EXERCISE_TYPES)[number];

export function isExerciseType(t: string): t is ExerciseType {
  return (EXERCISE_TYPES as readonly string[]).includes(t);
}

/** Етапи уроку: порожні пропускаємо (немає граматики — немає етапу «граматика»). */
export function lessonStages(c: { words: number; dialogues: number; grammar: number; exercises: number }): LessonStage[] {
  const stages: LessonStage[] = ['intro'];
  if (c.words > 0) stages.push('words');
  if (c.dialogues > 0) stages.push('dialogue');
  if (c.grammar > 0) stages.push('grammar');
  if (c.exercises > 0) stages.push('practice');
  stages.push('summary');
  return stages;
}

/**
 * Порядок вправ: за типом (див. EXERCISE_TYPES), у межах типу — як в уроці.
 * Невідомі типи (старий застосунок / нові дані) пропускаємо, щоб урок не «зависав».
 */
export function orderExercises<T extends { exercise_type: string }>(exercises: readonly T[]): T[] {
  return exercises
    .map((ex, i) => ({ ex, i }))
    .filter(({ ex }) => isExerciseType(ex.exercise_type))
    .sort((a, b) => {
      const ra = EXERCISE_TYPES.indexOf(a.ex.exercise_type as ExerciseType);
      const rb = EXERCISE_TYPES.indexOf(b.ex.exercise_type as ExerciseType);
      return ra - rb || a.i - b.i;
    })
    .map(({ ex }) => ex);
}

// ---------------------------------------------------------------- черга вправ
export interface PracticeState {
  /** id вправ, що лишилися (перша — поточна) */
  queue: string[];
  /** вправи, які вже раз поверталися в кінець черги */
  retried: string[];
  /** правильно з першої спроби */
  firstTry: string[];
  /** зрештою правильно (з першої або другої спроби) */
  solved: string[];
  /** пропущені (напр. «скажіть уголос», коли мікрофон недоступний) */
  skipped: string[];
  /** скільки всього різних вправ */
  total: number;
}

export function startPractice(ids: readonly string[]): PracticeState {
  const unique = [...new Set(ids)];
  return { queue: unique, retried: [], firstTry: [], solved: [], skipped: [], total: unique.length };
}

export type PracticeOutcome = 'correct' | 'wrong' | 'skipped';

/** Відповідь на поточну вправу. Неправильна вперше — повториться в кінці черги; вдруге — ідемо далі. */
export function answerCurrent(state: PracticeState, outcome: PracticeOutcome): PracticeState {
  const [current, ...rest] = state.queue;
  if (current === undefined) return state;
  const retried = state.retried.includes(current);
  if (outcome === 'correct') {
    return {
      ...state,
      queue: rest,
      solved: [...state.solved, current],
      firstTry: retried ? state.firstTry : [...state.firstTry, current],
    };
  }
  if (outcome === 'skipped') {
    return { ...state, queue: rest, skipped: [...state.skipped, current] };
  }
  if (!retried) {
    return { ...state, queue: [...rest, current], retried: [...state.retried, current] };
  }
  return { ...state, queue: rest };
}

/** Скільки різних вправ уже закрито (для смуги прогресу). */
export function practiceDone(state: PracticeState): number {
  return state.total - new Set(state.queue).size;
}

/** Чи поточна вправа — повтор після помилки. */
export function isRetry(state: PracticeState): boolean {
  return state.queue.length > 0 && state.retried.includes(state.queue[0]);
}

// ---------------------------------------------------------------- дрібниці для екрана
const CYRILLIC = /[Ѐ-ӿ]/;

/** Варіант відповіді українською (а не хорватською) — щоб не позначати його lang="hr". */
export function isUkrainian(text: string): boolean {
  return CYRILLIC.test(text);
}

/** Плитки для «склади речення» / «аудіювання»: ключ — позиція, тож однакові слова теж працюють. */
export function tilesFrom(options: unknown): Array<{ key: string; text: string }> {
  if (!Array.isArray(options)) return [];
  return options.filter((o): o is string => typeof o === 'string' && o.trim() !== '').map((text, i) => ({ key: `${i}:${text}`, text }));
}

/** Варіанти вибору: лише рядки, без повторів. */
export function choicesFrom(options: unknown): string[] {
  if (!Array.isArray(options)) return [];
  return [...new Set(options.filter((o): o is string => typeof o === 'string' && o.trim() !== ''))];
}

/** Орієнтовна тривалість, якщо в уроці її не вказано: ~1 хв на 2 слова, діалог, вправу. */
export function estimateMinutes(c: { words: number; turns: number; exercises: number }): number {
  return Math.max(5, Math.round(c.words * 0.25 + c.turns * 0.2 + c.exercises * 0.5));
}
