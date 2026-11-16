'use server';

import { createClient } from '@/utils/supabase/server';
import { trackEvent } from '@/app/actions/analytics';
import { writeMistakeRating } from '@/lib/progress-write-supabase';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Відповідь на вправу «Виправте помилку»: оновлює розклад повторення (lib/mistakes.ts через
 * writeMistakeRating — те саме приймає офлайн-черга) і пише подію exercise_completed. Права — RLS: лише власна помилка.
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

  const res = await writeMistakeRating(supabase, user.id, errorId, Boolean(correct), new Date());
  if (!res.ok) return { ok: false, error: res.error };
  if (!res.changed) return { ok: true, resolved: res.resolved };

  await trackEvent('exercise_completed', {
    exercise_type: 'fix_mistake',
    source: 'mistakes',
    success: Boolean(correct),
    attempt: res.attempt,
    duration_ms: typeof durationMs === 'number' && durationMs >= 0 ? Math.round(durationMs) : undefined,
  });
  return { ok: true, resolved: res.resolved };
}
