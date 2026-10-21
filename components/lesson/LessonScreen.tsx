'use client';

import { useCallback, useEffect, useRef, useTransition } from 'react';
import { useRouter } from 'next/navigation';
import LessonPlayer from '@/components/lesson/LessonPlayer';
import ErrorState from '@/components/ui/ErrorState';
import EmptyState from '@/components/ui/EmptyState';
import Button from '@/components/ui/Button';
import { useOfflineCopy } from '@/components/useOfflineCopy';
import { completeLesson } from '@/app/actions/progress';
import { track, getSessionId } from '@/lib/analytics-client';
import { isLessonContent, type LessonContent } from '@/lib/lesson-content';

/**
 * Екран уроку (client): дані приходять із сервера (app/(main)/lesson/[id]/page.tsx).
 * Офлайн (§76): кожне успішне відкриття зберігає копію уроку в браузері; якщо сервер не відповів —
 * показуємо останню збережену копію (useOfflineCopy). Версій кешу немає — копію перезаписують свіжі дані.
 */
export default function LessonScreen({
  lessonId,
  initial,
  notFound,
}: {
  lessonId: string;
  initial: LessonContent | null;
  notFound: boolean;
}) {
  const router = useRouter();
  const [retrying, startRetry] = useTransition();
  const { data: content, checked } = useOfflineCopy('lesson', lessonId, initial, isLessonContent, { useCopy: !notFound });

  const startedAtRef = useRef(0); // ставимо, коли урок відкрито (ефект нижче)
  const startTrackedRef = useRef<string | null>(null);

  // Аналітика: урок відкрито (один раз на урок, коли дані є)
  useEffect(() => {
    if (!content || startTrackedRef.current === lessonId) return;
    startTrackedRef.current = lessonId;
    startedAtRef.current = Date.now();
    track('lesson_started', { lesson_id: lessonId, level: content.lesson.level_code ?? undefined });
  }, [content, lessonId]);

  // Завершення уроку: прогрес уроку + слова уроку в повторення (SRS). Результат (нові слова, серія 🔥) —
  // для святкового екрана; помилку показує екран підсумку.
  const handleComplete = useCallback(async () => {
    return completeLesson(lessonId, {
      session_id: getSessionId(),
      duration_ms: Date.now() - startedAtRef.current,
      level: content?.lesson.level_code ?? undefined,
    });
  }, [lessonId, content]);

  if (notFound) {
    return (
      <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-4">
        <EmptyState
          title="Урок не знайдено"
          text="Можливо, його оновили або перенесли. Оберіть урок зі списку."
          action={<Button href="/lessons">До уроків</Button>}
        />
      </div>
    );
  }

  if (content) return <LessonPlayer key={content.lesson.id} content={content} onComplete={handleComplete} />;

  if (!checked || retrying) return <LessonLoading />;

  return (
    <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-4">
      <ErrorState
        title="Не вдалося відкрити урок"
        text="Перевірте інтернет і спробуйте ще раз. Уроки, які ви вже відкривали, доступні й офлайн."
        onRetry={() => startRetry(() => router.refresh())}
      />
    </div>
  );
}

/** Те саме, що показує app/(main)/lesson/[id]/loading.tsx, поки сервер готує урок. */
export function LessonLoading() {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center gap-4" role="status">
      <div className="size-10 rounded-full border-4 border-primary-soft border-t-primary animate-spin" aria-hidden="true" />
      <p className="text-body text-ink-muted">Завантаження уроку…</p>
    </div>
  );
}
