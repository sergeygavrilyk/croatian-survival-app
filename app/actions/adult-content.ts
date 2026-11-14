'use server';

import { createClient } from '@/utils/supabase/server';

/**
 * Перемикач «Показувати контент 18+» (profiles.adult_content, M26; рішення власника 2026-11-13).
 * Вмикає модуль «18+» і слова з регістром `vulgar`. RLS: лише свій профіль.
 */
export async function setAdultContent(enabled: boolean): Promise<{ ok: true } | { ok: false; error: string }> {
  if (typeof enabled !== 'boolean') return { ok: false, error: 'Невідоме значення.' };

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб зберегти вибір.' };

  const { error } = await supabase
    .from('profiles')
    .update({ adult_content: enabled, updated_at: new Date().toISOString() })
    .eq('id', user.id);
  if (error) {
    console.error('profiles adult_content:', error.message);
    return { ok: false, error: 'Не вдалося зберегти. Перевірте інтернет і спробуйте ще раз.' };
  }
  return { ok: true };
}
