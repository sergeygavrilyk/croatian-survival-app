'use server';

import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';

export async function markTopicAsCompleted(topicId: string) {
  const cookieStore = await cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll: () => cookieStore.getAll(), setAll: () => {} } }
  );

  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) throw new Error('Не авторизовано');

  // 1. Перевіряємо, чи є вже запис про цю тему
  const { data: existing } = await supabase
    .from('topic_progress')
    .select('id')
    .eq('user_id', user.id)
    .eq('topic_id', topicId)
    .maybeSingle();

  if (existing) {
    // 2. Якщо є — оновлюємо дату завершення
    await supabase.from('topic_progress').update({
      status: 'completed',
      completed_at: new Date().toISOString()
    }).eq('id', existing.id);
  } else {
    // 3. Якщо немає — створюємо новий запис
    await supabase.from('topic_progress').insert({
      user_id: user.id,
      topic_id: topicId,
      status: 'completed',
      completed_at: new Date().toISOString()
    });
  }

  return { success: true };
}