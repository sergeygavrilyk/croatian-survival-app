'use client';

import { useCallback, useTransition } from 'react';
import { useRouter } from 'next/navigation';
import ReadingView from '@/components/ReadingView';
import ErrorState from '@/components/ui/ErrorState';
import EmptyState from '@/components/ui/EmptyState';
import Button from '@/components/ui/Button';
import Skeleton from '@/components/ui/Skeleton';
import { useOfflineCopy } from '@/components/useOfflineCopy';
import { completeReading, saveReadingWord } from '@/app/actions/reading';
import { isReadingText, type ReadingText } from '@/lib/reading';

/**
 * Екран тексту для читання (client): текст приходить із сервера (app/reading/[id]/page.tsx).
 * Відкритий раз текст можна читати офлайн (копія в браузері, §76); збереження слова й результату — лише онлайн.
 */
export default function ReadingScreen({
  textId,
  initial,
  notFound,
}: {
  textId: string;
  initial: ReadingText | null;
  notFound: boolean;
}) {
  const router = useRouter();
  const [retrying, startRetry] = useTransition();
  const { data: text, checked } = useOfflineCopy('reading', textId, initial, isReadingText, { useCopy: !notFound });

  const level = text?.cefr;
  const handleComplete = useCallback(
    async (correct: number, total: number, durationMs: number) => {
      try {
        return await completeReading({ textId, correct, total, durationMs, level });
      } catch {
        return { ok: false as const, error: 'Немає інтернету — результат не збережено.' };
      }
    },
    [textId, level],
  );

  const handleSaveWord = useCallback(
    async (lemma: string) => {
      try {
        return await saveReadingWord(textId, lemma);
      } catch {
        return { ok: false as const, error: 'Немає інтернету — спробуйте пізніше.' };
      }
    },
    [textId],
  );

  if (notFound) {
    return (
      <div className="mx-auto flex min-h-screen max-w-2xl flex-col justify-center px-5">
        <EmptyState
          title="Текст не знайдено"
          text="Можливо, його оновили або перенесли. Оберіть текст зі списку."
          action={<Button href="/reading">До текстів</Button>}
        />
      </div>
    );
  }

  if (text) return <ReadingView key={text.id} text={text} onComplete={handleComplete} onSaveWord={handleSaveWord} />;

  if (!checked || retrying) return <ReadingLoading />;

  return (
    <div className="mx-auto flex min-h-screen max-w-2xl flex-col justify-center px-5">
      <ErrorState
        title="Не вдалося відкрити текст"
        text="Перевірте інтернет і спробуйте ще раз. Тексти, які ви вже відкривали, доступні й офлайн."
        onRetry={() => startRetry(() => router.refresh())}
      />
    </div>
  );
}

/** Те саме, що показує app/reading/[id]/loading.tsx, поки сервер готує текст. */
export function ReadingLoading() {
  return (
    <div
      className="mx-auto flex min-h-screen max-w-2xl flex-col gap-4 px-5 pt-[calc(1rem+env(safe-area-inset-top))]"
      role="status"
      aria-label="Завантаження тексту"
    >
      <Skeleton className="h-11 w-32 rounded-full" />
      <div className="flex items-start gap-4">
        <Skeleton className="size-16" />
        <div className="flex flex-1 flex-col gap-2">
          <Skeleton className="h-8 w-3/4" />
          <Skeleton className="h-5 w-1/2" />
        </div>
      </div>
      <Skeleton className="h-64" />
    </div>
  );
}
