import type { StatTileData } from '@/lib/celebration';
import { cn } from '@/lib/ui';

const TONE: Record<StatTileData['tone'], string> = {
  success: 'border-success-line bg-success-soft text-success-ink',
  warning: 'border-warning-line bg-warning-soft text-warning-ink',
};

/** Плитка підсумку на святковому екрані: «📚 +22 нові слова», «🔥 5 днів поспіль» (число «вискакує»). */
export default function StatTile({ emoji, value, label, tone, index = 0 }: StatTileData & { index?: number }) {
  return (
    <li className={cn('flex flex-col items-center gap-0.5 rounded-card border px-3 py-3', TONE[tone])}>
      <span
        className="flex items-center gap-1.5 font-heading text-h2 tabular-nums animate-pop"
        style={{ animationDelay: `${150 + index * 180}ms` }}
      >
        <span aria-hidden="true">{emoji}</span>
        {value}
      </span>
      <span className="text-label">{label}</span>
    </li>
  );
}
