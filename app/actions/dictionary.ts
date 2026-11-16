'use server';

import { createClient } from '@/utils/supabase/server';
import { trackEvent } from '@/app/actions/analytics';
import { isWordCategory } from '@/lib/lexeme-labels';
import { isUuid } from '@/lib/word-save';
import { writeDictionaryWord } from '@/lib/progress-write-supabase';

/**
 * Словник: слово → у повторення (тренажер), як «Зберегти в тренажер» у читанні.
 * Лише опубліковане слово; уже збережене не скидаємо. Права — RLS (лише свої рядки user_progress).
 * `category` — фільтр «Категорія», з якого додали слово (лише для аналітики; невідоме значення не записуємо).
 * Без мережі слово кладе в чергу на телефоні сторінка словника (lib/offline-queue.ts).
 */
export async function saveDictionaryWord(lexemeId: string, category?: string): Promise<{ ok: true } | { ok: false; error: string }> {
  if (!isUuid(lexemeId)) return { ok: false, error: 'Слово не знайдено.' };
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб додавати слова.' };

  const res = await writeDictionaryWord(supabase, user.id, lexemeId, new Date());
  if (!res.ok) return { ok: false, error: res.error };
  await trackEvent('word_saved', {
    lexeme_id: lexemeId,
    source: 'dictionary',
    level: res.cefr ?? undefined,
    category: isWordCategory(category) ? category : undefined,
  });
  return { ok: true };
}
