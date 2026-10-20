'use server';

import { createClient } from '@/utils/supabase/server';
import { parseMascot } from '@/lib/mascot';

/** Зберегти талісмана в профіль (Pjegica, Šime або Točka). RLS: лише свій профіль. */
export async function setMascot(value: string): Promise<{ ok: true } | { ok: false; error: string }> {
  const mascot = parseMascot(value);
  if (!mascot) return { ok: false, error: 'Невідомий талісман.' };

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб зберегти вибір.' };

  const { error } = await supabase.from('profiles').update({ mascot, updated_at: new Date().toISOString() }).eq('id', user.id);
  if (error) {
    console.error('profiles mascot:', error.message);
    return { ok: false, error: 'Не вдалося зберегти. Перевірте інтернет і спробуйте ще раз.' };
  }
  return { ok: true };
}
