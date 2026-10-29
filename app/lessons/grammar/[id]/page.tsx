import { createClient } from '@/utils/supabase/server';
import GrammarTopicView from '@/components/grammar/GrammarTopicView';
import { pickTopicExercises } from '@/lib/grammar';
import { loadGrammarTopic, type TopicPageData } from '@/lib/grammar-repo-supabase';
import { newSeed } from '@/lib/random';

export const metadata = { title: 'Тема граматики · Croatian Survival App' };
export const dynamic = 'force-dynamic';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Тема граматики (рішення власника 2026-10-27): правила з прикладами й озвученням, типові помилки,
 * уроки з темою і «Потренувати тему» — вправи на речення з уроків теми.
 */
export default async function GrammarTopicPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  let data: TopicPageData | null = null;
  let failed = false;
  if (UUID_RE.test(id)) {
    try {
      const supabase = await createClient();
      const { data: { user } } = await supabase.auth.getUser();
      data = await loadGrammarTopic(supabase, id, user?.id ?? null);
    } catch (err) {
      console.error('Помилка завантаження теми граматики:', err instanceof Error ? err.message : err);
      failed = true;
    }
  }
  // Вправи перемішуємо на сервері з seed — однаково на сервері й у браузері (lib/random.ts)
  const exercises = data ? pickTopicExercises(data.exercises, `${newSeed()}:${id}`, 10) : [];
  return <GrammarTopicView data={data ? { ...data, exercises } : null} failed={failed} />;
}
