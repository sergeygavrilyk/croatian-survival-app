'use server';

import { createClient } from '@/utils/supabase/server';
import { trackEvent } from '@/app/actions/analytics';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Читання (§6): слово з тексту → у тренажер (user_progress, як «зберегти слово» в уроці).
 * Шукаємо опубліковане слово словника за лемою зі словничка тексту. Права — RLS (лише свої рядки).
 */
export async function saveReadingWord(
  textId: string,
  lemma: string,
): Promise<{ ok: true } | { ok: false; error: string }> {
  const clean = typeof lemma === 'string' ? lemma.trim() : '';
  if (!clean || clean.length > 80) return { ok: false, error: 'Слово не знайдено.' };
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб зберігати слова.' };

  const { data: lexeme } = await supabase
    .from('lexemes')
    .select('id')
    .ilike('lemma', clean.replace(/[%_\\]/g, (c) => `\\${c}`))
    .eq('status', 'PUBLISHED')
    .order('created_at', { ascending: true })
    .limit(1)
    .maybeSingle();
  if (!lexeme) return { ok: false, error: 'Цього слова ще немає у словнику застосунку.' };

  const { error } = await supabase.from('user_progress').upsert(
    {
      user_id: user.id,
      lexeme_id: lexeme.id as string,
      interval_days: 0,
      repetition_count: 0,
      next_review_date: new Date().toISOString(),
    },
    { onConflict: 'user_id,lexeme_id', ignoreDuplicates: true }, // уже збережене слово не скидаємо
  );
  if (error) {
    console.error('saveReadingWord:', error.message);
    return { ok: false, error: 'Не вдалося зберегти слово. Перевірте інтернет.' };
  }
  await trackEvent('word_saved', { lexeme_id: lexeme.id as string, source: UUID_RE.test(textId) ? 'reading' : 'reading_unknown' });
  return { ok: true };
}

/**
 * Текст прочитано, відповіді на питання перевірено → reading_progress (один рядок на текст,
 * повторне читання оновлює результат і лічильник) + подія reading_completed (§71).
 */
export async function completeReading(input: {
  textId: string;
  correct: number;
  total: number;
  durationMs?: number;
  level?: string;
}): Promise<{ ok: true } | { ok: false; error: string }> {
  const { textId } = input;
  const total = Number.isInteger(input.total) ? Math.max(0, Math.min(input.total, 20)) : 0;
  const correct = Number.isInteger(input.correct) ? Math.max(0, Math.min(input.correct, total)) : 0;
  if (!UUID_RE.test(textId)) return { ok: false, error: 'Текст не знайдено.' };
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб зберегти прогрес.' };

  const { data: text } = await supabase.from('reading_texts').select('id, cefr').eq('id', textId).eq('status', 'PUBLISHED').maybeSingle();
  if (!text) return { ok: false, error: 'Текст не знайдено.' };

  const { data: existing } = await supabase
    .from('reading_progress')
    .select('id, read_count')
    .eq('user_id', user.id)
    .eq('text_id', textId)
    .maybeSingle();
  const now = new Date().toISOString();
  const { error } = existing
    ? await supabase
        .from('reading_progress')
        .update({ correct_count: correct, question_count: total, read_count: ((existing.read_count as number) ?? 1) + 1, completed_at: now })
        .eq('id', existing.id as string)
    : await supabase.from('reading_progress').insert({ user_id: user.id, text_id: textId, correct_count: correct, question_count: total, completed_at: now });
  if (error) {
    console.error('completeReading:', error.message);
    return { ok: false, error: 'Не вдалося зберегти прогрес. Перевірте інтернет.' };
  }

  await trackEvent('reading_completed', {
    skill: 'reading',
    source: 'reading',
    level: (text.cefr as string) ?? input.level,
    success: total > 0 ? correct / total >= 0.67 : true,
    count: total,
    correct_count: correct,
    duration_ms: typeof input.durationMs === 'number' && input.durationMs >= 0 ? Math.round(input.durationMs) : undefined,
  });
  return { ok: true };
}
