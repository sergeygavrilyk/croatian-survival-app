import { sessionCheer } from '@/lib/today';
import { cn } from '@/lib/ui';
import Card from './Card';
import Confetti from './Confetti';
import ProgressBar from './ProgressBar';

/**
 * Кінець сесії (тренажер, помилки, типові помилки, читання) і святковий екран після уроку:
 * 🎉 / 💪 / 🌱 за часткою правильних, підсумок, плитки (+N слів, серія 🔥), зелена смужка, дії.
 * На 🎉 — конфеті один раз (DESIGN_SYSTEM §3.4, §6: лише в кінці сесії, не після кожної відповіді).
 */
export default function SessionDone({
  correct,
  total,
  emoji,
  hero,
  title,
  celebrate,
  stats,
  barLabel = 'Правильних відповідей',
  headingAs: Heading = 'h2',
  children,
  footer,
  actions,
  className,
}: {
  correct: number;
  total: number;
  /** Свої емодзі й заголовок (урок: 🎉 «Урок пройдено!»); інакше — за часткою правильних */
  emoji?: string;
  /** Замість емодзі — картинка (талісман на святковому екрані після уроку) */
  hero?: React.ReactNode;
  title?: string;
  /** Конфеті; за замовчуванням — коли 🎉 */
  celebrate?: boolean;
  /** Плитки підсумку під заголовком */
  stats?: React.ReactNode;
  /** Підпис смужки для програм читання з екрана */
  barLabel?: string;
  /** h1 — коли це головний заголовок екрана (підсумок уроку) */
  headingAs?: 'h1' | 'h2';
  /** Текст підсумку під заголовком */
  children?: React.ReactNode;
  /** Додатковий вміст під смужкою (напр. «Тепер ви вмієте…») */
  footer?: React.ReactNode;
  /** Кнопки: головна дія першою */
  actions?: React.ReactNode;
  className?: string;
}) {
  const cheer = sessionCheer(correct, total);
  const shownEmoji = emoji ?? cheer.emoji;
  const party = celebrate ?? shownEmoji === '🎉';
  return (
    <>
      {party && <Confetti />}
      <Card hero role="status" className={cn('mx-auto flex w-full max-w-md animate-fade-in-up flex-col items-center gap-4 text-center', className)}>
        {hero ?? (
          <span className={cn('text-6xl leading-none', party && 'animate-pop')} aria-hidden="true">
            {shownEmoji}
          </span>
        )}
        <div>
          <Heading className={cn('font-heading', Heading === 'h1' ? 'text-h1' : 'text-h2')}>{title ?? cheer.title}</Heading>
          {children && <div className="mt-1 text-body text-ink-muted">{children}</div>}
        </div>
        {stats}
        {total > 0 && <ProgressBar value={correct} max={total} label={barLabel} barClassName="bg-success" />}
        {footer}
        {actions && <div className="flex w-full flex-col gap-2">{actions}</div>}
      </Card>
    </>
  );
}
