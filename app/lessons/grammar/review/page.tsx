import { createClient } from '@/utils/supabase/server';
import GrammarReview from '@/components/grammar/GrammarReview';
import { ASSESSED_LEVELS, assessmentSlug } from '@/lib/assessment';
import { pickLessonsLevel } from '@/lib/curriculum';
import { pickTopicExercises, type PracticeExercise, type ReviewTopic } from '@/lib/grammar';
import { loadLessonExercises, loadLevelGrammar } from '@/lib/grammar-repo-supabase';
import { newSeed } from '@/lib/random';

export const metadata = { title: 'Підсумок граматики · Croatian Survival App' };
export const dynamic = 'force-dynamic';

/** Скільки вправ кожної теми віддаємо в браузер (з них крок 2 бере до 15 разом). */
const PER_TOPIC = 8;

/**
 * «Підсумок граматики» рівня (рішення власника 2026-10-27, з варіанта Б) — перед фінальною перевіркою:
 * 1) згадати: «Вмію / Треба повторити» для кожної теми; 2) потренувати слабке; 3) фінальна перевірка рівня.
 */
export default async function GrammarReviewPage({ searchParams }: { searchParams: Promise<{ level?: string }> }) {
  const { level: requested } = await searchParams;
  const level = pickLessonsLevel(requested);
  const seed = newSeed();

  let topics: ReviewTopic[] | null = null;
  let exercisesByTopic: Record<string, PracticeExercise[]> = {};
  try {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();
    const data = await loadLevelGrammar(supabase, level, user?.id ?? null);
    topics = data.reviewTopics;
    const lessonIds = [...new Set(Object.values(data.lessonsOfTopic).flat())];
    const byLesson = await loadLessonExercises(supabase, lessonIds);
    exercisesByTopic = Object.fromEntries(
      topics.map((t) => [
        t.id,
        pickTopicExercises((data.lessonsOfTopic[t.id] ?? []).flatMap((id) => byLesson[id] ?? []), `${seed}:${t.id}`, PER_TOPIC),
      ]),
    );
  } catch (err) {
    console.error('Помилка завантаження підсумку граматики:', err instanceof Error ? err.message : err);
  }

  const finalHref = (ASSESSED_LEVELS as readonly string[]).includes(level) ? `/assessment/${assessmentSlug(level, 'final')}` : null;
  return <GrammarReview key={level} level={level} topics={topics} exercisesByTopic={exercisesByTopic} seed={seed} finalHref={finalHref} />;
}
