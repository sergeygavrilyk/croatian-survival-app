'use server';

import { completeLesson as completeLessonCore } from '@/lib/learning';
import { requireLearningContext, withRequestMeta } from '@/lib/server-context';
import type { EventProps } from '@/lib/analytics';

/**
 * Завершення уроку (VS-002: «completes → receives review»):
 * урок → lesson_progress, слова уроку → повторення на завтра, подія lesson_completed.
 * Логіка — у lib/learning.ts (completeLesson).
 *
 * @param context session_id, duration_ms, level — для аналітики (необов'язково)
 */
export async function completeLesson(lessonId: string, context: Pick<EventProps, 'session_id' | 'duration_ms' | 'level'> = {}) {
  const { userId, repo } = await requireLearningContext();
  return completeLessonCore(repo, {
    userId,
    lessonId,
    context: await withRequestMeta({
      session_id: context.session_id,
      duration_ms: context.duration_ms,
      level: context.level,
    }),
  });
}
