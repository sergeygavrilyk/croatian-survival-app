import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import PracticeTabs from '@/components/ui/PracticeTabs';
import SegmentedLinks from '@/components/ui/SegmentedLinks';
import { MISTAKES_SEGMENTS } from '@/lib/navigation';
import ErrorState from '@/components/ui/ErrorState';
import MistakesPractice, { type MistakeItem } from '@/components/MistakesPractice';
import { newSeed } from '@/lib/random';
import { isDue, SESSION_SIZE } from '@/lib/mistakes';

export const metadata = { title: 'Мої помилки · Croatian Survival App' };
export const dynamic = 'force-dynamic';

/**
 * «Практика» → «Помилки»: повторення особистих помилок — з рольової гри й з вправи «Типові помилки» (user_errors, M9 + M12 + M14).
 * Сторінка бере дані, MistakesPractice — інтерактивна вправа.
 */
export default async function MistakesPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const [openRes, resolvedRes] = await Promise.all([
    supabase
      .from('user_errors')
      .select('id, source, original_text, corrected_text, explanation_ua, error_type, situation, next_review_at, resolved_at')
      .eq('user_id', user.id)
      .is('resolved_at', null)
      .order('created_at', { ascending: true })
      .limit(300),
    supabase
      .from('user_errors')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', user.id)
      .not('resolved_at', 'is', null),
  ]);

  const failed = Boolean(openRes.error);
  const open = openRes.data ?? [];
  const now = new Date();
  const due = open.filter((row) => isDue(row as { resolved_at: string | null; next_review_at: string | null }, now));
  const items: MistakeItem[] = due.slice(0, SESSION_SIZE).map((row) => ({
    id: row.id as string,
    original: row.original_text as string,
    corrected: row.corrected_text as string,
    explanation: (row.explanation_ua as string | null) ?? null,
    source: (row.source as string | null) ?? null,
  }));

  return (
    <div className="min-h-screen pb-28">
      <header className="mx-auto max-w-md px-4 pt-[calc(2.5rem+env(safe-area-inset-top))] mb-4">
        <h1 className="font-heading text-h1 mb-2">Практика</h1>
        <PracticeTabs />
        <SegmentedLinks items={MISTAKES_SEGMENTS} label="Які помилки" className="mt-4" />
      </header>
      <main className="mx-auto max-w-md px-4">
        {failed ? (
          <ErrorState text="Не вдалося завантажити помилки. Перевірте інтернет і оновіть сторінку." />
        ) : (
          <MistakesPractice
            items={items}
            waitingCount={open.length - due.length}
            resolvedCount={resolvedRes.count ?? 0}
            seed={newSeed()}
          />
        )}
      </main>
    </div>
  );
}
