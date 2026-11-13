'use server';

import { createClient } from '@/utils/supabase/server';
import { trackEvent } from '@/app/actions/analytics';
import { isWordCategory } from '@/lib/lexeme-labels';
import { isUuid, newWordProgress } from '@/lib/word-save';

/**
 * Словник: слово → у повторення (тренажер), як «Зберегти в тренажер» у читанні.
 * Лише опубліковане слово; уже збережене не скидаємо. Права — RLS (лише свої рядки user_progress).
 * `category` — фільтр «Категорія», з якого додали слово (лише для аналітики; невідоме значення не записуємо).
 */
export async function saveDictionaryWord(lexemeId: string, category?: string): Promise<{ ok: true } | { ok: false; error: string }> {
  if (!isUuid(lexemeId)) return { ok: false, error: 'Слово не знайдено.' };
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб додавати слова.' };

  const { data: lexeme } = await supabase
    .from('lexemes')
    .select('id, cefr')
    .eq('id', lexemeId)
    .eq('status', 'PUBLISHED')
    .maybeSingle();
  if (!lexeme) return { ok: false, error: 'Цього слова вже немає у словнику.' };

  const { error } = await supabase
    .from('user_progress')
    .upsert(newWordProgress(user.id, lexemeId, new Date()), { onConflict: 'user_id,lexeme_id', ignoreDuplicates: true });
  if (error) {
    console.error('saveDictionaryWord:', error.message);
    return { ok: false, error: 'Не вдалося додати слово. Перевірте інтернет.' };
  }
  await trackEvent('word_saved', {
    lexeme_id: lexemeId,
    source: 'dictionary',
    level: (lexeme.cefr as string) ?? undefined,
    category: isWordCategory(category) ? category : undefined,
  });
  return { ok: true };
}
