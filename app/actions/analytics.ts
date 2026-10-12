'use server';

import { trackEvent as trackEventCore } from '@/lib/learning';
import { optionalLearningContext, withRequestMeta } from '@/lib/server-context';
import type { EventProps } from '@/lib/analytics';

/**
 * Записує подію аналітики від імені поточного користувача.
 * Для гостя нічого не пише. Ніколи не кидає помилку — аналітика не повинна ламати навчання.
 */
export async function trackEvent(name: string, props: EventProps = {}): Promise<boolean> {
  try {
    const ctx = await optionalLearningContext();
    if (!ctx) return false;
    return await trackEventCore(ctx.repo, ctx.userId, name, await withRequestMeta(props));
  } catch (error) {
    console.error('Помилка аналітики:', error);
    return false;
  }
}
