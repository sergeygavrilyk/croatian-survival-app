/**
 * Запис події в ai_usage_events від імені поточного користувача. Лише для сервера.
 * Облік ніколи не ламає основну дію: усі помилки тут ковтаються.
 */
import { createClient } from '@/utils/supabase/server';
import { toAiUsageRow, type AiUsageInput } from '@/lib/ai-usage';

export async function recordAiUsage(input: AiUsageInput): Promise<void> {
  try {
    const row = toAiUsageRow(input);
    if (!row) return;
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;
    const { error } = await supabase.from('ai_usage_events').insert({ ...row, user_id: user.id });
    if (error) console.warn('ai_usage_events: не вдалося записати подію', error.message);
  } catch (err) {
    console.warn('ai_usage_events: збій обліку', err);
  }
}
