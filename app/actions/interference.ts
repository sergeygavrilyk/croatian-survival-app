'use server';

import { createClient } from '@/utils/supabase/server';
import { trackEvent } from '@/app/actions/analytics';
import { canPractiseAsSentence, errorTypeFor, shortExplanation } from '@/lib/interference';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Відповідь у вправі «Типові помилки» (§19). Неправильна відповідь додає типову помилку
 * в «Мої помилки» (user_errors, source = 'exercise') або знову відкриває її, якщо вона вже була.
 * Права — RLS: користувач додає й змінює лише свої помилки. Аналітика — exercise_completed.
 */
export async function answerTypicalError(
  errorId: string,
  correct: boolean,
  durationMs?: number,
): Promise<{ ok: true; savedToMistakes: boolean } | { ok: false; error: string }> {
  if (!UUID_RE.test(errorId)) return { ok: false, error: 'Помилку не знайдено.' };
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб зберегти прогрес.' };

  const { data: typical, error: readError } = await supabase
    .from('linguistic_errors')
    .select('id, code, category, title_ua, incorrect_text, correct_text, explanation_ua')
    .eq('id', errorId)
    .eq('status', 'PUBLISHED')
    .maybeSingle();
  if (readError || !typical) return { ok: false, error: 'Помилку не знайдено.' };

  await trackEvent('exercise_completed', {
    exercise_type: 'typical_error',
    source: 'interference',
    skill: typical.category as string,
    success: Boolean(correct),
    duration_ms: typeof durationMs === 'number' && durationMs >= 0 ? Math.round(durationMs) : undefined,
  });

  if (correct || !canPractiseAsSentence({ category: typical.category as string, correct_text: typical.correct_text as string })) {
    return { ok: true, savedToMistakes: false };
  }

  const { data: existing } = await supabase
    .from('user_errors')
    .select('id')
    .eq('user_id', user.id)
    .eq('linguistic_error_id', errorId)
    .maybeSingle();

  const { error } = existing
    ? await supabase
        .from('user_errors')
        .update({ resolved_at: null, correct_streak: 0, next_review_at: null })
        .eq('id', existing.id as string)
    : await supabase.from('user_errors').insert({
        user_id: user.id,
        source: 'exercise',
        original_text: typical.incorrect_text,
        corrected_text: typical.correct_text,
        explanation_ua: shortExplanation({ title_ua: typical.title_ua as string, explanation_ua: typical.explanation_ua as string }),
        error_type: errorTypeFor(typical.category as string),
        linguistic_error_id: errorId,
      });
  if (error) {
    console.error('answerTypicalError:', error.message);
    return { ok: false, error: 'Не вдалося зберегти помилку для повторення. Перевірте інтернет.' };
  }
  return { ok: true, savedToMistakes: true };
}
