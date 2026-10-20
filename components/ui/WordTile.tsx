import { levelStyle } from '@/lib/levels';
import { cn } from '@/lib/ui';
import { wordInitial, type WordTheme } from '@/lib/word-theme';

/**
 * Плитка слова (DESIGN_SYSTEM §3.4): емодзі теми модуля, де слово вперше трапляється в уроках,
 * на світлому фоні кольору рівня слова. Слово поза уроками — перша літера в кольорі рівня.
 */
export default function WordTile({
  lemma,
  level,
  theme,
  size = 'md',
  className,
}: {
  lemma: string;
  level?: string | null;
  theme?: WordTheme | null;
  size?: 'md' | 'lg';
  className?: string;
}) {
  const lv = levelStyle(level ?? theme?.level);
  return (
    <span
      aria-hidden="true"
      title={theme ? `Тема: ${theme.level}.${theme.moduleOrder} ${theme.title}` : undefined}
      className={cn(
        'flex shrink-0 items-center justify-center rounded-card leading-none',
        size === 'lg' ? 'size-14 text-3xl' : 'size-12 text-2xl',
        lv.soft,
        !theme && cn('font-heading font-bold', size === 'lg' ? 'text-h2' : 'text-h3', lv.ink),
        className,
      )}
    >
      {theme ? theme.icon : <span lang="hr">{wordInitial(lemma)}</span>}
    </span>
  );
}
