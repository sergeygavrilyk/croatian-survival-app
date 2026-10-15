import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import PracticeTabs from '@/components/ui/PracticeTabs';
import SegmentedLinks from '@/components/ui/SegmentedLinks';
import ErrorState from '@/components/ui/ErrorState';
import ReadingListView, { type ReadingListItem, type ReadingModule } from '@/components/ReadingListView';
import { pickReadingLevel, READING_LEVELS, type ReadingLevel } from '@/lib/reading';

export const metadata = { title: 'Читання · Croatian Survival App' };
export const dynamic = 'force-dynamic';

/**
 * «Практика» → «Читання» (§6 ТЗ «Extensive Reading»): перемикач рівнів A0 · A1 · A2,
 * тексти рівня за модулями й що вже прочитано. Рівень — з адреси (?level=A2) або з профілю.
 * Сторінка бере дані, ReadingListView — малює.
 */
export default async function ReadingPage({ searchParams }: { searchParams: Promise<{ level?: string }> }) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');
  const { level: requested } = await searchParams;

  const [textsRes, profileRes, progressRes] = await Promise.all([
    supabase
      .from('reading_texts')
      .select('id, code, cefr, text_type, module_order, title_ua, title_hr, word_count, known_ratio')
      .eq('status', 'PUBLISHED')
      .order('cefr', { ascending: true })
      .order('order_index', { ascending: true })
      .limit(500),
    supabase.from('profiles').select('current_level').eq('id', user.id).maybeSingle(),
    supabase.from('reading_progress').select('text_id, correct_count, question_count').eq('user_id', user.id).limit(1000),
  ]);

  const all = (textsRes.data ?? []) as Array<Omit<ReadingListItem, 'known_ratio'> & { cefr: string; known_ratio: number | string | null }>;
  const available = READING_LEVELS.filter((l) => all.some((t) => t.cefr === l));
  const level: ReadingLevel = pickReadingLevel(requested, profileRes.data?.current_level, available);

  const modulesRes = await supabase
    .from('modules')
    .select('order_index, title_ua')
    .eq('level_code', level)
    .eq('status', 'PUBLISHED');

  const items: ReadingListItem[] = all
    .filter((t) => t.cefr === level)
    .map((t) => ({ ...t, known_ratio: t.known_ratio === null ? null : Number(t.known_ratio) }));
  const modules: ReadingModule[] = (modulesRes.data ?? []).map((m) => ({ order: m.order_index as number, title_ua: m.title_ua as string }));
  const progress: Record<string, { correct: number; total: number }> = {};
  for (const p of progressRes.data ?? []) {
    progress[p.text_id as string] = { correct: p.correct_count as number, total: p.question_count as number };
  }
  const levelTabs = available.map((l) => ({ href: `/reading?level=${l}`, label: l }));

  return (
    <div className="min-h-screen pb-28">
      <header className="mx-auto max-w-md px-4 pt-[calc(2.5rem+env(safe-area-inset-top))] mb-4">
        <h1 className="font-heading text-h1 mb-2">Практика</h1>
        <PracticeTabs />
      </header>
      <main className="mx-auto max-w-md px-4">
        {textsRes.error ? (
          <ErrorState text="Не вдалося завантажити тексти. Перевірте інтернет і оновіть сторінку." />
        ) : (
          <>
            {levelTabs.length > 1 && (
              <SegmentedLinks items={levelTabs} activeHref={`/reading?level=${level}`} label="Рівень текстів" className="mb-4" />
            )}
            <ReadingListView level={level} items={items} modules={modules} progress={progress} />
          </>
        )}
      </main>
    </div>
  );
}
