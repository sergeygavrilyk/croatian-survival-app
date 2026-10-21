/**
 * Вміст уроку для LessonPlayer: збирання з рядків бази (без запитів — їх робить сторінка-сервер,
 * app/(main)/lesson/[id]/page.tsx) і перевірка офлайн-копії (§76).
 * До 2026-10-21 це жило всередині client-сторінки уроку; копія в app/actions/lesson.ts (getLessonData) — видалена.
 */
import { examplesFrom, lessonPitfalls, type TypicalError } from './interference.ts';

export interface LessonWord {
  id: string;
  hr_text: string;
  ua_translation: string;
}

export interface DialogueLine {
  id: string;
  speaker_name: string;
  hr_text: string;
  ua_translation: string;
}

export interface LessonDialogue {
  id: string;
  title_ua: string | null;
  title_hr: string | null;
  situation: string | null;
  lines: DialogueLine[];
}

export interface GrammarRule {
  id: string;
  title_ua: string;
  explanation_ua: string;
  pattern_hr?: string | null;
  examples: Array<{ hr: string; ua: string }>;
}

export interface GrammarTopic {
  id: string;
  title_ua: string;
  title_hr?: string | null;
  description?: string | null;
  rules: GrammarRule[];
}

export interface LessonInfo {
  id: string;
  title_ua: string;
  title_hr: string | null;
  level_code: string | null;
  objectives: string[] | null;
  estimated_minutes: number | null;
}

/** Вправа уроку (як LessonExerciseData у components/lesson/LessonExercise.tsx). */
export interface LessonExerciseRow {
  id: string;
  exercise_type: string;
  question_text: string;
  correct_answer: string;
  options: unknown;
}

export interface LessonContent {
  lesson: LessonInfo;
  words: LessonWord[];
  dialogues: LessonDialogue[];
  grammar: GrammarTopic[];
  exercises: LessonExerciseRow[];
  /** Типові помилки українців для теми граматики й слів уроку (§19); показуємо на етапі «Граматика» */
  pitfalls?: TypicalError[];
}

/** Рядки бази, з яких збирається урок (кожен запит — у page.tsx). */
export interface LessonRows {
  lesson: {
    id: string;
    title_ua: string | null;
    title_hr: string | null;
    level_code: string | null;
    objectives: unknown;
    estimated_minutes: unknown;
  };
  items: ReadonlyArray<{ item_type: string; item_id: string }>;
  lexemes: ReadonlyArray<{ id: string; lemma: string; ukrainian_translation: string | null }>;
  exercises: ReadonlyArray<LessonExerciseRow>;
  conversations: ReadonlyArray<{ id: string; title_ua: string | null; title_hr: string | null; situation: string | null }>;
  turns: ReadonlyArray<DialogueLine & { conversation_id: string }>;
  grammar: ReadonlyArray<{
    id: string;
    title_ua: string;
    title_hr?: string | null;
    description?: string | null;
    rules?: ReadonlyArray<GrammarRule & { order_index?: number | null }> | null;
  }>;
  /** linguistic_errors (сирі: examples — jsonb) */
  errors: ReadonlyArray<Omit<TypicalError, 'examples'> & { examples: unknown }>;
}

export type LessonItemIds = { lexemeIds: string[]; exerciseIds: string[]; grammarIds: string[] };

/** id елементів уроку за типом, у порядку lesson_items.order_index (items уже впорядковані). */
export function lessonItemIds(items: LessonRows['items']): LessonItemIds {
  const idsOf = (type: string) => items.filter((i) => i.item_type === type).map((i) => i.item_id);
  return { lexemeIds: idsOf('lexeme'), exerciseIds: idsOf('exercise'), grammarIds: idsOf('grammar') };
}

/** Фільтр PostgREST `.or(...)` для типових помилок уроку; null — у уроці немає ні граматики, ні слів. */
export function pitfallsFilter({ grammarIds, lexemeIds }: Pick<LessonItemIds, 'grammarIds' | 'lexemeIds'>): string | null {
  const parts = [
    grammarIds.length ? `grammar_topic_id.in.(${grammarIds.join(',')})` : null,
    lexemeIds.length ? `lexeme_id.in.(${lexemeIds.join(',')})` : null,
  ].filter(Boolean);
  return parts.length ? parts.join(',') : null;
}

/** Зберегти порядок елементів уроку (lesson_items.order_index), а не порядок відповіді бази. */
export function inOrder<T extends { id: string }>(ids: readonly string[], rows: readonly T[] | null | undefined): T[] {
  const byId = new Map((rows ?? []).map((r) => [r.id, r]));
  return ids.map((id) => byId.get(id)).filter((r): r is T => r !== undefined);
}

function stringList(v: unknown): string[] | null {
  return Array.isArray(v) ? v.filter((x): x is string => typeof x === 'string' && x.trim() !== '') : null;
}

/** Рядки бази → вміст уроку для LessonPlayer. */
export function buildLessonContent(rows: LessonRows): LessonContent {
  const { lexemeIds, exerciseIds, grammarIds } = lessonItemIds(rows.items);

  const lesson: LessonInfo = {
    id: rows.lesson.id,
    title_ua: rows.lesson.title_ua ?? 'Урок',
    title_hr: rows.lesson.title_hr ?? null,
    level_code: rows.lesson.level_code ?? null,
    objectives: stringList(rows.lesson.objectives),
    estimated_minutes: typeof rows.lesson.estimated_minutes === 'number' ? rows.lesson.estimated_minutes : null,
  };

  const words: LessonWord[] = inOrder(
    lexemeIds,
    rows.lexemes.map((l) => ({ id: l.id, hr_text: l.lemma, ua_translation: l.ukrainian_translation ?? '' })),
  );

  const dialogues: LessonDialogue[] = rows.conversations
    .map((c) => ({
      id: c.id,
      title_ua: c.title_ua,
      title_hr: c.title_hr,
      situation: c.situation,
      lines: rows.turns
        .filter((t) => t.conversation_id === c.id)
        .map(({ id, speaker_name, hr_text, ua_translation }) => ({ id, speaker_name, hr_text, ua_translation })),
    }))
    .filter((d) => d.lines.length > 0);

  const grammar: GrammarTopic[] = inOrder(
    grammarIds,
    rows.grammar.map((topic) => ({
      id: topic.id,
      title_ua: topic.title_ua,
      title_hr: topic.title_hr ?? null,
      description: topic.description ?? null,
      rules: [...(topic.rules ?? [])]
        .sort((a, b) => (a.order_index ?? 0) - (b.order_index ?? 0))
        .map(({ id, title_ua, explanation_ua, pattern_hr, examples }) => ({
          id,
          title_ua,
          explanation_ua,
          pattern_hr: pattern_hr ?? null,
          examples: examplesFrom(examples),
        })),
    })),
  );

  const exercises = inOrder(exerciseIds, rows.exercises);

  const pitfalls = lessonPitfalls(
    rows.errors.map((r) => ({ ...r, examples: examplesFrom(r.examples) })),
    grammarIds,
    lexemeIds,
    2,
  );

  return { lesson, words, dialogues, grammar, exercises, pitfalls };
}

/** Чи схожа офлайн-копія на вміст уроку (стара копія іншого формату — відкидаємо, а не ламаємо урок). */
export function isLessonContent(v: unknown): v is LessonContent {
  if (!v || typeof v !== 'object') return false;
  const c = v as Partial<Record<keyof LessonContent, unknown>>;
  const lesson = c.lesson as Partial<LessonInfo> | undefined;
  return (
    !!lesson &&
    typeof lesson === 'object' &&
    typeof lesson.id === 'string' &&
    typeof lesson.title_ua === 'string' &&
    Array.isArray(c.words) &&
    Array.isArray(c.dialogues) &&
    Array.isArray(c.grammar) &&
    Array.isArray(c.exercises) &&
    (c.pitfalls === undefined || Array.isArray(c.pitfalls))
  );
}
