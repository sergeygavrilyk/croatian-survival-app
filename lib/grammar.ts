/**
 * «Граматика рівня» (рішення власника 2026-10-27: варіант А — окремий розділ у «Уроках»
 * + «Підсумок граматики» перед фінальною перевіркою рівня, для всіх рівнів).
 * Чиста логіка без бази: групування тем за модулями, стан теми, пошук, вибір вправ.
 * Запити — у lib/grammar-repo-supabase.ts, тести — lib/grammar.test.ts.
 */
import { orderExercises } from './lesson-flow.ts';
import { seededRandom } from './random.ts';
import { shuffle } from './interference.ts';

/** Стан теми для людини: пройдено (була в пройденому уроці) / зараз (у поточному модулі) / попереду. */
export type TopicState = 'done' | 'now' | 'next';

export interface GrammarModuleInput {
  id: string;
  order_index: number;
  title_ua: string;
  title_hr: string | null;
}

export interface GrammarTopicInput {
  id: string;
  title_ua: string;
  title_hr: string | null;
  description: string | null;
  ruleCount: number;
  /** Текст для пошуку: назви правил, шаблони (необов'язково) */
  searchExtra?: string;
}

export interface LevelTopic {
  id: string;
  title_ua: string;
  title_hr: string | null;
  description: string | null;
  ruleCount: number;
  /** У скількох уроках рівня є тема */
  lessonCount: number;
  /** Модуль, де тема з'являється вперше; null — тема рівня без уроку */
  moduleId: string | null;
  state: TopicState;
  /** Нормалізований текст для пошуку (без діакритик, малими) */
  search: string;
}

export interface LevelModuleGroup {
  id: string;
  order: number;
  title_ua: string;
  title_hr: string | null;
  state: TopicState;
  topics: LevelTopic[];
}

export interface LevelGrammar {
  groups: LevelModuleGroup[];
  /** Теми рівня, яких ще немає в жодному уроці (показуємо окремо, наприкінці) */
  unlinked: LevelTopic[];
  total: number;
  done: number;
  /** Поточний модуль людини (перший, де є непройдені уроки); null — усе пройдено або уроків немає */
  currentModuleId: string | null;
}

/** Рядок без діакритик і зайвих пробілів, малими: «Čekam» → «cekam», «đak» → «dak». */
export function normalizeSearch(text: string | null | undefined): string {
  return (text ?? '')
    .toLowerCase()
    .replace(/đ/g, 'd')
    .normalize('NFD')
    .replace(/\p{M}/gu, '')
    .replace(/[’'`]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

/**
 * Зібрати граматику рівня.
 * - `lessonsByModule` — id опублікованих уроків кожного модуля в порядку програми;
 * - `links` — які теми є в яких уроках (lesson_items із item_type = 'grammar');
 * - теми впорядковані за першою появою в програмі, у групі — модуль першої появи.
 */
export function buildLevelGrammar(input: {
  modules: readonly GrammarModuleInput[];
  lessonsByModule: Readonly<Record<string, readonly string[]>>;
  topics: readonly GrammarTopicInput[];
  links: ReadonlyArray<{ lesson_id: string; topic_id: string }>;
  completedLessonIds: Iterable<string>;
}): LevelGrammar {
  const modules = [...input.modules].sort((a, b) => a.order_index - b.order_index);
  const completed = new Set(input.completedLessonIds);

  // Порядок уроків у програмі рівня і модуль кожного уроку
  const lessonPos = new Map<string, number>();
  const lessonModule = new Map<string, string>();
  for (const m of modules) {
    for (const lessonId of input.lessonsByModule[m.id] ?? []) {
      if (lessonPos.has(lessonId)) continue;
      lessonPos.set(lessonId, lessonPos.size);
      lessonModule.set(lessonId, m.id);
    }
  }

  const currentModuleId =
    modules.find((m) => (input.lessonsByModule[m.id] ?? []).some((id) => !completed.has(id)))?.id ?? null;

  // Уроки кожної теми (лише уроки цього рівня)
  const lessonsOfTopic = new Map<string, Set<string>>();
  for (const { lesson_id, topic_id } of input.links) {
    if (!lessonPos.has(lesson_id)) continue;
    const set = lessonsOfTopic.get(topic_id) ?? new Set<string>();
    set.add(lesson_id);
    lessonsOfTopic.set(topic_id, set);
  }

  const built = input.topics.map((t) => {
    const lessons = [...(lessonsOfTopic.get(t.id) ?? [])].sort((a, b) => lessonPos.get(a)! - lessonPos.get(b)!);
    const first = lessons[0];
    const moduleId = first ? lessonModule.get(first)! : null;
    const state: TopicState = lessons.some((id) => completed.has(id))
      ? 'done'
      : moduleId && moduleId === currentModuleId
        ? 'now'
        : 'next';
    const topic: LevelTopic = {
      id: t.id,
      title_ua: t.title_ua,
      title_hr: t.title_hr,
      description: t.description,
      ruleCount: t.ruleCount,
      lessonCount: lessons.length,
      moduleId,
      state,
      search: normalizeSearch([t.title_ua, t.title_hr, t.description, t.searchExtra].filter(Boolean).join(' ')),
    };
    return { topic, firstPos: first !== undefined ? lessonPos.get(first)! : Number.MAX_SAFE_INTEGER };
  });
  built.sort((a, b) => a.firstPos - b.firstPos || a.topic.title_ua.localeCompare(b.topic.title_ua, 'uk'));

  const groups: LevelModuleGroup[] = modules
    .map((m) => {
      const topics = built.filter((b) => b.topic.moduleId === m.id).map((b) => b.topic);
      const state: TopicState =
        topics.length > 0 && topics.every((t) => t.state === 'done') ? 'done' : m.id === currentModuleId ? 'now' : 'next';
      return { id: m.id, order: m.order_index, title_ua: m.title_ua, title_hr: m.title_hr, state, topics };
    })
    .filter((g) => g.topics.length > 0);

  const all = built.map((b) => b.topic);
  return {
    groups,
    unlinked: all.filter((t) => t.moduleId === null),
    total: all.length,
    done: all.filter((t) => t.state === 'done').length,
    currentModuleId,
  };
}

/** Чи підходить тема під пошук: кожне слово запиту є в тексті теми (без діакритик). Порожній запит — так. */
export function matchesSearch(topic: Pick<LevelTopic, 'search'>, query: string): boolean {
  const words = normalizeSearch(query).split(' ').filter(Boolean);
  return words.every((w) => topic.search.includes(w));
}

/** Усі теми рівня за абеткою (українська назва). */
export function topicsAlphabetical(grammar: Pick<LevelGrammar, 'groups' | 'unlinked'>): LevelTopic[] {
  return [...grammar.groups.flatMap((g) => g.topics), ...grammar.unlinked].sort((a, b) =>
    a.title_ua.localeCompare(b.title_ua, 'uk'),
  );
}

// ---------------------------------------------------------------- вправи на тему

/** Вправи з уроків теми, що тренують саме речення (граматику), а не окремі слова. */
export const GRAMMAR_EXERCISE_TYPES = ['fill_in_the_blank', 'sentence_builder'] as const;

export interface PracticeExercise {
  id: string;
  exercise_type: string;
  question_text: string;
  correct_answer: string;
  options: unknown;
}

function grammarOnly<T extends PracticeExercise>(rows: readonly T[]): T[] {
  const seen = new Set<string>();
  return rows.filter((r) => {
    if (!(GRAMMAR_EXERCISE_TYPES as readonly string[]).includes(r.exercise_type) || seen.has(r.id)) return false;
    seen.add(r.id);
    return true;
  });
}

/** «Потренувати тему»: до `limit` вправ на речення з уроків теми, перемішано з seed, «вставити» перед «скласти». */
export function pickTopicExercises<T extends PracticeExercise>(rows: readonly T[], seed: string, limit = 10): T[] {
  return orderExercises(shuffle(grammarOnly(rows), seededRandom(seed)).slice(0, limit));
}

/**
 * «Підсумок граматики», крок 2: вправи на вибрані теми — по черзі з кожної теми (щоб усі теми потрапили),
 * до `limit` разом. Вправа, що є в кількох темах, береться один раз.
 */
export function pickReviewExercises<T extends PracticeExercise>(
  byTopic: Readonly<Record<string, readonly T[]>>,
  topicIds: readonly string[],
  seed: string,
  limit = 15,
): T[] {
  const random = seededRandom(seed);
  const pools = topicIds.map((id) => shuffle(grammarOnly(byTopic[id] ?? []), random));
  const out: T[] = [];
  const used = new Set<string>();
  for (let round = 0; out.length < limit && pools.some((p) => p.length > round); round++) {
    for (const pool of pools) {
      const ex = pool[round];
      if (!ex || used.has(ex.id)) continue;
      used.add(ex.id);
      out.push(ex);
      if (out.length >= limit) break;
    }
  }
  return orderExercises(out);
}

// ---------------------------------------------------------------- підсумок рівня

export interface ReviewTopic {
  id: string;
  title_ua: string;
  title_hr: string | null;
  /** Перший приклад першого правила з прикладами — «вмію сказати так» */
  example: { hr: string; ua: string } | null;
}

/** Відповідь людини про тему на кроці «Згадати». */
export type SelfCheck = 'can' | 'review';

/** Теми для тренування: «Треба повторити»; якщо таких немає — null (усе вмієте). */
export function weakTopicIds(topicIds: readonly string[], answers: Readonly<Record<string, SelfCheck | undefined>>): string[] {
  return topicIds.filter((id) => answers[id] === 'review');
}

/** Скільки тем уже позначено. */
export function answeredCount(topicIds: readonly string[], answers: Readonly<Record<string, SelfCheck | undefined>>): number {
  return topicIds.filter((id) => answers[id] !== undefined).length;
}

// ---------------------------------------------------------------- адреси й слова

export function grammarLevelHref(level: string): string {
  return `/lessons/grammar?level=${level}`;
}

export function grammarTopicHref(topicId: string): string {
  return `/lessons/grammar/${topicId}`;
}

export function grammarReviewHref(level: string): string {
  return `/lessons/grammar/review?level=${level}`;
}

/** «1 тема», «3 теми», «22 теми», «5 тем». */
export function topicsWord(n: number): string {
  return `${n} ${plural(n, 'тема', 'теми', 'тем')}`;
}

/** «1 правило», «4 правила», «5 правил». */
export function rulesWord(n: number): string {
  return `${n} ${plural(n, 'правило', 'правила', 'правил')}`;
}

/** «1 вправа», «3 вправи», «10 вправ». */
export function exercisesWord(n: number): string {
  return `${n} ${plural(n, 'вправа', 'вправи', 'вправ')}`;
}

/** «1 уроці», «2 уроках». */
export function lessonsLocative(n: number): string {
  return `${n} ${n % 10 === 1 && n % 100 !== 11 ? 'уроці' : 'уроках'}`;
}

function plural(n: number, one: string, few: string, many: string): string {
  const m10 = n % 10;
  const m100 = n % 100;
  if (m10 === 1 && m100 !== 11) return one;
  if (m10 >= 2 && m10 <= 4 && (m100 < 12 || m100 > 14)) return few;
  return many;
}
