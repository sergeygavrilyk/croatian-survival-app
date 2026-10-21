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
import SessionDone from '@/components/ui/SessionDone';
import { rateMistake } from '@/app/actions/mistakes';
import { track } from '@/lib/analytics-client';
import { answerTiles, checkSentence, distractorTiles, shuffleTiles, type SentenceVerdict } from '@/lib/mistakes';
import { seededRandom } from '@/lib/random';
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

/** Плитки перемішуються з seed сторінки — однаково на сервері й у браузері (інакше помилка React #418). */
function buildTiles(item: MistakeItem, seed: string): Tile[] {
  const words = [...answerTiles(item.corrected), ...distractorTiles(item.original, item.corrected)];
  return shuffleTiles(words.map((text, i) => ({ key: `${i}:${text}`, text })), seededRandom(`${seed}:${item.id}`));
}

/**
 * Вправа «Виправте помилку»: користувач бачить, що сказав у рольовій грі,
 * і складає правильний варіант із плиток (серед них — його ж неправильні слова).
 */
export default function MistakesPractice({
  items,
  waitingCount,
  resolvedCount,
  seed,
}: {
  items: MistakeItem[];
  waitingCount: number;
  resolvedCount: number;
  /** Випадковий seed від сервера для перемішування плиток */
  seed: string;
}) {
  const router = useRouter();
  const [index, setIndex] = useState(0);
  const [picked, setPicked] = useState<Tile[]>([]);
  const [result, setResult] = useState<Result | null>(null);
  const [correctCount, setCorrectCount] = useState(0);
  const [masteredNow, setMasteredNow] = useState(0);
  const [saveFailed, setSaveFailed] = useState(false);
  const shownAtRef = useRef(0); // ставимо в ефекті нижче, коли сесія почалася
  const sessionStartRef = useRef(0);

  const item = items[index];
  const tiles = useMemo(() => (item ? buildTiles(item, seed) : []), [item, seed]);
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
        title="На сьогодні все 🎉"
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
      <SessionDone
        correct={correctCount}
        total={items.length}
        actions={
          <>
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
          </>
        }
      >
        Виправили {correctCount} з {items.length}.
        {masteredNow > 0 && ` Засвоєно сьогодні: ${masteredNow} 🏆.`}
        {' '}Помилки, з якими ще було складно, повернуться пізніше.
      </SessionDone>
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
        <span className="font-heading text-label tabular-nums text-ink-muted">{index + 1} / {items.length}</span>
      </div>

      <Card className="flex flex-col gap-3">
        <div className="flex items-center gap-3">
          <span className="flex size-12 shrink-0 items-center justify-center rounded-card bg-danger-soft text-2xl leading-none" aria-hidden="true">
            {item.source === 'exercise' ? '🧩' : '💬'}
          </span>
          <p className="text-label text-ink-muted">{item.source === 'exercise' ? 'Типова помилка:' : 'Ви сказали в рольовій грі:'}</p>
        </div>
        <Hr as="p" className="text-body-lg text-ink-muted line-through decoration-danger-line">{item.original}</Hr>
        <p className="font-heading text-h3">Складіть правильно</p>
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
