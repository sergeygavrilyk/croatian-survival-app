import { MessagesSquare } from 'lucide-react';
import { createClient } from '@/utils/supabase/server';
import { summarizeSituations, situationMeta } from '@/lib/situations';
import ScenarioCard from '@/components/ui/ScenarioCard';
import EmptyState from '@/components/ui/EmptyState';
import ErrorState from '@/components/ui/ErrorState';
import Button from '@/components/ui/Button';
import { SONGS } from '@/lib/songs';

export const metadata = { title: 'Ситуації · Croatian Survival App' };

/**
 * «Ситуації» — фрази й діалоги для реальних ситуацій (docs/DESIGN_SYSTEM.md §9.4).
 * Дані: phrases і conversations, лише PUBLISHED.
 */
export default async function SituationsPage() {
  const supabase = await createClient();
  const [phrasesRes, dialoguesRes] = await Promise.all([
    supabase.from('phrases').select('situation, cefr').eq('status', 'PUBLISHED'),
    supabase.from('conversations').select('situation, level').eq('status', 'PUBLISHED').not('situation', 'is', null),
  ]);
  const failed = Boolean(phrasesRes.error || dialoguesRes.error);
  const situations = failed ? [] : summarizeSituations(phrasesRes.data ?? [], dialoguesRes.data ?? []);

  return (
    <div className="min-h-screen pb-28">
      <header className="mx-auto max-w-2xl px-5 pt-[calc(2.5rem+env(safe-area-inset-top))] pb-4">
        <h1 className="font-heading text-h1">Ситуації</h1>
        <p className="mt-1 text-body text-ink-muted">Що сказати в магазині, у лікаря, на СТО чи в MUP.</p>
      </header>

      {failed ? (
        <ErrorState text="Перевірте інтернет і оновіть сторінку. Ваш прогрес збережено." />
      ) : situations.length === 0 ? (
        <EmptyState
          icon={<MessagesSquare className="size-6" aria-hidden="true" />}
          title="Ситуацій поки немає"
          text="Фрази й діалоги з'являться тут після перевірки й публікації. А поки — продовжуйте уроки."
          action={<Button href="/lessons">До уроків</Button>}
        />
      ) : (
        <ul className="mx-auto grid max-w-2xl gap-3 px-5 sm:grid-cols-2">
          {situations.map((s) => (
            <li key={s.code}>
              <ScenarioCard emoji={s.emoji} title={s.label} meta={situationMeta(s)} href={`/situations/${s.code}`} className="h-full" />
            </li>
          ))}
        </ul>
      )}

      <section className="mx-auto mt-6 max-w-2xl px-5" aria-label="Пісні">
        <ScenarioCard emoji="🎵" title="Пісні" meta={`${SONGS.length} пісень для свят і фешт`} href="/situations/songs" />
      </section>
    </div>
  );
}
