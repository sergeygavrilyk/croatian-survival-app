/**
 * Спільний контекст для server actions: користувач, сховище, пристрій, версія застосунку.
 * Лише для сервера.
 */
import { headers } from 'next/headers';
import { createClient } from '@/utils/supabase/server';
import { createSupabaseLearningRepo } from '@/lib/learning-repo-supabase';
import { deviceFromUserAgent, type EventProps } from '@/lib/analytics';

export const APP_VERSION = process.env.npm_package_version ?? 'dev';

/** Повертає користувача і сховище; кидає помилку, якщо користувач не увійшов. */
export async function requireLearningContext() {
  const supabase = await createClient();
  const { data: { user }, error } = await supabase.auth.getUser();
  if (error || !user) throw new Error('Не авторизовано');
  return { userId: user.id, repo: createSupabaseLearningRepo(supabase) };
}

/** Те саме, але без помилки: для аналітики, яка не повинна заважати гостям. */
export async function optionalLearningContext() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  return user ? { userId: user.id, repo: createSupabaseLearningRepo(supabase) } : null;
}

/** Додає до властивостей події пристрій і версію застосунку (§72). */
export async function withRequestMeta(props: EventProps = {}): Promise<EventProps> {
  const ua = (await headers()).get('user-agent');
  return { ...props, device: deviceFromUserAgent(ua), app_version: APP_VERSION };
}
