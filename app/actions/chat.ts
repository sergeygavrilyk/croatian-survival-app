'use server'

import { createClient } from '@/utils/supabase/server';

/**
 * Створює нову сесію розмови з AI
 */
export async function startConversation(mode: string = 'roleplay', scenarioId?: string) {
  const supabase = await createClient();

  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) throw new Error('Не авторизовано');

  const { data, error } = await supabase
    .from('ai_conversations')
    .insert({
      user_id: user.id,
      mode: mode,
      scenario_id: scenarioId || null,
      status: 'active'
    })
    .select('id')
    .single();

  if (error) {
    console.error('Помилка створення сесії чату:', error);
    throw new Error('Не вдалося створити сесію');
  }

  return data.id as string;
}

/**
 * Зберігає окреме повідомлення у поточну сесію
 */
export async function saveChatMessage(conversationId: string, role: 'user' | 'assistant' | 'system', content: string) {
  const supabase = await createClient();

  const { error } = await supabase
    .from('ai_messages')
    .insert({
      conversation_id: conversationId,
      role: role,
      content: content
    });

  if (error) {
    console.error('Помилка збереження повідомлення:', error);
  }
}