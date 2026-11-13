import { labelChips, labelsAriaText, readLabels, type LexemeLabels } from '@/lib/lexeme-labels';
import { cn } from '@/lib/ui';
import Hr from './Hr';

/**
 * Позначка категорії слова (DESIGN_SYSTEM.md §3.4, рішення власника 2026-11-13): чипи «розмовне»,
 * «регіонально · Далмація», «італізм»… і «стандартно: *razumjeti*». Звичайне слово без стандартного відповідника — нічого.
 * Невідомі значення не показуємо (readLabels). «Образа» й «грубо» — бурштинові (увага), текст однаковий для всіх (стан не лише кольором, §98).
 */
export default function WordLabels({
  labels,
  standardLemma,
  className,
}: {
  labels: LexemeLabels;
  /** Лема стандартного відповідника (`standard_lexeme_id`), якщо є. */
  standardLemma?: string | null;
  className?: string;
}) {
  const chips = labelChips(readLabels(labels)); // офлайн-копія уроку могла зберегтися зі старими значеннями
  if (chips.length === 0 && !standardLemma) return null;
  return (
    <span className={cn('flex flex-wrap items-center gap-1.5', className)}>
      {chips.length > 0 && (
        <span className="flex flex-wrap items-center gap-1.5" role="list" aria-label={labelsAriaText(chips)}>
          {chips.map((chip) => (
            <span
              key={chip.key}
              role="listitem"
              className={cn(
                'inline-flex items-center rounded-full px-2 py-0.5 text-caption',
                chip.tone === 'warning' ? 'bg-warning-soft font-semibold text-warning-ink' : 'bg-surface-muted text-ink-muted',
              )}
            >
              {chip.text}
            </span>
          ))}
        </span>
      )}
      {standardLemma && (
        <span className="text-caption text-ink-muted">
          стандартно: <Hr className="font-semibold text-ink italic">{standardLemma}</Hr>
        </span>
      )}
    </span>
  );
}
