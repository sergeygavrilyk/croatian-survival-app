'use client';

import { useState } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ArrowRight, BookOpen, ChevronDown, CircleAlert, CircleCheck, CircleMinus, CircleX, RotateCcw } from 'lucide-react';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import PageHeader from '@/components/ui/PageHeader';
import { moveToLevel, type AssessmentResultView } from '@/app/actions/assessment';
import { AREA_LABELS, AREAS, areaRatio, percent, type Area } from '@/lib/assessment';
import { isUkrainian } from '@/lib/lesson-flow';
import { cn } from '@/lib/ui';
import { AREA_ICONS } from '@/components/assessment-icons';

/** Порада, що робити, коли навичка нижче порогу. */
const AREA_ADVICE: Record<Area, string> = {
  understand: 'Послухайте діалоги уроків ще раз і прочитайте тексти в «Практиці» → «Читання».',
  produce: 'Повторіть слова в «Практиці» → «Написати» і скажіть фрази з уроку вголос.',
  interact: 'Пройдіть діалоги уроків і рольову гру в «Ситуаціях».',
  mediate: 'Перечитайте діалоги з перекладом: хто що сказав і що це означає.',
};

/**
 * Результат тесту рівня (§60): бал загалом і за 4 навичками, «пройдено / ще ні» з поясненням,
 * що повторити (уроки, «Помилки»), розбір відповідей. Позначка: це оцінка застосунку, не сертифікат.
 */
export default function AssessmentResult({
  result,
  title,
  backHref,
  onRetry,
}: {
  result: AssessmentResultView;
  title: string;
  backHref: string;
  onRetry: () => void;
}) {
  const router = useRouter();
  const [showReview, setShowReview] = useState(false);
  const [moving, setMoving] = useState(false);
  const [moveError, setMoveError] = useState<string | null>(null);
  const { passed } = result;

  const goNextLevel = async () => {
    if (!result.nextLevel) return;
    setMoving(true);
    setMoveError(null);
    try {
      const res = await moveToLevel(result.nextLevel);
      if (res.ok) router.push('/lessons');
      else setMoveError(res.error);
    } catch {
      setMoveError('Немає інтернету — рівень не змінено.');
    } finally {
      setMoving(false);
    }
  };

  return (
    <div className="min-h-screen pb-10">
      <PageHeader title={title} backHref={backHref} closeMode />
      <main className="mx-auto flex max-w-md flex-col gap-4 px-4 py-6">
        <Card
          className={cn('flex flex-col items-center gap-2 text-center', passed ? 'border-success-line bg-success-soft' : 'border-warning-line bg-warning-soft')}
          role="status"
        >
          {passed ? (
            <CircleCheck className="size-10 text-success-ink" aria-hidden="true" />
          ) : (
            <CircleAlert className="size-10 text-warning-ink" aria-hidden="true" />
          )}
          <p className={cn('font-heading text-h2', passed ? 'text-success-ink' : 'text-warning-ink')}>
            {passed ? 'Пройдено!' : 'Ще не пройдено'}
          </p>
          <p className="font-heading text-h1">{percent(result.score)} %</p>
          <p className="text-body text-ink-muted">
            Правильно {result.correct} з {result.total}. Поріг: ≥ {percent(result.passRatio)} % загалом і ≥ {percent(result.areaMinRatio)} % у кожній навичці.
          </p>
        </Card>

        <Card className="flex flex-col gap-4">
          <h2 className="font-heading text-h3">За навичками</h2>
          <ul className="flex flex-col gap-4">
            {AREAS.map((a) => {
              const s = result.areaScores[a];
              const ratio = areaRatio(s);
              const weak = result.weakAreas.includes(a);
              const Icon = AREA_ICONS[a];
              return (
                <li key={a} className="flex flex-col gap-1.5">
                  <div className="flex items-center gap-2">
                    <Icon className="size-4 text-ink-muted" aria-hidden="true" />
                    <span className="flex-1 text-body font-semibold">{AREA_LABELS[a].title}</span>
                    <span className={cn('text-label', weak ? 'text-danger-ink' : 'text-ink-muted')}>
                      {ratio === null ? (s.skipped > 0 ? 'пропущено' : '—') : `${s.correct} з ${s.total} · ${percent(ratio)} %`}
                    </span>
                  </div>
                  <div
                    className="relative h-2 overflow-hidden rounded-full bg-line"
                    role="img"
                    aria-label={`${AREA_LABELS[a].title}: ${ratio === null ? 'без відповідей' : `${percent(ratio)} %`}${weak ? ', нижче порогу' : ''}`}
                  >
                    <div
                      className={cn('h-full rounded-full', weak ? 'bg-danger' : 'bg-success')}
                      style={{ width: `${percent(ratio)}%` }}
                    />
                  </div>
                  {s.skipped > 0 && ratio !== null && (
                    <p className="text-caption text-ink-subtle">Пропущено говоріння: {s.skipped} — не рахується в бал.</p>
                  )}
                  {weak && <p className="text-caption text-danger-ink">Нижче {percent(result.areaMinRatio)} %. {AREA_ADVICE[a]}</p>}
                </li>
              );
            })}
          </ul>
        </Card>

        {result.nextLevel && (
          <Card className="flex flex-col gap-3 border-success-line">
            <h2 className="font-heading text-h3">Рівень {result.cefr} підтверджено</h2>
            <p className="text-body text-ink-muted">
              Можна переходити на {result.nextLevel}: застосунок показуватиме уроки й повторення цього рівня. Уроки {result.cefr} лишаються відкриті.
            </p>
            <Button block onClick={goNextLevel} loading={moving}>
              Перейти на {result.nextLevel}
              <ArrowRight className="size-5" aria-hidden="true" />
            </Button>
            {moveError && <p role="alert" className="text-body text-danger-ink">{moveError}</p>}
          </Card>
        )}

        {(result.lessons.length > 0 || result.savedMistakes > 0) && (
          <Card className="flex flex-col gap-3">
            <h2 className="font-heading text-h3">Що повторити</h2>
            {result.lessons.length > 0 && (
              <ul className="flex flex-col gap-2">
                {result.lessons.map((l) => (
                  <li key={l.id}>
                    <Link
                      href={`/lesson/${l.id}`}
                      className="flex min-h-11 items-center gap-3 rounded-control border border-line bg-surface px-3 py-2 text-body hover:border-primary"
                    >
                      <BookOpen className="size-5 shrink-0 text-primary" aria-hidden="true" />
                      <span className="min-w-0 flex-1">{l.title_ua}</span>
                    </Link>
                  </li>
                ))}
              </ul>
            )}
            {result.savedMistakes > 0 && (
              <p className="text-body text-ink-muted">
                {result.savedMistakes} {result.savedMistakes === 1 ? 'фразу' : 'фраз(и)'} додано в{' '}
                <Link href="/mistakes" className="font-semibold text-primary underline underline-offset-2">«Помилки»</Link> — там їх можна потренувати.
              </p>
            )}
          </Card>
        )}

        <div className="flex flex-col gap-2">
          <button
            type="button"
            onClick={() => setShowReview((v) => !v)}
            aria-expanded={showReview}
            className="flex min-h-11 items-center justify-between rounded-control px-1 text-body font-semibold text-primary"
          >
            Розбір відповідей
            <ChevronDown className={cn('size-5 transition-transform', showReview && 'rotate-180')} aria-hidden="true" />
          </button>
          {showReview && (
            <ol className="flex flex-col gap-2">
              {result.review.map((r) => {
                const StatusIcon = r.skipped ? CircleMinus : r.correct ? CircleCheck : CircleX;
                const status = r.skipped ? 'пропущено' : r.correct ? 'правильно' : 'помилка';
                return (
                  <li key={r.order} className="flex gap-3 rounded-card border border-line bg-surface p-3">
                    <StatusIcon
                      className={cn('mt-0.5 size-5 shrink-0', r.skipped ? 'text-ink-subtle' : r.correct ? 'text-success-ink' : 'text-danger-ink')}
                      aria-label={status}
                    />
                    <div className="min-w-0 flex-1 text-body">
                      <p className="text-caption text-ink-subtle">{AREA_LABELS[r.area].title}</p>
                      <p className="break-words">{r.prompt_ua}</p>
                      {r.prompt_hr && <Hr as="p" className="break-words text-ink-muted">«{r.prompt_hr}»</Hr>}
                      {!r.correct && !r.skipped && r.given && (
                        <p className="mt-1 break-words text-danger-ink">
                          Ваша відповідь: <Answer text={r.given} />
                        </p>
                      )}
                      {!r.correct && (
                        <p className="mt-1 break-words text-success-ink">
                          Правильно: <Answer text={r.correctText} />
                        </p>
                      )}
                      {!r.correct && !r.skipped && r.explanation && <p className="mt-1 text-caption text-ink-muted">{r.explanation}</p>}
                    </div>
                  </li>
                );
              })}
            </ol>
          )}
        </div>

        <p className="text-caption text-ink-subtle">
          Це оцінка застосунку за вашими відповідями, а не офіційний сертифікат CEFR.
          {result.attemptSaved ? '' : ' Результат не вдалося зберегти — перевірте інтернет.'}
        </p>
        <div className="flex flex-col gap-2">
          <Button variant={passed ? 'secondary' : 'primary'} block onClick={onRetry}>
            <RotateCcw className="size-5" aria-hidden="true" />
            Пройти ще раз
          </Button>
          <Button variant={passed ? 'primary' : 'tertiary'} block href={backHref}>
            До перевірок
          </Button>
        </div>
      </main>
    </div>
  );
}

function Answer({ text }: { text: string }) {
  return isUkrainian(text) ? <span className="font-semibold">{text}</span> : <Hr className="font-semibold">{text}</Hr>;
}
