import Link from 'next/link';
import { ChevronRight, CircleCheck, ClipboardCheck, Flag, Milestone } from 'lucide-react';
import Card from '@/components/ui/Card';
import EmptyState from '@/components/ui/EmptyState';
import { DEFAULT_AREA_MIN_RATIO, DEFAULT_PASS_RATIO, percent, type LevelStatus } from '@/lib/assessment';
import { cn } from '@/lib/ui';

export interface AssessmentListItem {
  slug: string;
  kind: string;
  title: string;
  subtitle: string | null;
  minutes: number | null;
  attempts: number;
  bestScore: number | null;
  passed: boolean;
}

/**
 * Список перевірок рівня (§60): модулі 1–5 → середина → 6–10 → фінал.
 * Стан — іконкою й текстом (не лише кольором, §98). Тести не блокують уроки.
 */
export default function AssessmentListView({
  level,
  items,
  status,
}: {
  level: string | null;
  items: AssessmentListItem[];
  status: LevelStatus;
}) {
  if (!level || items.length === 0) {
    return (
      <EmptyState
        icon={<ClipboardCheck className="size-6" aria-hidden="true" />}
        title="Перевірок поки немає"
        text="Тут з’являться короткі тести після кожного модуля, у середині й наприкінці рівня."
      />
    );
  }

  return (
    <div className="flex flex-col gap-4">
      <Card className={cn('flex flex-col gap-2', status.finalPassed && 'border-success-line bg-success-soft')}>
        <p className="font-heading text-h3">
          {status.finalPassed ? `Рівень ${level} підтверджено` : `Рівень ${level}: пройдено ${status.passed} з ${status.total}`}
        </p>
        <p className="text-body text-ink-muted">
          Кожна перевірка міряє 4 навички: розумію, кажу, спілкуюся, переказую. Пройдено — ≥ {percent(DEFAULT_PASS_RATIO)} % загалом і ≥{' '}
          {percent(DEFAULT_AREA_MIN_RATIO)} % у кожній навичці. Уроки відкриті незалежно від результату.
        </p>
        <p className="text-caption text-ink-subtle">Це оцінка застосунку, а не офіційний сертифікат CEFR.</p>
      </Card>

      <ol className="flex flex-col gap-2">
        {items.map((t) => {
          const Icon = t.kind === 'final' ? Flag : t.kind === 'mid' ? Milestone : ClipboardCheck;
          const big = t.kind !== 'module';
          const state = t.passed
            ? `Пройдено · найкраще ${percent(t.bestScore)} %`
            : t.attempts > 0
              ? `Найкраще ${percent(t.bestScore)} % · ще не пройдено`
              : `Не проходили${t.minutes ? ` · ~${t.minutes} хв` : ''}`;
          return (
            <li key={t.slug}>
              <Link
                href={`/assessment/${t.slug}`}
                className={cn(
                  'flex min-h-16 items-center gap-3 rounded-card border bg-surface p-4 shadow-sm transition-colors hover:border-primary',
                  t.passed ? 'border-success-line' : big ? 'border-primary' : 'border-line',
                )}
              >
                <span
                  className={cn(
                    'flex size-10 shrink-0 items-center justify-center rounded-full',
                    t.passed ? 'bg-success-soft text-success-ink' : 'bg-primary-soft text-primary-ink',
                  )}
                >
                  {t.passed ? <CircleCheck className="size-5" aria-hidden="true" /> : <Icon className="size-5" aria-hidden="true" />}
                </span>
                <span className="min-w-0 flex-1">
                  <span className={cn('block break-words', big ? 'font-heading text-h3' : 'text-body font-semibold')}>{t.title}</span>
                  {t.subtitle && <span className="block text-label font-normal text-ink-muted break-words">{t.subtitle}</span>}
                  <span className={cn('block text-caption', t.passed ? 'text-success-ink' : 'text-ink-subtle')}>{state}</span>
                </span>
                <ChevronRight className="size-5 shrink-0 text-ink-subtle" aria-hidden="true" />
              </Link>
            </li>
          );
        })}
      </ol>
    </div>
  );
}
