'use server';

import { createClient } from '@/utils/supabase/server';
import { createSupabaseLearningRepo } from '@/lib/learning-repo-supabase';
import { completeLesson as completeLessonCore } from '@/lib/learning';
import { buildAnalyticsRow } from '@/lib/analytics';
import { isWordCategory } from '@/lib/lexeme-labels';
import { readingCompletedProps } from '@/lib/reading';
import { writeDictionaryWord, writeReadingCompleted, writeReadingWord } from '@/lib/progress-write-supabase';
import { syncOps, syncSummary, type ApplyOutcome, type SyncResult, type ValidOp } from '@/lib/offline-sync';
import { withRequestMeta } from '@/lib/server-context';

/** Таблиці немає: PostgREST — PGRST205 («Could not find the table»), Postgres — 42P01. */
function isMissingTable(error: { code?: string } | null): boolean {
  return error?.code === 'PGRST205' || error?.code === '42P01';
}

/**
 * Офлайн без втрат (рішення власника 2026-11-16): приймає пакет дій з черги на телефоні
 * (components/OfflineSync.tsx) і застосовує кожну тією самою логікою, що й онлайн, з часом дії.
 * Перевірки, повтор номера й порядок — lib/offline-sync.ts; журнал номерів — public.client_ops (M28).
 * Не увійшов — нічого не приймаємо, черга чекає входу.
 */
export async function syncOfflineOps(ops: unknown): Promise<{ ok: true; results: SyncResult[] } | { ok: false; reason: 'unauthenticated' }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, reason: 'unauthenticated' };
  const userId = user.id;
  const repo = createSupabaseLearningRepo(supabase);
  const now = new Date();

  const logRow = async (name: Parameters<typeof buildAnalyticsRow>[0], props: Parameters<typeof buildAnalyticsRow>[1], at: Date) => {
    const row = buildAnalyticsRow(name, await withRequestMeta(props), at);
    if (!row) return false;
    await repo.logEvent(userId, row);
    return true;
  };
  // Подія після прийнятої дії — другорядна: збій не повертає дію в чергу
  const softLog = async (...args: Parameters<typeof logRow>) => {
    try {
      await logRow(...args);
    } catch (error) {
      console.error('syncOfflineOps: подія не записалась:', error);
    }
  };

  const apply = async (op: ValidOp, at: Date): Promise<ApplyOutcome> => {
    switch (op.kind) {
      case 'lesson_completed': {
        const { data: lesson, error } = await supabase.from('lessons').select('id').eq('id', op.lessonId).eq('status', 'PUBLISHED').maybeSingle();
        if (error) return { status: 'retry', reason: 'lesson_read' };
        if (!lesson) return { status: 'rejected', reason: 'not_found' };
        await completeLessonCore(repo, {
          userId,
          lessonId: op.lessonId,
          now: at,
          context: await withRequestMeta({ session_id: op.sessionId, duration_ms: op.durationMs, level: op.level, source: 'offline' }),
        });
        return { status: 'ok' };
      }
      case 'reading_completed': {
        const res = await writeReadingCompleted(supabase, userId, op, at);
        if (!res.ok) return res.permanent ? { status: 'rejected', reason: 'not_found' } : { status: 'retry', reason: 'write' };
        await softLog('reading_completed', readingCompletedProps({ cefr: res.cefr, level: op.level, correct: op.correct, total: op.total, durationMs: op.durationMs }), at);
        return { status: 'ok' };
      }
      case 'word_saved': {
        if (op.source === 'reading') {
          const res = await writeReadingWord(supabase, userId, op.lemma, at);
          if (!res.ok) return res.permanent ? { status: 'rejected', reason: 'not_found' } : { status: 'retry', reason: 'write' };
          await softLog('word_saved', { lexeme_id: res.lexemeId, source: 'reading' }, at);
          return { status: 'ok' };
        }
        const res = await writeDictionaryWord(supabase, userId, op.lexemeId, at);
        if (!res.ok) return res.permanent ? { status: 'rejected', reason: 'not_found' } : { status: 'retry', reason: 'write' };
        await softLog('word_saved', {
          lexeme_id: op.lexemeId,
          source: 'dictionary',
          level: res.cefr ?? undefined,
          category: isWordCategory(op.category) ? op.category : undefined,
        }, at);
        return { status: 'ok' };
      }
      case 'event': {
        // збій запису події — кидає, і подія лишається в черзі (retry)
        return (await logRow(op.name, op.props, at)) ? { status: 'ok' } : { status: 'rejected', reason: 'bad_event' };
      }
    }
  };

  const results = await syncOps(ops, {
    userId,
    now,
    async knownOpIds(ids) {
      const { data, error } = await supabase.from('client_ops').select('op_id').in('op_id', ids);
      if (error && isMissingTable(error)) {
        // код уже на сервері, а міграцію M28 ще не запущено (Approve власника після мержу): приймаємо без
        // журналу — урок і слова однаково не дублюються, повтор може лише двічі записати подію
        console.warn('syncOfflineOps: таблиці client_ops ще немає (M28) — приймаємо без журналу');
        return new Set<string>();
      }
      if (error) throw new Error(error.message);
      return new Set((data ?? []).map((r: { op_id: string }) => r.op_id));
    },
    apply,
    async record(opId, kind, at) {
      const { error } = await supabase.from('client_ops').insert({ op_id: opId, user_id: userId, kind, occurred_at: at.toISOString() });
      // повтор номера (дві вкладки водночас) і ще не запущена M28 — не помилка
      if (error && error.code !== '23505' && !isMissingTable(error)) throw new Error(error.message);
    },
  });

  const summary = syncSummary(results, ops, now);
  if (summary.count > 0 || summary.failed > 0) await softLog('offline_synced', summary, now);
  return { ok: true, results };
}
