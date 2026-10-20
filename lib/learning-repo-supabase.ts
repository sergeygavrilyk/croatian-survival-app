/**
 * Реалізація LearningRepo поверх Supabase (працює від імені користувача — діють RLS).
 * Використовується лише на сервері (server actions).
 */
import type { SupabaseClient } from '@supabase/supabase-js';
import type { LearningRepo } from './learning.ts';
import { LEARNING_EVENTS } from './progress.ts';
import { DEFAULT_EASE } from './srs.ts';

export function createSupabaseLearningRepo(supabase: SupabaseClient): LearningRepo {
  return {
    async getCardState(userId, lexemeId) {
      const { data, error } = await supabase
        .from('user_progress')
        .select('ease_factor, interval_days, repetition_count, lapses')
        .eq('user_id', userId)
        .eq('lexeme_id', lexemeId)
        .maybeSingle();
      if (error) throw new Error(`Не вдалося прочитати прогрес: ${error.message}`);
      if (!data) return null;
      return {
        easeFactor: data.ease_factor ?? DEFAULT_EASE,
        intervalDays: data.interval_days ?? 0,
        repetitionCount: data.repetition_count ?? 0,
        lapses: data.lapses ?? 0,
      };
    },

    async saveCardState(userId, lexemeId, next, now) {
      const { error } = await supabase.from('user_progress').upsert(
        {
          user_id: userId,
          lexeme_id: lexemeId,
          ease_factor: next.easeFactor,
          interval_days: next.intervalDays,
          repetition_count: next.repetitionCount,
          lapses: next.lapses,
          next_review_date: next.nextReviewDate.toISOString(),
          last_reviewed_at: now.toISOString(),
          updated_at: now.toISOString(),
        },
        { onConflict: 'user_id,lexeme_id' }
      );
      if (error) throw new Error(`Не вдалося зберегти прогрес: ${error.message}`);
    },

    async addReviewHistory(entry) {
      const { error } = await supabase.from('srs_reviews').insert({
        user_id: entry.userId,
        lexeme_id: entry.lexemeId,
        result: entry.result,
        response_time_ms: entry.responseTimeMs,
        old_interval: entry.prev.intervalDays,
        new_interval: entry.next.intervalDays,
        old_ease: entry.prev.easeFactor,
        new_ease: entry.next.easeFactor,
      });
      if (error) throw new Error(error.message);
    },

    async markLessonCompleted(userId, lessonId, now) {
      const { error } = await supabase.from('lesson_progress').upsert(
        {
          user_id: userId,
          lesson_id: lessonId,
          status: 'completed',
          completed_at: now.toISOString(),
          updated_at: now.toISOString(),
        },
        { onConflict: 'user_id,lesson_id' }
      );
      if (error) throw new Error(`Не вдалося зберегти прогрес уроку: ${error.message}`);
    },

    async getLessonLexemeIds(lessonId) {
      const { data, error } = await supabase
        .from('lesson_items')
        .select('item_id')
        .eq('lesson_id', lessonId)
        .eq('item_type', 'lexeme');
      if (error) throw new Error(error.message);
      return (data ?? []).map((row: { item_id: string }) => row.item_id);
    },

    async addToReviewIfAbsent(userId, lexemeIds, dueAt) {
      // ignoreDuplicates + select повертає лише реально вставлені рядки
      const { data, error } = await supabase
        .from('user_progress')
        .upsert(
          lexemeIds.map((lexemeId) => ({
            user_id: userId,
            lexeme_id: lexemeId,
            interval_days: 1,
            repetition_count: 0,
            next_review_date: dueAt.toISOString(),
          })),
          { onConflict: 'user_id,lexeme_id', ignoreDuplicates: true }
        )
        .select('id');
      if (error) throw new Error(error.message);
      return data?.length ?? 0;
    },

    async logEvent(userId, row) {
      const { error } = await supabase.from('analytics_events').insert({ user_id: userId, ...row });
      if (error) throw new Error(error.message);
    },

    async getLearningActivity(userId, since) {
      // Ті самі джерела, що й 🔥 на «Сьогодні» (app/page.tsx): події навчання + історія повторень карток
      const [events, reviews, profile] = await Promise.all([
        supabase
          .from('analytics_events')
          .select('occurred_at')
          .eq('user_id', userId)
          .in('event_name', [...LEARNING_EVENTS])
          .gte('occurred_at', since.toISOString())
          .order('occurred_at', { ascending: false })
          .limit(5000),
        supabase
          .from('srs_reviews')
          .select('created_at')
          .eq('user_id', userId)
          .gte('created_at', since.toISOString())
          .order('created_at', { ascending: false })
          .limit(5000),
        supabase.from('profiles').select('timezone').eq('id', userId).maybeSingle(),
      ]);
      if (events.error) throw new Error(events.error.message);
      return {
        timestamps: [
          ...(events.data ?? []).map((r: { occurred_at: string }) => r.occurred_at),
          ...(reviews.error ? [] : (reviews.data ?? []).map((r: { created_at: string }) => r.created_at)),
        ],
        timeZone: profile.error ? null : ((profile.data as { timezone?: string | null } | null)?.timezone ?? null),
      };
    },
  };
}
