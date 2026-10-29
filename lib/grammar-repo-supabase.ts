/**
 * Запити для «Граматики рівня» (лише сервер: page.tsx — Server Components). Діють RLS користувача;
 * у застосунку — тільки PUBLISHED. Уся обробка — у lib/grammar.ts.
 */
import type { SupabaseClient } from '@supabase/supabase-js';
import { examplesFrom, type TypicalError } from './interference.ts';
import type { GrammarRule } from './lesson-content.ts';
import { buildLevelGrammar, type LevelGrammar, type PracticeExercise, type ReviewTopic } from './grammar.ts';

type Row = Record<string, unknown>;

const RULES_SELECT = 'id, title_ua, explanation_ua, pattern_hr, examples, order_index';

/** Правила теми в порядку order_index, приклади — перевірені examplesFrom. */
export function rulesFrom(raw: unknown): GrammarRule[] {
  const rows = Array.isArray(raw) ? (raw as Row[]) : [];
  return [...rows]
    .sort((a, b) => ((a.order_index as number) ?? 0) - ((b.order_index as number) ?? 0))
    .map((r) => ({
      id: r.id as string,
      title_ua: (r.title_ua as string) ?? '',
      explanation_ua: (r.explanation_ua as string) ?? '',
      pattern_hr: (r.pattern_hr as string | null) ?? null,
      examples: examplesFrom(r.examples),
    }));
}

async function completedLessonIds(supabase: SupabaseClient, userId: string | null): Promise<string[]> {
  if (!userId) return [];
  const { data, error } = await supabase.from('lesson_progress').select('lesson_id').eq('user_id', userId).eq('status', 'completed');
  // Збій прогресу не ховає граматику — просто все буде «попереду»
  if (error) {
    console.error('Помилка завантаження прогресу уроків:', error.message);
    return [];
  }
  return (data ?? []).map((r) => (r as { lesson_id: string }).lesson_id);
}

export interface LevelGrammarData {
  grammar: LevelGrammar;
  /** Теми рівня з першим прикладом — для «Підсумку граматики» */
  reviewTopics: ReviewTopic[];
  /** Уроки рівня, де є тема */
  lessonsOfTopic: Record<string, string[]>;
}

/** Граматика рівня: модулі → юніти → уроки → теми уроків + прогрес людини. */
export async function loadLevelGrammar(supabase: SupabaseClient, level: string, userId: string | null): Promise<LevelGrammarData> {
  const modulesRes = await supabase
    .from('modules')
    .select('id, order_index, title_ua, title_hr')
    .eq('level_code', level)
    .eq('status', 'PUBLISHED')
    .order('order_index', { ascending: true });
  if (modulesRes.error) throw modulesRes.error;
  const modules = (modulesRes.data ?? []) as Array<{ id: string; order_index: number; title_ua: string; title_hr: string | null }>;
  const moduleIds = modules.map((m) => m.id);

  const unitsRes = moduleIds.length
    ? await supabase
        .from('units')
        .select('id, module_id')
        .in('module_id', moduleIds)
        .eq('status', 'PUBLISHED')
        .order('order_index', { ascending: true })
    : { data: [], error: null };
  if (unitsRes.error) throw unitsRes.error;
  const units = (unitsRes.data ?? []) as Array<{ id: string; module_id: string }>;
  const unitModule = new Map(units.map((u) => [u.id, u.module_id]));

  const [lessonsRes, completed] = await Promise.all([
    units.length
      ? supabase
          .from('lessons')
          .select('id, unit_id')
          .in('unit_id', units.map((u) => u.id))
          .eq('status', 'PUBLISHED')
          .order('order_index', { ascending: true })
          .order('created_at', { ascending: true })
      : Promise.resolve({ data: [], error: null }),
    completedLessonIds(supabase, userId),
  ]);
  if (lessonsRes.error) throw lessonsRes.error;
  const lessons = (lessonsRes.data ?? []) as Array<{ id: string; unit_id: string }>;

  // Уроки модуля в порядку програми: юніти за порядком, у юніті — уроки за порядком
  const unitOrder = new Map(units.map((u, i) => [u.id, i]));
  const lessonsByModule: Record<string, string[]> = Object.fromEntries(moduleIds.map((id) => [id, [] as string[]]));
  for (const l of [...lessons].sort((a, b) => (unitOrder.get(a.unit_id) ?? 0) - (unitOrder.get(b.unit_id) ?? 0))) {
    const m = unitModule.get(l.unit_id);
    if (m) lessonsByModule[m].push(l.id);
  }

  const lessonIds = lessons.map((l) => l.id);
  const linksRes = lessonIds.length
    ? await supabase.from('lesson_items').select('lesson_id, item_id').eq('item_type', 'grammar').in('lesson_id', lessonIds)
    : { data: [], error: null };
  if (linksRes.error) throw linksRes.error;
  const links = ((linksRes.data ?? []) as Array<{ lesson_id: string; item_id: string }>).map((r) => ({
    lesson_id: r.lesson_id,
    topic_id: r.item_id,
  }));

  // Теми рівня + теми, які трапляються в уроках рівня (на випадок нагадування з іншого рівня)
  const linkedIds = [...new Set(links.map((l) => l.topic_id))];
  const topicsRes = await supabase
    .from('grammar_topics')
    .select(`id, title_ua, title_hr, description, rules:grammar_rules(${RULES_SELECT})`)
    .or(linkedIds.length ? `cefr.eq.${level},id.in.(${linkedIds.join(',')})` : `cefr.eq.${level}`)
    .eq('status', 'PUBLISHED');
  if (topicsRes.error) throw topicsRes.error;
  const topicRows = (topicsRes.data ?? []) as Row[];

  const topics = topicRows.map((t) => {
    const rules = rulesFrom(t.rules);
    return {
      id: t.id as string,
      title_ua: t.title_ua as string,
      title_hr: (t.title_hr as string | null) ?? null,
      description: (t.description as string | null) ?? null,
      ruleCount: rules.length,
      searchExtra: rules.map((r) => `${r.title_ua} ${r.pattern_hr ?? ''}`).join(' '),
      rules,
    };
  });

  const grammar = buildLevelGrammar({ modules, lessonsByModule, topics, links, completedLessonIds: completed });

  const byId = new Map(topics.map((t) => [t.id, t]));
  const ordered = [...grammar.groups.flatMap((g) => g.topics), ...grammar.unlinked];
  const reviewTopics: ReviewTopic[] = ordered.map((t) => {
    const rules = byId.get(t.id)?.rules ?? [];
    const example = rules.find((r) => r.examples.length > 0)?.examples[0] ?? null;
    return { id: t.id, title_ua: t.title_ua, title_hr: t.title_hr, example };
  });

  const lessonsOfTopic: Record<string, string[]> = {};
  for (const { lesson_id, topic_id } of links) (lessonsOfTopic[topic_id] ??= []).push(lesson_id);

  return { grammar, reviewTopics, lessonsOfTopic };
}

/** Вправи з уроків: lesson_items (exercise) → exercises (PUBLISHED), згруповано за уроком. */
export async function loadLessonExercises(
  supabase: SupabaseClient,
  lessonIds: readonly string[],
): Promise<Record<string, PracticeExercise[]>> {
  if (lessonIds.length === 0) return {};
  const itemsRes = await supabase
    .from('lesson_items')
    .select('lesson_id, item_id')
    .eq('item_type', 'exercise')
    .in('lesson_id', [...lessonIds])
    .order('order_index', { ascending: true });
  if (itemsRes.error) throw itemsRes.error;
  const items = (itemsRes.data ?? []) as Array<{ lesson_id: string; item_id: string }>;
  const ids = [...new Set(items.map((i) => i.item_id))];
  if (ids.length === 0) return {};

  // Великі списки id — частинами, щоб адреса запиту не була задовгою
  const rows: PracticeExercise[] = [];
  for (let i = 0; i < ids.length; i += 150) {
    const res = await supabase
      .from('exercises')
      .select('id, exercise_type, question_text, correct_answer, options')
      .in('id', ids.slice(i, i + 150))
      .in('exercise_type', ['fill_in_the_blank', 'sentence_builder'])
      .eq('status', 'PUBLISHED');
    if (res.error) throw res.error;
    rows.push(...((res.data ?? []) as PracticeExercise[]));
  }
  const byId = new Map(rows.map((r) => [r.id, r]));
  const out: Record<string, PracticeExercise[]> = {};
  for (const { lesson_id, item_id } of items) {
    const ex = byId.get(item_id);
    if (ex) (out[lesson_id] ??= []).push(ex);
  }
  return out;
}

export interface TopicLesson {
  id: string;
  title_ua: string;
  title_hr: string | null;
  done: boolean;
  /** «A1.3» */
  moduleCode: string | null;
}

export interface TopicPageData {
  topic: {
    id: string;
    cefr: string;
    title_ua: string;
    title_hr: string | null;
    description: string | null;
    rules: GrammarRule[];
  };
  lessons: TopicLesson[];
  pitfalls: TypicalError[];
  exercises: PracticeExercise[];
  /** Тему вже пройдено (є пройдений урок) */
  done: boolean;
}

/** Одна тема: правила, уроки з темою, типові помилки, вправи на речення з її уроків. null — теми немає / не опублікована. */
export async function loadGrammarTopic(supabase: SupabaseClient, topicId: string, userId: string | null): Promise<TopicPageData | null> {
  const [topicRes, linksRes, errorsRes, completed] = await Promise.all([
    supabase
      .from('grammar_topics')
      .select(`id, cefr, title_ua, title_hr, description, rules:grammar_rules(${RULES_SELECT})`)
      .eq('id', topicId)
      .eq('status', 'PUBLISHED')
      .maybeSingle(),
    supabase.from('lesson_items').select('lesson_id').eq('item_type', 'grammar').eq('item_id', topicId),
    supabase
      .from('linguistic_errors')
      .select('id, code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id')
      .eq('status', 'PUBLISHED')
      .eq('grammar_topic_id', topicId)
      .limit(3),
    completedLessonIds(supabase, userId),
  ]);
  if (topicRes.error) throw topicRes.error;
  if (!topicRes.data) return null;
  if (linksRes.error) throw linksRes.error;
  // Типові помилки — необов'язкові
  if (errorsRes.error) console.warn('Типові помилки теми не завантажились:', errorsRes.error.message);

  const t = topicRes.data as Row;
  const linkedLessonIds = [...new Set(((linksRes.data ?? []) as Array<{ lesson_id: string }>).map((r) => r.lesson_id))];

  const lessonsRes = linkedLessonIds.length
    ? await supabase
        .from('lessons')
        .select('id, title_ua, title_hr, order_index, unit:units(order_index, status, module:modules(order_index, level_code, status))')
        .in('id', linkedLessonIds)
        .eq('status', 'PUBLISHED')
    : { data: [], error: null };
  if (lessonsRes.error) throw lessonsRes.error;

  const done = new Set(completed);
  const one = <T,>(v: unknown): T | null => ((Array.isArray(v) ? v[0] : v) as T | null) ?? null;
  const levelRank = (l: string | null) => ['A0', 'A1', 'A2', 'B1', 'B2'].indexOf(l ?? '');
  const lessons = ((lessonsRes.data ?? []) as Row[])
    .map((l) => {
      const unit = one<{ order_index: number | null; status: string | null; module: unknown }>(l.unit);
      const mod = one<{ order_index: number | null; level_code: string | null; status: string | null }>(unit?.module);
      return {
        id: l.id as string,
        title_ua: (l.title_ua as string) ?? 'Урок',
        title_hr: (l.title_hr as string | null) ?? null,
        done: done.has(l.id as string),
        moduleCode: mod?.level_code && mod.order_index != null ? `${mod.level_code}.${mod.order_index}` : null,
        published: unit?.status === 'PUBLISHED' && mod?.status === 'PUBLISHED',
        sort: [levelRank(mod?.level_code ?? null), mod?.order_index ?? 0, unit?.order_index ?? 0, (l.order_index as number) ?? 0],
      };
    })
    .filter((l) => l.published)
    .sort((a, b) => a.sort.reduce((acc, v, i) => acc || v - b.sort[i], 0));

  const exercisesByLesson = await loadLessonExercises(supabase, lessons.map((l) => l.id));

  return {
    topic: {
      id: t.id as string,
      cefr: (t.cefr as string) ?? '',
      title_ua: t.title_ua as string,
      title_hr: (t.title_hr as string | null) ?? null,
      description: (t.description as string | null) ?? null,
      rules: rulesFrom(t.rules),
    },
    lessons: lessons.map(({ id, title_ua, title_hr, done: d, moduleCode }) => ({ id, title_ua, title_hr, done: d, moduleCode })),
    pitfalls: errorsRes.error
      ? []
      : ((errorsRes.data ?? []) as Row[]).map((r) => ({ ...(r as unknown as TypicalError), examples: examplesFrom(r.examples) })),
    exercises: lessons.flatMap((l) => exercisesByLesson[l.id] ?? []),
    done: lessons.some((l) => l.done),
  };
}
