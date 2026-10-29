import { createClient } from '@/utils/supabase/server';
import GrammarLevelView from '@/components/grammar/GrammarLevelView';
import { pickLessonsLevel } from '@/lib/curriculum';
import { loadLevelGrammar } from '@/lib/grammar-repo-supabase';
import type { LevelGrammar } from '@/lib/grammar';

export const metadata = { title: 'Граматика рівня · Croatian Survival App' };
export const dynamic = 'force-dynamic';

/**
 * «Уроки» → «Граматика рівня» (рішення власника 2026-10-27, варіант А): усі теми рівня в одному місці,
 * за модулями першої появи, зі станом «пройдено / зараз / попереду». Рівень — з адреси (?level=A1).
 */
export default async function GrammarLevelPage({ searchParams }: { searchParams: Promise<{ level?: string }> }) {
  const { level: requested } = await searchParams;
  const level = pickLessonsLevel(requested);

  let grammar: LevelGrammar | null = null;
  try {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();
    grammar = (await loadLevelGrammar(supabase, level, user?.id ?? null)).grammar;
  } catch (err) {
    console.error('Помилка завантаження граматики рівня:', err instanceof Error ? err.message : err);
  }

  return <GrammarLevelView key={level} level={level} grammar={grammar} />;
}
