import { Fragment } from 'react';
import Link from 'next/link';
import { ChevronRight, CircleCheck, ClipboardCheck, Sparkles } from 'lucide-react';
import Card from '@/components/ui/Card';
import EmptyState from '@/components/ui/EmptyState';
import LevelBadge from '@/components/ui/LevelBadge';
import ProgressBar from '@/components/ui/ProgressBar';
import { assessmentIcon, levelStyle } from '@/lib/levels';
import { DEFAULT_AREA_MIN_RATIO, DEFAULT_PASS_RATIO, percent, type LevelStatus } from '@/lib/assessment';
import { grammarReviewHref } from '@/lib/grammar';
import { cn } from '@/lib/ui';

export interface AssessmentListItem {
  slug: string;
  kind: string;
  title: string;
  /** Номер модуля (перевірка модуля) — для емодзі теми */
  moduleOrder?: number | null;
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

  const lv = levelStyle(level);
  return (
    <div className="flex flex-col gap-4">
      <Card className={cn('flex flex-col gap-3', status.finalPassed ? 'border-success-line bg-success-soft' : cn('border-t-4', lv.line))}>
        <div className="flex items-center gap-3">
          <span
            aria-hidden="true"
            className={cn(
              'flex size-12 shrink-0 items-center justify-center rounded-card text-2xl leading-none',
              status.finalPassed ? 'bg-surface' : lv.soft,
            )}
          >
            {status.finalPassed ? '🏅' : '📝'}
          </span>
          <div className="min-w-0 flex-1">
            <p className="flex flex-wrap items-center gap-2">
              <LevelBadge level={level} />
              <span className={cn('text-label', status.finalPassed ? 'text-success-ink' : lv.ink)}>{lv.name}</span>
            </p>
            <p className="font-heading text-h3">
              {status.finalPassed ? `Рівень ${level} підтверджено! 🎉` : `Пройдено ${status.passed} з ${status.total}`}
            </p>
          </div>
        </div>
        {!status.finalPassed && status.total > 0 && (
          <ProgressBar value={status.passed} max={status.total} label={`Пройдено перевірок рівня ${level}`} barClassName="bg-success" />
        )}
        <p className="text-body text-ink-muted">
          Кожна перевірка міряє 4 навички: розумію, кажу, спілкуюся, переказую. Пройдено — ≥ {percent(DEFAULT_PASS_RATIO)} % загалом і ≥{' '}
          {percent(DEFAULT_AREA_MIN_RATIO)} % у кожній навичці. Уроки відкриті незалежно від результату.
        </p>
        <p className="text-caption text-ink-subtle">Це оцінка застосунку, а не офіційний сертифікат CEFR.</p>
      </Card>

      <ol className="flex flex-col gap-2">
        {items.map((t) => {
          const big = t.kind !== 'module';
          const state = t.passed
            ? `Пройдено · найкраще ${percent(t.bestScore)} %`
            : t.attempts > 0
              ? `Найкраще ${percent(t.bestScore)} % · ще не пройдено`
              : `Не проходили${t.minutes ? ` · ~${t.minutes} хв` : ''}`;
          return (
            <Fragment key={t.slug}>
            {t.kind === 'final' && (
              <li>
                <Link
                  href={grammarReviewHref(level)}
                  className={cn(
                    'flex min-h-16 items-center gap-3 rounded-card border-2 border-dashed p-4 transition-colors hover:bg-surface',
                    lv.line,
                    lv.soft,
                  )}
                >
                  <span aria-hidden="true" className={cn('flex size-12 shrink-0 items-center justify-center rounded-card bg-surface', lv.ink)}>
                    <Sparkles className="size-6" />
                  </span>
                  <span className="min-w-0 flex-1">
                    <span className="block text-body font-semibold">Перед фіналом: підсумок граматики {level}</span>
                    <span className="block text-label font-normal text-ink-muted">Згадати все й потренувати слабке · ~15 хв</span>
                  </span>
                  <ChevronRight className="size-5 shrink-0 text-ink-subtle" aria-hidden="true" />
                </Link>
              </li>
            )}
            <li>
              <Link
                href={`/assessment/${t.slug}`}
                className={cn(
                  'flex min-h-16 items-center gap-3 rounded-card border bg-surface p-4 shadow-sm transition-colors hover:border-primary',
                  t.passed ? 'border-success-line' : big ? cn('border-2', lv.line) : 'border-line',
                )}
              >
                <span
                  aria-hidden="true"
                  className={cn(
                    'relative flex size-12 shrink-0 items-center justify-center rounded-card text-2xl leading-none',
                    t.passed ? 'bg-success-soft' : lv.soft,
                  )}
                >
                  {assessmentIcon(t.kind, level, t.moduleOrder)}
                  {t.passed && (
                    <CircleCheck className="absolute -right-1.5 -bottom-1.5 size-5 rounded-full bg-surface text-success" aria-hidden="true" />
                  )}
                </span>
                <span className="min-w-0 flex-1">
                  <span className={cn('block break-words', big ? 'font-heading text-h3' : 'text-body font-semibold')}>{t.title}</span>
                  {t.subtitle && <span className="block text-label font-normal text-ink-muted break-words">{t.subtitle}</span>}
                  <span className={cn('block text-caption', t.passed ? 'text-success-ink' : 'text-ink-subtle')}>{state}</span>
                </span>
                <ChevronRight className="size-5 shrink-0 text-ink-subtle" aria-hidden="true" />
              </Link>
            </li>
            </Fragment>
          );
        })}
      </ol>
    </div>
  );
}
