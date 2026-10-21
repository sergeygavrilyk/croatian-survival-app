'use client';

import { useEffect, useState } from 'react';
import { ArrowRight, BadgeCheck, Flame, MessageCircle, Repeat, Send, X } from 'lucide-react';
import { quickTranslateToCroatian, type TranslationSource } from '@/app/actions/translate';
import { countUk } from '@/lib/format';
import { levelStyle, moduleIcon } from '@/lib/levels';
import { weekCheer, type AssessmentSuggestion } from '@/lib/today';
import { cn } from '@/lib/ui';
import type { DayActivity } from '@/lib/progress';
import AiPanel from '@/components/ui/AiPanel';
import AudioButton from '@/components/ui/AudioButton';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import IconButton from '@/components/ui/IconButton';
import LevelBadge from '@/components/ui/LevelBadge';
import ProgressBar from '@/components/ui/ProgressBar';
import Mascot from '@/components/ui/Mascot';
import { storeMascot, type MascotKind } from '@/lib/mascot';

type Day = DayActivity & { level: 0 | 1 | 2 | 3 | 4 };

export interface TodayViewProps {
  name: string;
  greeting: string;
  level: string;
  next: { id: string; title: string; moduleOrder: number } | null;
  lessonsDone: number;
  lessonsTotal: number;
  dueCount: number;
  week: Day[];
  streak: number;
  loadFailed: boolean;
  /** Талісман з профілю (null — не обрано → Pjegica) */
  mascot: MascotKind | null;
  /** Перевірка щойно пройденого модуля / середини / рівня (§60), яку ще не проходили */
  assessment: AssessmentSuggestion | null;
}

/** Насиченість клітинки за кількістю занять (зелений — «вчився», docs/DESIGN_SYSTEM.md §3). */
const LEVEL_CLASSES: Record<Day['level'], string> = {
  0: 'bg-surface-muted border border-line',
  1: 'bg-success-soft border border-success-line',
  2: 'bg-success/40',
  3: 'bg-success/70',
  4: 'bg-success',
};

/** «Сьогодні» (docs/DESIGN_SYSTEM.md §7.1): одна головна дія, повторення, «Що сказати?», активність за тиждень. */
export default function TodayView(props: TodayViewProps) {
  const { name, greeting, level, next, lessonsDone, lessonsTotal, dueCount, week, streak, loadFailed, mascot, assessment } = props;

  // Копія вибору талісмана в браузері — для святкового екрана після уроку (працює й офлайн)
  useEffect(() => {
    storeMascot(typeof window === 'undefined' ? null : window.localStorage, mascot);
  }, [mascot]);

  return (
    <div className="min-h-screen pb-28">
      <header className="mx-auto flex max-w-2xl items-start justify-between gap-4 px-5 pt-[calc(2.5rem+env(safe-area-inset-top))] pb-4">
        <div className="flex min-w-0 items-center gap-3">
          <Mascot kind={mascot} size={72} hello />
          <div className="min-w-0">
            <p className="truncate text-label font-normal text-ink-muted">
              <Hr>Bok</Hr>, {name}!
            </p>
            <h1 className="font-heading text-display">
              <Hr>{greeting}!</Hr>
            </h1>
          </div>
        </div>
        <p
          className={cn(
            'mt-1 flex shrink-0 items-center gap-1.5 rounded-full border px-3 py-1.5 text-label',
            streak > 0 ? 'border-warning-line bg-warning-soft text-warning-ink' : 'border-line bg-surface text-ink-subtle',
          )}
          aria-label={`Днів поспіль із навчанням: ${streak}`}
          title="Днів поспіль із навчанням"
        >
          <Flame className="size-4" aria-hidden="true" />
          <span className="font-heading tabular-nums">{streak}</span>
        </p>
      </header>

      <main className="mx-auto flex max-w-2xl animate-fade-in-up flex-col gap-4 px-5">
        {loadFailed && (
          <p role="alert" className="rounded-card border border-warning-line bg-warning-soft p-4 text-body text-warning-ink">
            Частину даних не вдалося завантажити. Ваш прогрес збережено — оновіть сторінку трохи згодом.
          </p>
        )}

        <ContinueCard level={level} next={next} done={lessonsDone} total={lessonsTotal} />
        {/* коли всі уроки пройдено, «Перевірити рівень» уже в головній картці */}
        {assessment && next && <AssessmentCard level={level} suggestion={assessment} />}
        <ReviewCard dueCount={dueCount} />
        <QuickTranslateCard />
        <WeekCard week={week} />
      </main>
    </div>
  );
}

// ---------------------------------------------------------------- головна дія: наступний урок
function ContinueCard({ level, next, done, total }: { level: string; next: TodayViewProps['next']; done: number; total: number }) {
  const lv = levelStyle(level);
  const icon = next ? moduleIcon(level, next.moduleOrder) : total > 0 ? '🏆' : '📚';
  return (
    <Card hero className="flex flex-col gap-4">
      <div className="flex items-start gap-4">
        <span
          className={cn('flex size-16 shrink-0 items-center justify-center rounded-card text-4xl leading-none', lv.soft)}
          aria-hidden="true"
        >
          {icon}
        </span>
        <div className="min-w-0 flex-1">
          <div className="flex items-center justify-between gap-2">
            <p className={cn('text-label', lv.ink)}>
              {next ? `Наступний урок · модуль ${level}.${next.moduleOrder}` : lv.name}
            </p>
            <LevelBadge level={level} />
          </div>
          {next && <h2 className="mt-1 font-heading text-h2 break-words">{next.title}</h2>}
        </div>
      </div>

      {next ? (
        <>
          {total > 0 && (
            <div className="flex flex-col gap-1.5">
              <ProgressBar value={done} max={total} label={`Пройдено уроків ${level}`} barClassName={lv.bar} />
              <p className="text-caption text-ink-subtle">
                Пройдено {done} з {total}
              </p>
            </div>
          )}
          <Button href={`/lesson/${next.id}`} block>
            {done > 0 ? 'Продовжити' : 'Почати'}
            <ArrowRight className="size-5" aria-hidden="true" />
          </Button>
        </>
      ) : total > 0 ? (
        <>
          <h2 className="font-heading text-h2">Усі уроки {level} пройдено! 🎉</h2>
          <p className="text-body text-ink-muted">Перевірте себе: тест покаже, що вже вмієте, і що варто повторити.</p>
          <Button href="/lessons/tests" block>
            Перевірити рівень
            <ArrowRight className="size-5" aria-hidden="true" />
          </Button>
        </>
      ) : (
        <>
          <h2 className="font-heading text-h2">Оберіть урок</h2>
          <Button href="/lessons" block>
            До уроків
            <ArrowRight className="size-5" aria-hidden="true" />
          </Button>
        </>
      )}
    </Card>
  );
}

// ---------------------------------------------------------------- перевірка модуля (§60)
function AssessmentCard({ level, suggestion }: { level: string; suggestion: AssessmentSuggestion }) {
  const lv = levelStyle(level);
  const title =
    suggestion.kind === 'module'
      ? `Модуль ${level}.${suggestion.moduleOrder} пройдено!`
      : suggestion.kind === 'mid'
        ? `Половину ${level} пройдено!`
        : `Рівень ${level} пройдено!`;
  const what =
    suggestion.kind === 'module' ? 'Перевірте себе: що вже вмієте з цього модуля' : 'Перевірте себе: що вже вмієте на цьому рівні';
  return (
    <Card className="flex flex-col gap-3">
      <div className="flex items-start gap-4">
        <span className={cn('flex size-11 shrink-0 items-center justify-center rounded-full', lv.soft, lv.ink)} aria-hidden="true">
          <BadgeCheck className="size-5" />
        </span>
        <div className="min-w-0 flex-1">
          <h2 className="font-heading text-h3 break-words">{title} 🎯</h2>
          <p className="text-body text-ink-muted">
            {what}
            {suggestion.minutes ? ` · ~${suggestion.minutes} хв` : ''}. Тест не блокує уроки.
          </p>
        </div>
      </div>
      <Button href={`/assessment/${suggestion.slug}`} variant="secondary" block>
        Пройти перевірку
        <ArrowRight className="size-5" aria-hidden="true" />
      </Button>
    </Card>
  );
}

// ---------------------------------------------------------------- повторення
function ReviewCard({ dueCount }: { dueCount: number }) {
  return (
    <Card className="flex items-center gap-4">
      <span
        className={cn(
          'flex size-11 shrink-0 items-center justify-center rounded-full',
          dueCount > 0 ? 'bg-primary-soft text-primary-ink' : 'bg-success-soft text-success-ink',
        )}
        aria-hidden="true"
      >
        {dueCount > 0 ? <Repeat className="size-5" /> : <BadgeCheck className="size-5" />}
      </span>
      <div className="min-w-0 flex-1">
        <h2 className="font-heading text-h3">Повторення</h2>
        <p className="text-body text-ink-muted">
          {dueCount > 0 ? `${countUk(dueCount, ['слово', 'слова', 'слів'])} час повторити` : 'Усе повторено. Нові з’являться завтра.'}
        </p>
      </div>
      {dueCount > 0 && (
        <Button href="/trainer" variant="secondary" size="sm" className="shrink-0">
          Повторити
        </Button>
      )}
    </Card>
  );
}

// ---------------------------------------------------------------- «Мені потрібно сказати…»
const SOURCE_TITLE: Record<TranslationSource, string> = {
  verified: 'Перевірена фраза застосунку',
  cache: 'Ваш попередній переклад · AI',
  ai: 'Переклад AI',
};

function QuickTranslateCard() {
  const [phrase, setPhrase] = useState('');
  const [result, setResult] = useState<{ text: string; source: TranslationSource } | null>(null);
  const [error, setError] = useState<{ text: string; retry: boolean } | null>(null);
  const [busy, setBusy] = useState(false);
  const [online, setOnline] = useState(true);

  // Офлайн (§76): AI недоступний — поле вимкнене з поясненням, а не зламане
  useEffect(() => {
    const update = () => setOnline(navigator.onLine);
    update();
    window.addEventListener('online', update);
    window.addEventListener('offline', update);
    return () => {
      window.removeEventListener('online', update);
      window.removeEventListener('offline', update);
    };
  }, []);

  const run = async () => {
    if (!phrase.trim() || busy) return;
    setBusy(true);
    setError(null);
    try {
      const res = await quickTranslateToCroatian(phrase);
      if (res.ok) setResult({ text: res.text, source: res.source });
      else {
        setResult(null);
        setError({ text: res.error, retry: res.retryable });
      }
    } catch {
      setResult(null);
      setError({ text: 'Немає зв’язку з сервером. Перевірте інтернет і спробуйте ще раз.', retry: true });
    } finally {
      setBusy(false);
    }
  };

  const clear = () => {
    setPhrase('');
    setResult(null);
    setError(null);
  };

  return (
    <Card className="flex flex-col gap-4">
      <div>
        <h2 className="flex items-center gap-2 font-heading text-h3">
          <MessageCircle className="size-5 text-ai-ink" aria-hidden="true" />
          Мені потрібно сказати…
        </h2>
        <p className="mt-1 text-body text-ink-muted">Напишіть українською — підкажемо, як сказати хорватською.</p>
      </div>

      <form
        onSubmit={(e) => {
          e.preventDefault();
          void run();
        }}
        className="flex items-center gap-2"
      >
        <label htmlFor="say-input" className="sr-only">
          Що потрібно сказати
        </label>
        <input
          id="say-input"
          type="text"
          value={phrase}
          onChange={(e) => setPhrase(e.target.value)}
          placeholder="Напр.: Як записатися до лікаря?"
          maxLength={300}
          disabled={!online}
          className="min-h-12 min-w-0 flex-1 rounded-control border border-line bg-surface px-4 text-body placeholder:text-ink-subtle disabled:bg-surface-muted"
        />
        <IconButton
          type="submit"
          label={busy ? 'Перекладаємо…' : 'Перекласти'}
          disabled={!online || busy || !phrase.trim()}
          className="size-12 rounded-control bg-primary text-white hover:bg-primary-hover hover:text-white"
        >
          {busy ? (
            <span className="size-5 animate-spin rounded-full border-2 border-current border-t-transparent" aria-hidden="true" />
          ) : (
            <Send className="size-5" aria-hidden="true" />
          )}
        </IconButton>
      </form>

      {!online && <p className="text-label font-normal text-ink-muted">Немає інтернету — переклад недоступний. Уроки й повторення працюють.</p>}

      {error && (
        <div role="alert" className="flex items-start gap-3 rounded-card border border-danger-line bg-danger-soft p-4 text-danger-ink">
          <div className="flex-1">
            <p className="text-body">{error.text}</p>
            {error.retry && (
              <Button variant="secondary" size="sm" className="mt-3" onClick={() => void run()} loading={busy}>
                Спробувати ще раз
              </Button>
            )}
          </div>
          <IconButton label="Закрити повідомлення" onClick={() => setError(null)} className="-m-2 text-danger-ink hover:bg-danger-line/40">
            <X className="size-5" aria-hidden="true" />
          </IconButton>
        </div>
      )}

      {result && <TranslationResult result={result} onClear={clear} />}
    </Card>
  );
}

function TranslationResult({ result, onClear }: { result: { text: string; source: TranslationSource }; onClear: () => void }) {
  const body = (
    <div className="flex items-start gap-2">
      <Hr as="p" className="min-w-0 flex-1 font-heading text-h3 break-words">
        {result.text}
      </Hr>
      <AudioButton text={result.text} />
      <IconButton label="Очистити переклад" onClick={onClear}>
        <X className="size-5" aria-hidden="true" />
      </IconButton>
    </div>
  );

  // Перевірена фраза — зелена; текст від AI — завжди в AiPanel з міткою (§11)
  if (result.source === 'verified') {
    return (
      <section aria-live="polite" className="animate-fade-in-up rounded-card border border-success-line bg-success-soft p-4">
        <p className="mb-2 flex items-center gap-1.5 text-caption font-semibold text-success-ink">
          <BadgeCheck className="size-4" aria-hidden="true" />
          {SOURCE_TITLE.verified}
        </p>
        {body}
      </section>
    );
  }
  return (
    <div aria-live="polite" className="animate-fade-in-up">
      <AiPanel title={SOURCE_TITLE[result.source]}>{body}</AiPanel>
    </div>
  );
}

// ---------------------------------------------------------------- активність за 7 днів
function WeekCard({ week }: { week: Day[] }) {
  const active = week.filter((d) => d.count > 0).length;
  return (
    <Card className="flex flex-col gap-3">
      <div className="flex items-baseline justify-between gap-3">
        <h2 className="font-heading text-h3">Останні 7 днів</h2>
        <p className="text-caption text-ink-subtle">Днів із навчанням: {active} з 7</p>
      </div>
      <p className="text-body text-ink-muted">{weekCheer(active)}</p>
      <ol className="grid grid-cols-7 gap-2">
        {week.map((d, i) => {
          const today = i === week.length - 1;
          return (
            <li key={d.date} className="flex flex-col items-center gap-1.5">
              <span className={cn('size-9 rounded-control', LEVEL_CLASSES[d.level])} aria-hidden="true" />
              <span className={cn('text-caption', today ? 'font-semibold text-ink' : 'text-ink-subtle')} aria-hidden="true">
                {d.label}
              </span>
              <span className="sr-only">
                {today ? 'Сьогодні' : d.label}: {d.count > 0 ? `занять — ${d.count}` : 'без занять'}
              </span>
            </li>
          );
        })}
      </ol>
    </Card>
  );
}
