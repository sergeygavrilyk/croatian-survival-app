import { CircleCheck, CircleAlert, CircleX, Lightbulb } from 'lucide-react';
import type { AnswerVerdict } from '@/lib/answer';
import { cn } from '@/lib/ui';
import Hr from './Hr';

export type FeedbackKind = Exclude<AnswerVerdict, 'empty'> | 'gave_up';

const STYLES: Record<FeedbackKind, { box: string; Icon: typeof CircleCheck; title: string }> = {
  exact: { box: 'bg-success-soft border-success-line text-success-ink', Icon: CircleCheck, title: 'Правильно!' },
  diacritics: { box: 'bg-success-soft border-success-line text-success-ink', Icon: CircleCheck, title: 'Правильно. Зверніть увагу на літери:' },
  typo: { box: 'bg-warning-soft border-warning-line text-warning-ink', Icon: CircleAlert, title: 'Майже — одна одруківка. Правильно:' },
  wrong: { box: 'bg-danger-soft border-danger-line text-danger-ink', Icon: CircleX, title: 'Ще ні. Правильно:' },
  gave_up: { box: 'bg-surface-muted border-line text-ink', Icon: Lightbulb, title: 'Правильна відповідь:' },
};

/**
 * Результат відповіді за вердиктом `checkTypedAnswer()` (docs/DESIGN_SYSTEM.md §9.2).
 * Стан передається іконкою, текстом і кольором — не лише кольором.
 */
export default function FeedbackBanner({
  kind,
  expected,
  className,
  children,
}: {
  kind: FeedbackKind;
  /** Правильний хорватський варіант */
  expected?: string;
  className?: string;
  /** Додаткові дії, напр. <AudioButton /> */
  children?: React.ReactNode;
}) {
  const { box, Icon, title } = STYLES[kind];
  const showExpected = kind !== 'exact' && expected;
  return (
    <div role="status" className={cn('flex items-start gap-3 rounded-card border p-4 animate-fade-in-up', box, className)}>
      <Icon className="mt-0.5 size-5 shrink-0" aria-hidden="true" />
      <div className="min-w-0 flex-1">
        <p className="text-label">{title}</p>
        {showExpected && (
          <Hr as="p" className="mt-1 font-heading text-h3 break-words">
            {expected}
          </Hr>
        )}
      </div>
      {children}
    </div>
  );
}
