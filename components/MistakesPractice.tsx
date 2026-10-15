'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { CircleCheck, MessagesSquare } from 'lucide-react';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import AiPanel from '@/components/ui/AiPanel';
import EmptyState from '@/components/ui/EmptyState';
import FeedbackBanner from '@/components/ui/FeedbackBanner';
import ProgressBar from '@/components/ui/ProgressBar';
import { rateMistake } from '@/app/actions/mistakes';
import { track } from '@/lib/analytics-client';
import { answerTiles, checkSentence, distractorTiles, shuffleTiles, type SentenceVerdict } from '@/lib/mistakes';
import { countUk } from '@/lib/format';
import { cn } from '@/lib/ui';

export interface MistakeItem {
  id: string;
  original: string;
  corrected: string;
  explanation: string | null;
  /** Звідки помилка: roleplay — рольова гра, exercise — вправа «Типові помилки» */
  source?: string | null;
}

interface Tile {
  key: string;
  text: string;
}

type Result = SentenceVerdict | 'gave_up';

function buildTiles(item: MistakeItem): Tile[] {
  const words = [...answerTiles(item.corrected), ...distractorTiles(item.original, item.corrected)];
  return shuffleTiles(words.map((text, i) => ({ key: `${i}:${text}`, text })));
}

/**
 * Вправа «Виправте помилку»: користувач бачить, що сказав у рольовій грі,
 * і складає правильний варіант із плиток (серед них — його ж неправильні слова).
 */
export default function MistakesPractice({
  items,
  waitingCount,
  resolvedCount,
}: {
  items: MistakeItem[];
  waitingCount: number;
  resolvedCount: number;
}) {
  const router = useRouter();
  const [index, setIndex] = useState(0);
  const [picked, setPicked] = useState<Tile[]>([]);
  const [result, setResult] = useState<Result | null>(null);
  const [correctCount, setCorrectCount] = useState(0);
  const [masteredNow, setMasteredNow] = useState(0);
  const [saveFailed, setSaveFailed] = useState(false);
  const shownAtRef = useRef(Date.now());
  const sessionStartRef = useRef(Date.now());

  const item = items[index];
  const tiles = useMemo(() => (item ? buildTiles(item) : []), [item]);
  const pool = tiles.filter((t) => !picked.some((p) => p.key === t.key));
  const itemsKey = items.map((i) => i.id).join(',');

  // Нова сесія (перше відкриття або «Ще раз» з новим набором помилок)
  useEffect(() => {
    if (!itemsKey) return;
    sessionStartRef.current = Date.now();
    shownAtRef.current = Date.now();
    track('review_started', { count: itemsKey.split(',').length, source: 'mistakes' });
  }, [itemsKey]);

  if (items.length === 0) {
    if (waitingCount === 0 && resolvedCount === 0) {
      return (
        <EmptyState
          icon={<MessagesSquare className="size-6" aria-hidden="true" />}
          title="Помилок поки немає"
          text="Тут з’являться помилки з рольової гри з AI і з вправи «Типові помилки» — їх можна буде виправити й запам’ятати."
          action={<Button href="/mistakes/typical">Типові помилки</Button>}
        />
      );
    }
    return (
      <EmptyState
        icon={<CircleCheck className="size-6" aria-hidden="true" />}
        title="На сьогодні все"
        text={[
          waitingCount > 0 ? `Наступне повторення — завтра: ${countUk(waitingCount, ['помилка', 'помилки', 'помилок'])}.` : null,
          resolvedCount > 0 ? `Засвоєно: ${resolvedCount}.` : null,
        ].filter(Boolean).join(' ')}
        action={<Button href="/situations">Нова рольова гра</Button>}
      />
    );
  }

  // Підсумок сесії
  if (!item) {
    return (
      <Card className="flex flex-col gap-4 text-center">
        <p className="font-heading text-h2">Готово!</p>
        <p className="text-body text-ink-muted">
          Правильно: {correctCount} з {items.length}.
          {masteredNow > 0 && ` Засвоєно сьогодні: ${masteredNow}.`}
          {' '}Помилки, з якими ще було складно, повернуться пізніше.
        </p>
        <div className="flex flex-col gap-2 sm:flex-row">
          <Button
            block
            onClick={() => {
              // Нові «на сьогодні» помилки (неправильні щойно — теж) підтягне сервер
              setIndex(0);
              setPicked([]);
              setResult(null);
              setCorrectCount(0);
              setMasteredNow(0);
              router.refresh();
            }}
          >
            Ще раз
          </Button>
          <Button block variant="secondary" href="/trainer">До тренажера</Button>
        </div>
      </Card>
    );
  }

  const answer = picked.map((t) => t.text).join(' ');

  const finish = async (verdict: Result) => {
    const correct = verdict === 'exact' || verdict === 'diacritics';
    setResult(verdict);
    if (correct) setCorrectCount((c) => c + 1);
    const res = await rateMistake(item.id, correct, Date.now() - shownAtRef.current);
    if (!res.ok) setSaveFailed(true);
    else if (res.resolved && correct) setMasteredNow((m) => m + 1);
  };

  const next = () => {
    const nextIndex = index + 1;
    if (nextIndex >= items.length) {
      track('review_completed', {
        count: items.length,
        correct_count: correctCount,
        duration_ms: Date.now() - sessionStartRef.current,
        source: 'mistakes',
        success: true,
      });
    }
    setIndex(nextIndex);
    setPicked([]);
    setResult(null);
    shownAtRef.current = Date.now();
  };

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center gap-3">
        <ProgressBar value={index} max={items.length} label="Прогрес повторення помилок" className="flex-1" />
        <span className="text-label text-ink-muted">{index + 1} / {items.length}</span>
      </div>

      <Card className="flex flex-col gap-2">
        <p className="text-label text-ink-muted">{item.source === 'exercise' ? 'Типова помилка:' : 'Ви сказали в рольовій грі:'}</p>
        <Hr as="p" className="text-body-lg text-ink-muted line-through decoration-danger-line">{item.original}</Hr>
        <p className="mt-2 font-heading text-h3">Складіть правильно</p>
      </Card>

      {/* Відповідь */}
      <div
        aria-live="polite"
        className={cn(
          'min-h-20 rounded-card border-2 bg-surface p-3 flex flex-wrap gap-2 items-center',
          result === null ? 'border-line' : result === 'exact' || result === 'diacritics' ? 'border-success-line' : 'border-danger-line',
        )}
      >
        {picked.length === 0 && <span className="text-label font-normal text-ink-subtle">Натискайте слова нижче…</span>}
        {picked.map((t) => (
          <button
            key={t.key}
            type="button"
            disabled={result !== null}
            onClick={() => setPicked((p) => p.filter((x) => x.key !== t.key))}
            className="min-h-11 rounded-control bg-primary-soft px-3 text-body text-primary-ink"
            lang="hr"
          >
            {t.text}
          </button>
        ))}
      </div>

      {/* Плитки */}
      {result === null && (
        <div className="flex flex-wrap justify-center gap-2">
          {pool.map((t) => (
            <button
              key={t.key}
              type="button"
              onClick={() => setPicked((p) => [...p, t])}
              className="min-h-11 rounded-control border border-line bg-surface px-3 text-body shadow-sm"
              lang="hr"
            >
              {t.text}
            </button>
          ))}
        </div>
      )}

      {result === null ? (
        <div className="flex flex-col gap-2">
          <Button block disabled={picked.length === 0} onClick={() => void finish(checkSentence(answer, item.corrected))}>
            Перевірити
          </Button>
          <Button block variant="tertiary" onClick={() => void finish('gave_up')}>
            Не знаю — показати
          </Button>
        </div>
      ) : (
        <div className="flex flex-col gap-3">
          <FeedbackBanner kind={result} expected={item.corrected}>
            <AudioButton text={item.corrected} />
          </FeedbackBanner>
          {item.explanation && (
            <AiPanel title="Чому так">
              <p className="text-body">{item.explanation}</p>
            </AiPanel>
          )}
          {saveFailed && (
            <p role="alert" className="text-label font-normal text-danger-ink">
              Не вдалося зберегти відповідь — перевірте інтернет. Помилка повториться наступного разу.
            </p>
          )}
          <Button block onClick={next}>Далі</Button>
        </div>
      )}
    </div>
  );
}
