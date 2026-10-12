'use server';

import { rateCard } from '@/lib/learning';
import { requireLearningContext } from '@/lib/server-context';

/**
 * Оцінює картку в тренажері (свайп «Знаю» / «Не знаю»):
 * оновлює стан SRS у user_progress і пише історію в srs_reviews.
 * Логіка — у lib/learning.ts (rateCard), тут лише авторизація.
 *
 * @param lexemeId ID лексеми (public.lexemes.id)
 * @param rating 1 — «Знаю» (свайп вправо), 0 — «Не знаю» (свайп вліво)
 * @param responseTimeMs час відповіді в мс (необов'язково)
 */
export async function rateFlashcard(lexemeId: string, rating: number, responseTimeMs?: number) {
  const { userId, repo } = await requireLearningContext();
  return rateCard(repo, { userId, lexemeId, rating, responseTimeMs });
}
