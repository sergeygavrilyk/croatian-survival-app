import { createClient } from '@/utils/supabase/server';
import LessonScreen from '@/components/lesson/LessonScreen';
import { buildLessonContent, lessonItemIds, pitfallsFilter, type LessonContent, type LessonRows } from '@/lib/lesson-content';

export const metadata = { title: 'Урок · Croatian Survival App' };
export const dynamic = 'force-dynamic';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Урок (§75, з 2026-10-21 — Server Component): сторінка бере дані з бази на сервері,
 * LessonScreen (client) — показує урок, зберігає офлайн-копію (§76) і завершення.
 * Онлайн урок завжди свіжий, тож ручна версія кешу (LESSON_CACHE_VERSION) більше не потрібна.
 */
export default async function LessonPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const content = UUID_RE.test(id) ? await loadLesson(id) : { content: null, notFound: true };
  return <LessonScreen lessonId={id} initial={content.content} notFound={content.notFound} />;
}

/** null + notFound — уроку немає (або він не опублікований); null без notFound — збій бази чи мережі. */
async function loadLesson(lessonId: string): Promise<{ content: LessonContent | null; notFound: boolean }> {
  try {
    const supabase = await createClient();
    const [lessonRes, itemsRes, conversationsRes] = await Promise.all([
      supabase
        .from('lessons')
        .select('id, title_ua, title_hr, level_code, objectives, estimated_minutes, unit_id')
        .eq('id', lessonId)
        .eq('status', 'PUBLISHED')
        .maybeSingle(),
      supabase.from('lesson_items').select('item_type, item_id').eq('lesson_id', lessonId).order('order_index', { ascending: true }),
      supabase
        .from('conversations')
        .select('id, title_ua, title_hr, situation')
        .eq('lesson_id', lessonId)
        .eq('status', 'PUBLISHED')
        .order('order_index', { ascending: true }),
    ]);
    for (const r of [lessonRes, itemsRes, conversationsRes]) if (r.error) throw r.error;
    if (!lessonRes.data) return { content: null, notFound: true };

    const items = (itemsRes.data ?? []) as LessonRows['items'];
    const conversations = (conversationsRes.data ?? []) as LessonRows['conversations'];
    const { lexemeIds, exerciseIds, grammarIds } = lessonItemIds(items);
    const errorsFilter = pitfallsFilter({ grammarIds, lexemeIds });
    const none = Promise.resolve({ data: [], error: null });

    const unitId = (lessonRes.data as { unit_id?: string | null }).unit_id ?? null;

    const [lexemesRes, exercisesRes, grammarRes, turnsRes, errorsRes, moduleRes] = await Promise.all([
      lexemeIds.length
        ? supabase.from('lexemes').select('id, lemma, ukrainian_translation').in('id', lexemeIds).eq('status', 'PUBLISHED')
        : none,
      exerciseIds.length
        ? supabase
            .from('exercises')
            .select('id, exercise_type, question_text, correct_answer, options, task')
            .in('id', exerciseIds)
            .eq('status', 'PUBLISHED')
            .then(async (res) =>
              // колонка task — з міграції M19 (письмо й переказ); без неї урок працює як раніше
              res.error?.code === '42703'
                ? supabase
                    .from('exercises')
                    .select('id, exercise_type, question_text, correct_answer, options')
                    .in('id', exerciseIds)
                    .eq('status', 'PUBLISHED')
                : res,
            )
        : none,
      grammarIds.length
        ? supabase
            .from('grammar_topics')
            .select('id, title_ua, title_hr, description, rules:grammar_rules(id, title_ua, explanation_ua, pattern_hr, examples, order_index)')
            .in('id', grammarIds)
            .eq('status', 'PUBLISHED')
        : none,
      conversations.length
        ? supabase
            .from('conversation_turns')
            .select('id, conversation_id, speaker_name, hr_text, ua_translation')
            .in('conversation_id', conversations.map((c) => c.id))
            .order('order_index', { ascending: true })
        : none,
      // Типові помилки українців (§19) — необов'язкові: збій не ламає урок
      errorsFilter
        ? supabase
            .from('linguistic_errors')
            .select('id, code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id')
            .eq('status', 'PUBLISHED')
            .or(errorsFilter)
        : none,
      // Модуль уроку — для емодзі теми на вступі (DESIGN_SYSTEM §3.4); необов'язковий
      unitId
        ? supabase.from('units').select('module:modules(order_index, title_ua, title_hr)').eq('id', unitId).maybeSingle()
        : Promise.resolve({ data: null, error: null }),
    ]);
    for (const r of [lexemesRes, exercisesRes, grammarRes, turnsRes]) if (r.error) throw r.error;
    if (errorsRes.error) console.warn('Типові помилки не завантажились:', errorsRes.error.message);
    if (moduleRes.error) console.warn('Модуль уроку не завантажився:', moduleRes.error.message);
    const moduleRaw = moduleRes.error ? null : (moduleRes.data as { module?: unknown } | null)?.module;
    const moduleRow = (Array.isArray(moduleRaw) ? moduleRaw[0] : moduleRaw) as LessonRows['module'] | undefined;

    const content = buildLessonContent({
      lesson: lessonRes.data as LessonRows['lesson'],
      items,
      lexemes: (lexemesRes.data ?? []) as LessonRows['lexemes'],
      exercises: (exercisesRes.data ?? []) as LessonRows['exercises'],
      conversations,
      turns: (turnsRes.data ?? []) as LessonRows['turns'],
      grammar: (grammarRes.data ?? []) as unknown as LessonRows['grammar'],
      errors: errorsRes.error ? [] : ((errorsRes.data ?? []) as LessonRows['errors']),
      module: moduleRow ?? null,
    });
    return { content, notFound: false };
  } catch (err) {
    console.error('Помилка завантаження уроку:', err instanceof Error ? err.message : err);
    return { content: null, notFound: false };
  }
}
