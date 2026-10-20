'use client';

import { useMemo, useRef, useState } from 'react';
import { BookCheck } from 'lucide-react';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import EmptyState from '@/components/ui/EmptyState';
import FeedbackBanner from '@/components/ui/FeedbackBanner';
import ProgressBar from '@/components/ui/ProgressBar';
import TypicalErrorCard from '@/components/TypicalErrorCard';
import { answerTypicalError } from '@/app/actions/interference';
import { track } from '@/lib/analytics-client';
import { categoryLabel, countByCategory, isSpoken, pickQuiz, quizOptions, quizQuestion, type TypicalError } from '@/lib/interference';
import { seededRandom } from '@/lib/random';
import { cn } from '@/lib/ui';

const SESSION_SIZE = 8;

/**
 * «Практика» → «Помилки» → «Типові помилки українців» (§19): вправа «Яке речення правильне?».
 * Після відповіді — картка з поясненням. Неправильна відповідь додає помилку в «Мої помилки»
 * (її там треба буде скласти з плиток), щоб вона повторилась пізніше.
 */
export default function TypicalErrorsQuiz({ items, savedIds, seed }: { items: TypicalError[]; savedIds: string[]; seed: string }) {
  const [category, setCategory] = useState<string | null>(null);
  const [round, setRound] = useState(0);
  const [index, setIndex] = useState(0);
  const [choice, setChoice] = useState<boolean | null>(null);
  const [correctCount, setCorrectCount] = useState(0);
  const [saved, setSaved] = useState<'saved' | 'failed' | null>(null);
  const [savedNow, setSavedNow] = useState<Set<string>>(() => new Set(savedIds));
  const shownAtRef = useRef(Date.now());
  const sessionStartRef = useRef(Date.now());
  const startedRef = useRef(false);

  const counts = useMemo(() => countByCategory(items), [items]);
  // Новий набір — при зміні категорії або «Ще раз» (round); savedNow навмисно не в залежностях,
  // щоб набір не змінювався посеред сесії
  const session = useMemo(
    // seed від сервера: набір і варіанти однакові на сервері й у браузері (інакше помилка React #418)
    () => pickQuiz(items, { category, exclude: savedNow, size: SESSION_SIZE, random: seededRandom(`${seed}:${category ?? 'all'}:${round}`) }),
    // eslint-disable-next-line react-hooks/exhaustive-deps
    [items, category, round, seed],
  );
  const item = session[index];
  const options = useMemo(() => (item ? quizOptions(item, seededRandom(`${seed}:${item.id}:${round}`)) : []), [item, seed, round]);

  if (items.length === 0) {
    return (
      <EmptyState
        icon={<BookCheck className="size-6" aria-hidden="true" />}
        title="Каталог помилок ще порожній"
        text="Тут з’являться типові помилки українців у хорватській: оманливі слова, відмінки, порядок слів."
      />
    );
  }

  const restart = (nextCategory: string | null = category) => {
    setCategory(nextCategory);
    setRound((r) => r + 1);
    setIndex(0);
    setChoice(null);
    setSaved(null);
    setCorrectCount(0);
    startedRef.current = false;
  };

  const answer = async (correct: boolean) => {
    if (!item || choice !== null) return;
    if (!startedRef.current) {
      startedRef.current = true;
      sessionStartRef.current = Date.now();
      track('review_started', { count: session.length, source: 'typical_errors' });
    }
    setChoice(correct);
    if (correct) setCorrectCount((c) => c + 1);
    const res = await answerTypicalError(item.id, correct, Date.now() - shownAtRef.current);
    if (!res.ok) setSaved('failed');
    else if (res.savedToMistakes) {
      setSaved('saved');
      setSavedNow((s) => new Set(s).add(item.id));
    }
  };

  const next = () => {
    if (index + 1 >= session.length) {
      track('review_completed', {
        count: session.length,
        correct_count: correctCount,
        duration_ms: Date.now() - sessionStartRef.current,
        source: 'typical_errors',
        success: true,
      });
    }
    setIndex((i) => i + 1);
    setChoice(null);
    setSaved(null);
    shownAtRef.current = Date.now();
  };

  const chips = (
    <div className="-mx-4 flex gap-2 overflow-x-auto px-4 pb-1" role="group" aria-label="Категорія помилок">
      {[{ category: null as string | null, count: items.length }, ...counts].map((c) => {
        const active = c.category === category;
        return (
          <button
            key={c.category ?? 'all'}
            type="button"
            aria-pressed={active}
            onClick={() => restart(c.category)}
            className={cn(
              'min-h-11 shrink-0 rounded-full border px-3 text-label transition-colors duration-150',
              active ? 'border-primary bg-primary-soft text-primary-ink' : 'border-line bg-surface text-ink-muted hover:text-ink',
            )}
          >
            {c.category ? categoryLabel(c.category) : 'Усі'} · {c.count}
          </button>
        );
      })}
    </div>
  );

  // Підсумок
  if (!item) {
    return (
      <div className="flex flex-col gap-4">
        {chips}
        <Card className="flex flex-col gap-4 text-center">
          <p className="font-heading text-h2">Готово!</p>
          <p className="text-body text-ink-muted">
            Правильно: {correctCount} з {session.length}. Помилки, у яких ви помилились, — у «Моїх помилках»: там їх треба буде скласти
            правильно.
          </p>
          <div className="flex flex-col gap-2 sm:flex-row">
            <Button block onClick={() => restart()}>
              Ще раз
            </Button>
            <Button block variant="secondary" href="/mistakes">
              Мої помилки
            </Button>
          </div>
        </Card>
      </div>
    );
  }

  const spoken = isSpoken(item.category);

  return (
    <div className="flex flex-col gap-4">
      {chips}
      <div className="flex items-center gap-3">
        <ProgressBar value={index} max={session.length} label="Прогрес вправи" className="flex-1" />
        <span className="text-label text-ink-muted">
          {index + 1} / {session.length}
        </span>
      </div>

      <Card className="flex flex-col gap-1">
        <p className="text-label text-ink-muted">{categoryLabel(item.category)}</p>
        <p className="font-heading text-h3">{quizQuestion(item.category)}</p>
      </Card>

      <div className="flex flex-col gap-2" role="group" aria-label="Варіанти відповіді">
        {options.map((o) => {
          const picked = choice !== null;
          return (
            <button
              key={o.text}
              type="button"
              disabled={picked}
              onClick={() => void answer(o.correct)}
              lang={spoken ? undefined : 'hr'}
              className={cn(
                'min-h-14 rounded-control border-2 bg-surface px-4 py-3 text-left text-body-lg transition-colors duration-150',
                !picked && 'border-line hover:border-primary',
                picked && o.correct && 'border-success-line bg-success-soft text-success-ink',
                picked && !o.correct && 'border-danger-line bg-danger-soft text-danger-ink line-through decoration-danger-line',
              )}
            >
              {o.text}
            </button>
          );
        })}
      </div>

      {choice !== null && (
        <>
          <FeedbackBanner kind={choice ? 'exact' : 'wrong'} expected={choice ? undefined : item.correct_text} />
          <TypicalErrorCard error={item} heading={null} />
          {saved === 'saved' && (
            <p className="text-label text-ink-muted" role="status">
              Додано в «Мої помилки» — повторимо пізніше.
            </p>
          )}
          {saved === 'failed' && (
            <p className="text-label text-danger-ink" role="status">
              Не вдалося зберегти відповідь. Перевірте інтернет.
            </p>
          )}
          <Button block onClick={next}>
            {index + 1 >= session.length ? 'Завершити' : 'Далі'}
          </Button>
        </>
      )}
    </div>
  );
}
