import Link from 'next/link';
import { ChevronRight } from 'lucide-react';
import { cn } from '@/lib/ui';

/**
 * Картка ситуації: знак, назва, метадані, одна дія (docs/DESIGN_SYSTEM.md §9.4).
 * Радісний стиль (§3.4): плитка знака — на світлому фоні кольору рівня (`tileClassName`), під назвою — бейджі (`tags`).
 */
export default function ScenarioCard({
  emoji,
  title,
  meta,
  href,
  tileClassName,
  tags,
  className,
}: {
  emoji: string;
  title: string;
  /** Напр. «9 фраз · 1 діалог» */
  meta?: string;
  href?: string;
  /** Фон плитки знака, напр. levelStyle('A0').soft; за замовчуванням нейтральний */
  tileClassName?: string;
  /** Бейджі рівнів, «Розмова з AI» */
  tags?: React.ReactNode;
  className?: string;
}) {
  const body = (
    <>
      <span
        aria-hidden="true"
        className={cn('flex size-12 shrink-0 items-center justify-center rounded-card text-2xl leading-none', tileClassName ?? 'bg-surface-muted')}
      >
        {emoji}
      </span>
      <span className="min-w-0 flex-1">
        <span className="block font-heading text-h3">{title}</span>
        {meta && <span className="mt-0.5 block text-label font-medium text-ink-muted">{meta}</span>}
        {tags && <span className="mt-1.5 flex flex-wrap items-center gap-1.5">{tags}</span>}
      </span>
      {href && <ChevronRight className="size-5 shrink-0 text-ink-subtle" aria-hidden="true" />}
    </>
  );
  const classes = cn('flex items-center gap-4 rounded-card border border-line bg-surface p-4 shadow-sm', className);

  return href ? (
    <Link href={href} className={cn(classes, 'transition-colors duration-150 hover:border-primary/40 active:scale-[0.98]')}>
      {body}
    </Link>
  ) : (
    <div className={classes}>{body}</div>
  );
}
