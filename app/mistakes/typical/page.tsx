import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import PracticeTabs from '@/components/ui/PracticeTabs';
import SegmentedLinks from '@/components/ui/SegmentedLinks';
import ErrorState from '@/components/ui/ErrorState';
import TypicalErrorsQuiz from '@/components/TypicalErrorsQuiz';
import { newSeed } from '@/lib/random';
import { examplesFrom, upToLevel, type TypicalError } from '@/lib/interference';
import { MISTAKES_SEGMENTS } from '@/lib/navigation';

export const metadata = { title: 'Типові помилки · Croatian Survival App' };
export const dynamic = 'force-dynamic';

/**
 * «Практика» → «Помилки» → «Типові помилки українців» (§19 ТЗ, M14 linguistic_errors).
 * Сторінка бере дані (каталог до рівня користувача + які помилки вже в «Моїх помилках»),
 * TypicalErrorsQuiz — інтерактивна вправа.
 */
export default async function TypicalErrorsPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const [catalogRes, profileRes, savedRes] = await Promise.all([
    supabase
      .from('linguistic_errors')
      .select('id, code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples')
      .eq('status', 'PUBLISHED')
      .order('code', { ascending: true })
      .limit(500),
    supabase.from('profiles').select('current_level').eq('id', user.id).maybeSingle(),
    supabase.from('user_errors').select('linguistic_error_id').eq('user_id', user.id).not('linguistic_error_id', 'is', null).limit(500),
  ]);

  const failed = Boolean(catalogRes.error);
  const catalog: TypicalError[] = (catalogRes.data ?? []).map((r) => ({ ...(r as Omit<TypicalError, 'examples'>), examples: examplesFrom(r.examples) }));
  const items = upToLevel(catalog, (profileRes.data?.current_level as string | null | undefined) ?? null);
  const savedIds = (savedRes.data ?? []).map((r) => r.linguistic_error_id as string);

  return (
    <div className="min-h-screen pb-28">
      <header className="mx-auto max-w-2xl px-5 pt-[calc(2.5rem+env(safe-area-inset-top))] pb-4">
        <h1 className="font-heading text-h1">Практика</h1>
        <PracticeTabs className="mt-2" />
        <SegmentedLinks items={MISTAKES_SEGMENTS} label="Які помилки" className="mt-4" />
      </header>
      <main className="mx-auto max-w-2xl px-5">
        {failed ? (
          <ErrorState text="Не вдалося завантажити типові помилки. Перевірте інтернет і оновіть сторінку." />
        ) : (
          <>
            <p className="mb-4 text-body text-ink-muted">
              Помилки, які українці часто роблять у хорватській: схожі слова з іншим значенням, відмінки, порядок слів, вимова.
            </p>
            <TypicalErrorsQuiz items={items} savedIds={savedIds} seed={newSeed()} />
          </>
        )}
      </main>
    </div>
  );
}
