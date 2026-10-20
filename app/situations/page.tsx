import { MessagesSquare, Sparkles } from 'lucide-react';
import { createClient } from '@/utils/supabase/server';
import { groupSituations, situationCounts, summarizeSituations } from '@/lib/situations';
import { getScenario } from '@/lib/roleplay';
import { levelStyle } from '@/lib/levels';
import ScenarioCard from '@/components/ui/ScenarioCard';
import LevelBadge from '@/components/ui/LevelBadge';
import EmptyState from '@/components/ui/EmptyState';
import ErrorState from '@/components/ui/ErrorState';
import Button from '@/components/ui/Button';
import { SONGS } from '@/lib/songs';

export const metadata = { title: 'Ситуації · Croatian Survival App' };

/**
 * «Ситуації» — фрази й діалоги для реальних ситуацій (docs/DESIGN_SYSTEM.md §9.4).
 * Дані: phrases і conversations, лише PUBLISHED. Радісний стиль (§3.4, 2026-10-20): групи за темами,
 * знак ситуації на фоні кольору першого рівня, бейджі рівнів, «Розмова з AI» (індиго) там, де є рольова гра.
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
        <div className="mx-auto flex max-w-2xl animate-fade-in-up flex-col gap-6 px-5">
          {groupSituations(situations).map((g) => (
            <section key={g.key} className="flex flex-col gap-2" aria-labelledby={`situations-${g.key}`}>
              <h2 id={`situations-${g.key}`} className="text-label text-ink-muted">
                {g.label}
              </h2>
              <ul className="grid gap-3 sm:grid-cols-2">
                {g.items.map((s) => (
                  <li key={s.code}>
                    <ScenarioCard
                      emoji={s.emoji}
                      title={s.label}
                      meta={situationCounts(s)}
                      href={`/situations/${s.code}`}
                      tileClassName={s.levels[0] ? levelStyle(s.levels[0]).soft : undefined}
                      tags={
                        <>
                          {s.levels.map((l) => (
                            <LevelBadge key={l} level={l} />
                          ))}
                          {getScenario(s.code) && (
                            <span className="inline-flex items-center gap-1 rounded-full bg-ai-soft px-2.5 py-0.5 text-caption font-semibold text-ai-ink">
                              <Sparkles className="size-3.5" aria-hidden="true" />
                              Розмова з AI
                            </span>
                          )}
                        </>
                      }
                      className="h-full"
                    />
                  </li>
                ))}
              </ul>
            </section>
          ))}
        </div>
      )}

      <section className="mx-auto mt-6 flex max-w-2xl flex-col gap-2 px-5" aria-labelledby="situations-songs">
        <h2 id="situations-songs" className="text-label text-ink-muted">
          Свята й пісні
        </h2>
        <ScenarioCard emoji="🎵" title="Пісні" meta={`${SONGS.length} пісень для свят і фешт`} href="/situations/songs" />
      </section>
    </div>
  );
}
