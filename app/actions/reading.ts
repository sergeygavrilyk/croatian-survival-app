'use server';

import { createClient } from '@/utils/supabase/server';
import { trackEvent } from '@/app/actions/analytics';
import { writeReadingCompleted, writeReadingWord } from '@/lib/progress-write-supabase';
import { readingCompletedProps } from '@/lib/reading';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Читання (§6): слово з тексту → у тренажер (user_progress, як «зберегти слово» в уроці).
 * Шукаємо опубліковане слово словника за лемою зі словничка тексту. Права — RLS (лише свої рядки).
 * Без мережі слово кладе в чергу на телефоні ReadingScreen (lib/offline-queue.ts).
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

  const res = await writeReadingWord(supabase, user.id, clean, new Date());
  if (!res.ok) return { ok: false, error: res.error };
  await trackEvent('word_saved', { lexeme_id: res.lexemeId, source: UUID_RE.test(textId) ? 'reading' : 'reading_unknown' });
  return { ok: true };
}

/**
 * Текст прочитано, відповіді на питання перевірено → reading_progress (один рядок на текст,
 * повторне читання оновлює результат і лічильник) + подія reading_completed (§71).
 * Без мережі результат кладе в чергу на телефоні ReadingScreen (lib/offline-queue.ts).
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

  const res = await writeReadingCompleted(supabase, user.id, { textId, correct, total }, new Date());
  if (!res.ok) return { ok: false, error: res.error };

  await trackEvent('reading_completed', readingCompletedProps({ cefr: res.cefr, level: input.level, correct, total, durationMs: input.durationMs }));
  return { ok: true };
}
