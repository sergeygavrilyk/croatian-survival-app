'use client';

import { useMemo, useState, useTransition } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Sparkles, X } from 'lucide-react';
import AudioButton from '@/components/ui/AudioButton';
import Button from '@/components/ui/Button';
import EmptyState from '@/components/ui/EmptyState';
import ErrorState from '@/components/ui/ErrorState';
import Hr from '@/components/ui/Hr';
import IconButton from '@/components/ui/IconButton';
import GrammarPractice from '@/components/grammar/GrammarPractice';
import {
  answeredCount, grammarLevelHref, pickReviewExercises, topicsWord, weakTopicIds,
  type PracticeExercise, type ReviewTopic, type SelfCheck,
} from '@/lib/grammar';
import { lessonsHref } from '@/lib/curriculum';
import { levelStyle } from '@/lib/levels';
import { cn } from '@/lib/ui';

type Step = 'check' | 'practice';

/**
 * «Підсумок граматики» рівня (рішення власника 2026-10-27; DESIGN_SYSTEM §7.9).
 * Крок 1 «Згадати» — для кожної теми приклад речення й «Вмію / Треба повторити» (спершу спробувати самому — §North Star);
 * крок 2 «Потренувати» — до 15 вправ на теми «Треба повторити» (нічого не позначено — на всі теми потроху);
 * крок 3 — фінальна перевірка рівня. Позначки живуть лише на цьому екрані (без нової таблиці).
 */
export default function GrammarReview({
  level,
  topics,
  exercisesByTopic,
  seed,
  finalHref,
}: {
  level: string;
  topics: ReviewTopic[] | null;
  exercisesByTopic: Record<string, PracticeExercise[]>;
  seed: string;
  /** Фінальна перевірка рівня; null — для рівня її ще немає */
  finalHref: string | null;
}) {
  const router = useRouter();
  const [, startRetry] = useTransition();
  const [answers, setAnswers] = useState<Record<string, SelfCheck | undefined>>({});
  const [step, setStep] = useState<Step>('check');
  const [run, setRun] = useState(0);
  const lv = levelStyle(level);
  const ids = useMemo(() => (topics ?? []).map((t) => t.id), [topics]);
  const weak = weakTopicIds(ids, answers);
  // Рядок, а не масив: список тем стабільний між рендерами, поки не змінились позначки
  const practiceKey = (weak.length > 0 ? weak : ids).join(',');
  const exercises = useMemo(
    () => pickReviewExercises(exercisesByTopic, practiceKey ? practiceKey.split(',') : [], `${seed}:${run}`, 15),
    [exercisesByTopic, practiceKey, seed, run],
  );

  const backHref = grammarLevelHref(level);

  if (!topics) {
    return (
      <Shell backHref={backHref} level={level}>
        <ErrorState text="Не вдалося завантажити підсумок. Перевірте інтернет і спробуйте ще раз." onRetry={() => startRetry(() => router.refresh())} />
      </Shell>
    );
  }
  if (topics.length === 0) {
    return (
      <Shell backHref={backHref} level={level}>
        <EmptyState
          icon={<Sparkles className="size-6" aria-hidden="true" />}
          title={`Граматика рівня ${level} ще готується`}
          text="Підсумок з’явиться разом з уроками рівня."
          action={<Button href={lessonsHref(level)}>До уроків</Button>}
        />
      </Shell>
    );
  }

  const finalButton = finalHref ? (
    <Button block href={finalHref}>
      Фінальна перевірка {level}
    </Button>
  ) : (
    <Button block href={lessonsHref(level)}>
      До уроків {level}
    </Button>
  );

  if (step === 'practice') {
    return (
      <div className="mx-auto flex min-h-screen max-w-2xl flex-col gap-4 px-5 pt-[calc(0.75rem+env(safe-area-inset-top))] pb-10">
        <div className="flex items-center gap-2">
          <IconButton label="Повернутися до кроку «Згадати»" onClick={() => setStep('check')} className="-ml-2">
            <X className="size-6" aria-hidden="true" />
          </IconButton>
          <p className="min-w-0 flex-1 truncate font-heading text-h3">Підсумок граматики {level}</p>
        </div>
        <Steps current={2} level={level} />
        {exercises.length === 0 ? (
          <EmptyState
            icon={<Sparkles className="size-6" aria-hidden="true" />}
            title="Вправ на ці теми поки немає"
            text="Повторіть правила на сторінках тем — і можна переходити до перевірки."
            action={finalButton}
          />
        ) : (
          <GrammarPractice
            key={run}
            exercises={exercises}
            level={level}
            source="grammar_review"
            doneTitle="Граматику повторено!"
            doneActions={
              <>
                {finalButton}
                <Button
                  block
                  variant="secondary"
                  onClick={() => {
                    setRun((n) => n + 1);
                    setStep('check');
                  }}
                >
                  Позначити теми ще раз
                </Button>
                <Button block variant="tertiary" href={backHref}>
                  Усі теми {level}
                </Button>
              </>
            }
          />
        )}
      </div>
    );
  }

  const marked = answeredCount(ids, answers);
  const set = (id: string, v: SelfCheck) => setAnswers((a) => ({ ...a, [id]: a[id] === v ? undefined : v }));

  return (
    <Shell backHref={backHref} level={level}>
      <Steps current={1} level={level} />
      <div>
        <h1 className="font-heading text-h1">Підсумок граматики {level}</h1>
        <p className="mt-1 text-body text-ink-muted">
          Що ви вже вмієте сказати? Прочитайте приклад, спробуйте сказати схоже речення про себе й позначте чесно. Те, що треба повторити, потренуємо першим.
        </p>
      </div>
      <p className={cn('text-label', lv.ink)} aria-live="polite">
        Позначено {marked} з {topics.length}
      </p>

      <ul className="flex flex-col gap-3 pb-36">
        {topics.map((t) => {
          const a = answers[t.id];
          return (
            <li key={t.id} className="flex flex-col gap-3 rounded-card border border-line bg-surface p-4 shadow-sm">
              <div className="flex items-start gap-2">
                <div className="min-w-0 flex-1">
                  <h2 className="text-body font-semibold">{t.title_ua}</h2>
                  {t.example ? (
                    <>
                      <Hr as="p" className={cn('text-body font-semibold', lv.ink)}>
                        {t.example.hr}
                      </Hr>
                      <p className="text-label font-normal text-ink-muted">{t.example.ua}</p>
                    </>
                  ) : (
                    t.title_hr && (
                      <Hr as="p" className="text-label font-normal text-ink-muted">
                        {t.title_hr}
                      </Hr>
                    )
                  )}
                </div>
                {t.example && <AudioButton text={t.example.hr} label={`Прослухати «${t.example.hr}»`} />}
              </div>
              <div role="group" aria-label={`Як ви знаєте тему «${t.title_ua}»`} className="grid grid-cols-2 gap-2">
                <button
                  type="button"
                  aria-pressed={a === 'can'}
                  onClick={() => set(t.id, 'can')}
                  className={cn(
                    'min-h-11 rounded-control border text-label transition-colors duration-150',
                    a === 'can' ? 'border-2 border-success bg-success-soft text-success-ink' : 'border-line bg-surface text-ink-muted hover:bg-surface-muted',
                  )}
                >
                  Вмію
                </button>
                <button
                  type="button"
                  aria-pressed={a === 'review'}
                  onClick={() => set(t.id, 'review')}
                  className={cn(
                    'min-h-11 rounded-control border text-label transition-colors duration-150',
                    a === 'review' ? 'border-2 border-warning bg-warning-soft text-warning-ink' : 'border-line bg-surface text-ink-muted hover:bg-surface-muted',
                  )}
                >
                  Треба повторити
                </button>
              </div>
            </li>
          );
        })}
      </ul>

      <div className="fixed inset-x-0 bottom-0 z-30 border-t border-line bg-surface/95 px-5 pt-3 pb-[calc(1rem+env(safe-area-inset-bottom))]">
        <div className="mx-auto flex max-w-2xl flex-col gap-1">
          <p className="text-center text-label font-normal text-ink-muted">
            {weak.length > 0 ? `Потренуємо ${topicsWord(weak.length)}, які треба повторити` : 'Нічого не позначено «повторити» — вправи на все потроху'}
          </p>
          <Button block onClick={() => setStep('practice')}>
            Далі: вправи
          </Button>
          {finalHref && (
            <Button block variant="tertiary" href={finalHref}>
              Одразу до фінальної перевірки
            </Button>
          )}
        </div>
      </div>
    </Shell>
  );
}

function Shell({ backHref, level, children }: { backHref: string; level: string; children: React.ReactNode }) {
  return (
    <div className="mx-auto flex min-h-screen max-w-2xl flex-col gap-4 px-5 pt-[calc(1rem+env(safe-area-inset-top))] pb-10">
      <Link href={backHref} className="-ml-1 inline-flex min-h-11 w-fit items-center gap-1.5 rounded-control px-1 text-label text-ink-muted hover:text-ink">
        <ArrowLeft className="size-5" aria-hidden="true" />
        Граматика {level}
      </Link>
      {children}
    </div>
  );
}

/** Кроки підсумку: 1 Згадати → 2 Потренувати → 3 Перевірка рівня. */
function Steps({ current, level }: { current: 1 | 2; level: string }) {
  const lv = levelStyle(level);
  const steps = ['Згадати', 'Потренувати', `Перевірка ${level}`];
  return (
    <ol aria-label="Кроки підсумку" className="grid grid-cols-3 gap-2">
      {steps.map((s, i) => {
        const n = i + 1;
        const active = n <= current;
        return (
          <li key={s} aria-current={n === current ? 'step' : undefined} className="flex flex-col gap-1.5">
            <span className={cn('h-1.5 rounded-full', active ? lv.bar : 'bg-surface-muted')} />
            <span className={cn('text-caption', n === current ? lv.ink : 'text-ink-subtle')}>
              {n}. {s}
            </span>
          </li>
        );
      })}
    </ol>
  );
}
