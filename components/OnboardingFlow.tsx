'use client';

import { useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { Check, ChevronDown } from 'lucide-react';
import PageHeader from '@/components/ui/PageHeader';
import Card from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import Hr from '@/components/ui/Hr';
import ProgressBar from '@/components/ui/ProgressBar';
import LevelBadge from '@/components/ui/LevelBadge';
import Confetti from '@/components/ui/Confetti';
import MascotPicker from '@/components/MascotPicker';
import { storeMascot, type MascotKind } from '@/lib/mascot';
import { levelStyle } from '@/lib/levels';
import { track } from '@/lib/analytics-client';
import { DAILY_GOALS, LEARNING_GOALS, SELF_LEVELS } from '@/lib/onboarding';
import type { Confidence, LevelScore, PlacementAnswer } from '@/lib/placement';
import { cn } from '@/lib/ui';
import {
  completeOnboarding,
  getPlacementTest,
  submitPlacement,
  type PlacementQuestion,
  type PlacementReviewItem,
} from '@/app/actions/onboarding';

type Step = 'goals' | 'daily' | 'level' | 'test-intro' | 'test' | 'result';
const MAIN_STEPS: Step[] = ['goals', 'daily', 'level'];
const START_LEVELS = ['A0', 'A1', 'A2', 'B1', 'B2'] as const;

const CONFIDENCE_TEXT: Record<Confidence, string> = {
  high: 'Оцінка досить надійна.',
  medium: 'Оцінка приблизна: межа між рівнями нечітка.',
  low: 'Оцінка ненадійна: відповіді були непослідовні або питань замало. Можна пройти тест ще раз пізніше.',
};

interface PlacementOutcome {
  estimated: string;
  recommendedStart: string;
  confidence: Confidence;
  scoreByLevel: Record<string, LevelScore>;
  review: PlacementReviewItem[];
}

/**
 * Онбординг: мета → щоденна ціль → самооцінка → тест рівня (за бажанням) → результат.
 * Радісний стиль (DESIGN_SYSTEM §3.4, 2026-10-20): 👋 вітає на першому кроці, знаки цілей як у «Ситуаціях»,
 * рівні — у своїх кольорах, результат тесту — у кольорі рівня з конфеті.
 */
export default function OnboardingFlow({
  initialGoals,
  initialDailyGoal,
  isRepeat,
}: {
  initialGoals: string[];
  initialDailyGoal: number | null;
  isRepeat: boolean;
}) {
  const router = useRouter();
  const [step, setStep] = useState<Step>('goals');
  const [goals, setGoals] = useState<string[]>(initialGoals);
  const [dailyGoal, setDailyGoal] = useState<number | null>(initialDailyGoal);
  const [selfKey, setSelfKey] = useState<string | null>(null);
  const [mascot, setMascot] = useState<MascotKind | null>(null);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Тест рівня
  const [test, setTest] = useState<{ assessmentId: string; questions: PlacementQuestion[] } | null>(null);
  const [testMissing, setTestMissing] = useState(false);
  const [loadingTest, setLoadingTest] = useState(false);
  const [qIndex, setQIndex] = useState(0);
  const [answers, setAnswers] = useState<PlacementAnswer[]>([]);
  const startedAt = useRef<string | null>(null);
  const [outcome, setOutcome] = useState<PlacementOutcome | null>(null);
  const [chosenStart, setChosenStart] = useState<string | null>(null);

  useEffect(() => {
    track('onboarding_started', { source: isRepeat ? 'repeat' : 'first' });
  }, [isRepeat]);

  const self = SELF_LEVELS.find((s) => s.key === selfKey) ?? null;

  const finish = async (level: string, viaPlacement: boolean) => {
    setSaving(true);
    setError(null);
    const res = await completeOnboarding({
      goals,
      dailyGoalMinutes: dailyGoal,
      level,
      timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
      selfLevel: selfKey ?? undefined,
      viaPlacement,
      mascot,
    });
    if (res.ok) {
      storeMascot(window.localStorage, mascot);
      router.replace('/');
      router.refresh();
    } else {
      setError(res.error);
      setSaving(false);
    }
  };

  const startTest = async () => {
    setLoadingTest(true);
    setError(null);
    try {
      const t = await getPlacementTest();
      if (!t) {
        setTestMissing(true);
        return;
      }
      setTest(t);
      setAnswers([]);
      setQIndex(0);
      startedAt.current = new Date().toISOString();
      track('placement_started', { count: t.questions.length, self_level: selfKey ?? undefined });
      setStep('test');
    } catch {
      setError('Не вдалося завантажити тест. Перевірте інтернет.');
    } finally {
      setLoadingTest(false);
    }
  };

  const submitTest = async (all: PlacementAnswer[]) => {
    if (!test) return;
    setSaving(true);
    setError(null);
    const res = await submitPlacement(test.assessmentId, all, startedAt.current);
    setSaving(false);
    if (!res.ok) {
      setError(res.error);
      return;
    }
    setOutcome({ ...res.result, review: res.review });
    setChosenStart(res.result.recommendedStart);
    setStep('result');
  };

  const answerQuestion = (chosen: number | null) => {
    if (!test) return;
    const q = test.questions[qIndex];
    const next = [...answers.filter((a) => a.item_id !== q.id), { item_id: q.id, chosen }];
    setAnswers(next);

    const nextQ = test.questions[qIndex + 1];
    const blockEnds = !nextQ || nextQ.cefr !== q.cefr;
    if (blockEnds) {
      // Якщо на рівні майже все «Не знаю» — складніші питання не показуємо
      const block = test.questions.filter((x) => x.cefr === q.cefr);
      const skipped = block.filter((x) => next.find((a) => a.item_id === x.id)?.chosen === null).length;
      if (!nextQ || skipped >= Math.ceil(block.length * 0.75)) {
        void submitTest(next);
        return;
      }
    }
    setQIndex(qIndex + 1);
  };

  // ---------------------------------------------------------------- шапка
  const mainIndex = MAIN_STEPS.indexOf(step);
  const back = () => {
    setError(null);
    if (step === 'daily') setStep('goals');
    else if (step === 'level') setStep('daily');
    else if (step === 'test-intro') setStep('level');
    else if (step === 'test') setStep('test-intro'); // перервати тест
    else if (step === 'result') setStep('test-intro');
    else if (step === 'goals' && isRepeat) router.push('/profile');
  };
  const canGoBack = (step !== 'goals' || isRepeat) && !saving;

  return (
    <div className="min-h-screen pb-10">
      <PageHeader
        title={step === 'test' ? 'Тест рівня' : step === 'result' ? 'Ваш результат' : 'Налаштуймо навчання'}
        onBack={canGoBack ? back : undefined}
        closeMode={step === 'test'}
        action={
          step === 'test' ? (
            <Button variant="tertiary" size="sm" onClick={() => void submitTest(answers)} disabled={saving}>
              Завершити
            </Button>
          ) : undefined
        }
      >
        {mainIndex >= 0 && <ProgressBar value={mainIndex + 1} max={MAIN_STEPS.length} label="Крок налаштування" />}
        {step === 'test' && test && (
          <ProgressBar value={qIndex} max={test.questions.length} label="Прогрес тесту" />
        )}
      </PageHeader>

      <main className="mx-auto flex max-w-2xl flex-col gap-4 px-5 pt-6">
        {error && (
          <p role="alert" className="rounded-card border border-danger-line bg-danger-soft p-4 text-body text-danger-ink">
            {error}
          </p>
        )}

        {step === 'goals' && (
          <>
            {!isRepeat && <Welcome mascot={mascot} onMascot={setMascot} />}
            <StepTitle title="Для чого вам хорватська?" hint="Можна обрати кілька — підберемо ситуації і слова." />
            <div className="flex flex-col gap-2" role="group" aria-label="Мета навчання">
              {LEARNING_GOALS.map((g) => (
                <ChoiceButton
                  key={g.key}
                  selected={goals.includes(g.key)}
                  onClick={() => setGoals((v) => (v.includes(g.key) ? v.filter((x) => x !== g.key) : [...v, g.key]))}
                  label={g.label}
                  hint={g.hint}
                  emoji={g.emoji}
                  multi
                />
              ))}
            </div>
            <Button block disabled={goals.length === 0} onClick={() => setStep('daily')}>
              Далі
            </Button>
          </>
        )}

        {step === 'daily' && (
          <>
            <StepTitle title="Скільки часу на день?" hint="Ціль можна змінити будь-коли в профілі." />
            <div className="flex flex-col gap-2" role="radiogroup" aria-label="Щоденна ціль">
              {DAILY_GOALS.map((d) => (
                <ChoiceButton
                  key={d.minutes}
                  selected={dailyGoal === d.minutes}
                  onClick={() => setDailyGoal(d.minutes)}
                  label={d.label}
                  hint={d.hint}
                />
              ))}
            </div>
            <Button block disabled={dailyGoal === null} onClick={() => setStep('level')}>
              Далі
            </Button>
          </>
        )}

        {step === 'level' && (
          <>
            <StepTitle title="Як ви оцінюєте свою хорватську?" hint="Якщо щось уже знаєте — запропонуємо короткий тест." />
            <div className="flex flex-col gap-2" role="radiogroup" aria-label="Самооцінка рівня">
              {SELF_LEVELS.map((s) => (
                <ChoiceButton
                  key={s.key}
                  selected={selfKey === s.key}
                  onClick={() => setSelfKey(s.key)}
                  label={s.label}
                  badge={<LevelBadge level={s.level} />}
                />
              ))}
            </div>
            <Button
              block
              disabled={!self || saving}
              loading={saving}
              onClick={() => (self?.test ? setStep('test-intro') : self && void finish(self.level, false))}
            >
              {self && !self.test ? 'Почати навчання' : 'Далі'}
            </Button>
          </>
        )}

        {step === 'test-intro' && self && (
          <>
            <StepTitle
              title="Короткий тест рівня"
              hint="До 24 питань від A0 до B2: слова, граматика, читання. 5–10 хвилин. Якщо не знаєте відповіді — натисніть «Не знаю», це нормально: складніші питання тоді не показуємо."
            />
            <Card className="text-body text-ink-muted">
              Результат — <strong className="text-ink">оцінка застосунку</strong>, а не офіційний сертифікат CEFR. Аудіювання й говоріння
              тест поки не перевіряє.
            </Card>
            {testMissing ? (
              <Card className="border-warning-line bg-warning-soft text-warning-ink">
                Тест ще проходить перевірку і скоро з&apos;явиться. Поки що почнемо з рівня {self.level} — змінити можна в профілі.
              </Card>
            ) : null}
            <div className="flex flex-col gap-2">
              {!testMissing && (
                <Button block onClick={() => void startTest()} loading={loadingTest}>
                  Почати тест
                </Button>
              )}
              <Button block variant={testMissing ? 'primary' : 'tertiary'} onClick={() => void finish(self.level, false)} loading={saving}>
                {testMissing ? `Почати з рівня ${self.level}` : `Пропустити — почати з ${self.level}`}
              </Button>
            </div>
          </>
        )}

        {step === 'test' && test && test.questions[qIndex] && (
          <QuestionCard
            key={test.questions[qIndex].id}
            question={test.questions[qIndex]}
            number={qIndex + 1}
            total={test.questions.length}
            disabled={saving}
            onAnswer={answerQuestion}
          />
        )}

        {step === 'result' && outcome && (
          <PlacementResultView
            outcome={outcome}
            chosenStart={chosenStart}
            onChooseStart={setChosenStart}
            saving={saving}
            onFinish={() => chosenStart && void finish(chosenStart, true)}
          />
        )}
      </main>
    </div>
  );
}

// ---------------------------------------------------------------- частини
/**
 * Привітання на першому кроці + вибір талісмана (Pjegica, Šime або Točka, рішення власника 2026-10-20).
 * Вибір необов'язковий: не обрано — показуємо Pjegica; змінити можна в профілі.
 */
function Welcome({ mascot, onMascot }: { mascot: MascotKind | null; onMascot: (kind: MascotKind) => void }) {
  return (
    <div className="flex animate-fade-in-up flex-col gap-4 rounded-hero border border-level-a0-line bg-level-a0-soft p-5">
      <div className="flex items-center gap-4">
        <span className="flex size-14 shrink-0 items-center justify-center rounded-full bg-surface text-4xl leading-none" aria-hidden="true">
          <span className="inline-block origin-[70%_70%] animate-wave">👋</span>
        </span>
        <div className="min-w-0">
          <p className="font-heading text-h2">
            <Hr>Dobro došli!</Hr>
          </p>
          <p className="text-body text-ink-muted">Ласкаво просимо! Кілька коротких питань — і почнемо вчити хорватську.</p>
        </div>
      </div>
      <div className="flex flex-col gap-2">
        <p className="text-label">Хто вчитиметься разом з вами?</p>
        <MascotPicker value={mascot} onChange={onMascot} label="Талісман, який вас супроводжуватиме" />
        <p className="text-caption text-ink-muted">Змінити можна будь-коли в профілі.</p>
      </div>
    </div>
  );
}

function StepTitle({ title, hint }: { title: string; hint?: string }) {
  return (
    <div className="animate-fade-in-up">
      <h2 className="font-heading text-h1">{title}</h2>
      {hint && <p className="mt-1 text-body text-ink-muted">{hint}</p>}
    </div>
  );
}

function ChoiceButton({
  selected,
  onClick,
  label,
  hint,
  emoji,
  badge,
  multi,
}: {
  selected: boolean;
  onClick: () => void;
  label: string;
  hint?: string;
  /** Знак варіанта (мета навчання) */
  emoji?: string;
  /** Бейдж справа (рівень) */
  badge?: React.ReactNode;
  multi?: boolean;
}) {
  return (
    <button
      type="button"
      role={multi ? undefined : 'radio'}
      aria-pressed={multi ? selected : undefined}
      aria-checked={multi ? undefined : selected}
      onClick={onClick}
      className={cn(
        'flex min-h-14 w-full items-center gap-3 rounded-card border bg-surface px-4 py-3 text-left transition-colors duration-150 active:scale-[0.98]',
        selected ? 'border-primary bg-primary-soft' : 'border-line hover:border-primary/40',
      )}
    >
      <span
        aria-hidden="true"
        className={cn(
          'flex size-6 shrink-0 items-center justify-center border-2',
          multi ? 'rounded-md' : 'rounded-full',
          selected ? 'border-primary bg-primary text-white' : 'border-slate-300',
        )}
      >
        {selected && <Check className="size-4" strokeWidth={3} />}
      </span>
      {emoji && (
        <span
          aria-hidden="true"
          className={cn(
            'flex size-10 shrink-0 items-center justify-center rounded-control text-2xl leading-none',
            selected ? 'bg-surface' : 'bg-surface-muted',
          )}
        >
          {emoji}
        </span>
      )}
      <span className="min-w-0 flex-1">
        <span className="block text-body font-semibold">{label}</span>
        {hint && <span className="block text-label font-normal text-ink-muted">{hint}</span>}
      </span>
      {badge && <span className="shrink-0">{badge}</span>}
    </button>
  );
}

function QuestionCard({
  question,
  number,
  total,
  disabled,
  onAnswer,
}: {
  question: PlacementQuestion;
  number: number;
  total: number;
  disabled: boolean;
  onAnswer: (chosen: number | null) => void;
}) {
  // Варіанти з хорватським текстом позначаємо lang="hr" (§98)
  const optionsAreCroatian = question.options.every((o) => !/[а-яіїєґ]/i.test(o));
  return (
    <div className="flex flex-col gap-4 animate-fade-in-up">
      <p className="text-label text-ink-muted">
        Питання {number} з {total}
      </p>
      <Card hero>
        <p className="text-body-lg">{question.prompt_ua}</p>
        {question.prompt_hr && (
          <Hr as="p" className="mt-3 font-heading text-h2 break-words">
            {question.prompt_hr}
          </Hr>
        )}
      </Card>
      <div className="flex flex-col gap-2">
        {question.options.map((o, i) => (
          <button
            key={i}
            type="button"
            disabled={disabled}
            onClick={() => onAnswer(i)}
            className="min-h-12 w-full rounded-control border border-line bg-surface px-4 py-3 text-left text-body transition-colors duration-150 hover:border-primary/50 hover:bg-primary-soft active:scale-[0.98] disabled:opacity-50"
          >
            {optionsAreCroatian ? <Hr>{o}</Hr> : o}
          </button>
        ))}
        <Button variant="tertiary" block disabled={disabled} onClick={() => onAnswer(null)}>
          Не знаю
        </Button>
      </div>
    </div>
  );
}

function PlacementResultView({
  outcome,
  chosenStart,
  onChooseStart,
  saving,
  onFinish,
}: {
  outcome: PlacementOutcome;
  chosenStart: string | null;
  onChooseStart: (level: string) => void;
  saving: boolean;
  onFinish: () => void;
}) {
  const levels = Object.entries(outcome.scoreByLevel);
  const beginner = outcome.recommendedStart === 'A0';
  const lv = levelStyle(beginner ? 'A0' : outcome.estimated);
  return (
    <div className="flex flex-col gap-4 animate-fade-in-up">
      <Confetti seed="placement" />
      <div className={cn('flex flex-col items-center rounded-hero border p-6 text-center', lv.soft, lv.line)}>
        <span className="text-5xl leading-none animate-pop" aria-hidden="true">
          🎉
        </span>
        <p className={cn('mt-3 text-label', lv.ink)}>Оцінка застосунку</p>
        <p className={cn('mt-1 font-heading text-display', lv.ink)}>{beginner ? 'Початковий рівень' : outcome.estimated}</p>
        <p className="mt-1 font-heading text-h3">{lv.name}</p>
        <p className="mt-1 text-body text-ink-muted">{lv.goal}</p>
        <p className="mt-3 text-body text-ink-muted">{CONFIDENCE_TEXT[outcome.confidence]}</p>
        <p className="mt-2 text-caption text-ink-subtle">Це не офіційний сертифікат CEFR.</p>
      </div>

      <Card>
        <h3 className="font-heading text-h3">Відповіді за рівнями</h3>
        <ul className="mt-3 flex flex-col gap-3">
          {levels.map(([level, s]) => (
            <li key={level} className="flex items-center gap-3">
              <LevelBadge level={level} className="w-10 justify-center" />
              <ProgressBar value={s.correct} max={s.total} label={`Правильні відповіді ${level}`} barClassName={levelStyle(level).bar} />
              <span className="w-12 shrink-0 text-right text-label">
                {s.correct}/{s.total}
              </span>
            </li>
          ))}
        </ul>
      </Card>

      <Card>
        <h3 className="font-heading text-h3">З чого почнемо?</h3>
        <p className="mt-1 text-body text-ink-muted">Рекомендуємо {outcome.recommendedStart}. Можна обрати інший рівень.</p>
        <div className="mt-3 grid grid-cols-5 gap-2" role="radiogroup" aria-label="Рівень, з якого почати">
          {START_LEVELS.map((l) => (
            <button
              key={l}
              type="button"
              role="radio"
              aria-checked={chosenStart === l}
              onClick={() => onChooseStart(l)}
              className={cn(
                'min-h-12 rounded-control border text-label transition-colors duration-150',
                chosenStart === l ? cn('border-transparent', levelStyle(l).solid) : 'border-line bg-surface hover:border-primary/40',
              )}
            >
              {l}
            </button>
          ))}
        </div>
        <Button block className="mt-4" onClick={onFinish} loading={saving} disabled={!chosenStart}>
          Почати з {chosenStart ?? outcome.recommendedStart}
        </Button>
      </Card>

      <details className="group rounded-card border border-line bg-surface p-5">
        <summary className="flex min-h-11 cursor-pointer list-none items-center justify-between font-heading text-h3">
          Розбір відповідей
          <ChevronDown className="size-5 transition-transform duration-150 group-open:rotate-180" aria-hidden="true" />
        </summary>
        <ol className="mt-3 flex flex-col gap-3">
          {outcome.review.map((r, i) => (
            <li key={i} className="border-t border-line pt-3 first:border-0 first:pt-0">
              <p className="text-label font-normal text-ink-muted">{r.prompt_ua}</p>
              {r.prompt_hr && (
                <Hr as="p" className="text-body font-semibold">
                  {r.prompt_hr}
                </Hr>
              )}
              <p className={cn('mt-1 text-body', r.correct ? 'text-success-ink' : 'text-danger-ink')}>
                {r.correct ? '✓ ' : '✕ '}
                {r.chosen ?? 'Не знаю'}
                {!r.correct && (
                  <span className="text-ink">
                    {' '}
                    → <strong>{r.correctOption}</strong>
                  </span>
                )}
              </p>
              {r.explanation && <p className="mt-0.5 text-label font-normal text-ink-muted">{r.explanation}</p>}
            </li>
          ))}
        </ol>
      </details>
    </div>
  );
}
