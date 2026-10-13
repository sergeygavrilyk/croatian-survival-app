'use server';

import { createClient } from '@/utils/supabase/server';
import { trackEvent } from '@/app/actions/analytics';
import { scheduleMistake } from '@/lib/mistakes';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Відповідь на вправу «Виправте помилку»: оновлює розклад повторення (lib/mistakes.ts)
 * і пише подію exercise_completed. Права — RLS: лише власна помилка.
 */
export async function rateMistake(
  errorId: string,
  correct: boolean,
  durationMs?: number,
): Promise<{ ok: true; resolved: boolean } | { ok: false; error: string }> {
  if (!UUID_RE.test(errorId)) return { ok: false, error: 'Помилку не знайдено.' };
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб зберегти прогрес.' };

  const { data: row, error: readError } = await supabase
    .from('user_errors')
    .select('id, correct_streak, review_count, resolved_at')
    .eq('id', errorId)
    .eq('user_id', user.id)
    .maybeSingle();
  if (readError || !row) return { ok: false, error: 'Помилку не знайдено.' };
  if (row.resolved_at) return { ok: true, resolved: true };

  const now = new Date();
  const next = scheduleMistake(
    { correctStreak: row.correct_streak as number, reviewCount: row.review_count as number },
    Boolean(correct),
    now,
  );
  const { error } = await supabase
    .from('user_errors')
    .update({
      correct_streak: next.correctStreak,
      review_count: next.reviewCount,
      next_review_at: next.nextReviewAt.toISOString(),
      last_reviewed_at: now.toISOString(),
      resolved_at: next.resolvedAt ? next.resolvedAt.toISOString() : null,
    })
    .eq('id', errorId);
  if (error) {
    console.error('rateMistake:', error.message);
    return { ok: false, error: 'Не вдалося зберегти відповідь. Перевірте інтернет.' };
  }

  await trackEvent('exercise_completed', {
    exercise_type: 'fix_mistake',
    source: 'mistakes',
    success: Boolean(correct),
    attempt: next.reviewCount,
    duration_ms: typeof durationMs === 'number' && durationMs >= 0 ? Math.round(durationMs) : undefined,
  });
  return { ok: true, resolved: Boolean(next.resolvedAt) };
}
