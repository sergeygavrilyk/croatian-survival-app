/**
 * Запис прогресу читання, слів у повторення й відповідей у «Помилках» — спільне для онлайн-дій (app/actions/reading.ts,
 * app/actions/dictionary.ts, app/actions/mistakes.ts) і прийому офлайн-черги (app/actions/offline-sync.ts). Лише сервер;
 * працює від імені користувача (діють RLS). Час дії `now` — онлайн «зараз», з черги — коли людина вчилася.
 *
 * `permanent: true` — дію не застосувати ніколи (тексту чи слова немає): з черги її прибираємо;
 * без нього — збій бази, з черги спробуємо пізніше.
 */
import type { SupabaseClient } from '@supabase/supabase-js';
import { newWordProgress } from './word-save.ts';
import { scheduleMistake } from './mistakes.ts';

export type WriteResult<T = object> = ({ ok: true } & T) | { ok: false; error: string; permanent: boolean };

/** Опубліковане слово словника за лемою зі словничка тексту. */
async function findLexemeByLemma(supabase: SupabaseClient, lemma: string): Promise<{ id: string; cefr: string | null } | null> {
  const { data } = await supabase
    .from('lexemes')
    .select('id, cefr')
    .ilike('lemma', lemma.replace(/[%_\\]/g, (c) => `\\${c}`))
    .eq('status', 'PUBLISHED')
    .order('created_at', { ascending: true })
    .limit(1)
    .maybeSingle();
  return data ? { id: data.id as string, cefr: (data.cefr as string | null) ?? null } : null;
}

/** Слово → у повторення «на сьогодні» (від `now`); уже збережене не скидаємо. */
async function addWord(supabase: SupabaseClient, userId: string, lexemeId: string, now: Date, label: string): Promise<WriteResult> {
  const { error } = await supabase
    .from('user_progress')
    .upsert(newWordProgress(userId, lexemeId, now), { onConflict: 'user_id,lexeme_id', ignoreDuplicates: true });
  if (error) {
    console.error(`${label}:`, error.message);
    return { ok: false, error: 'Не вдалося зберегти слово. Перевірте інтернет.', permanent: false };
  }
  return { ok: true };
}

/** Слово з тексту (за лемою) → у повторення. */
export async function writeReadingWord(
  supabase: SupabaseClient,
  userId: string,
  lemma: string,
  now: Date,
): Promise<WriteResult<{ lexemeId: string }>> {
  const clean = lemma.trim();
  if (!clean || clean.length > 80) return { ok: false, error: 'Слово не знайдено.', permanent: true };
  const lexeme = await findLexemeByLemma(supabase, clean);
  if (!lexeme) return { ok: false, error: 'Цього слова ще немає у словнику застосунку.', permanent: true };
  const res = await addWord(supabase, userId, lexeme.id, now, 'saveReadingWord');
  return res.ok ? { ok: true, lexemeId: lexeme.id } : res;
}

/** Слово зі словника (за id) → у повторення. */
export async function writeDictionaryWord(
  supabase: SupabaseClient,
  userId: string,
  lexemeId: string,
  now: Date,
): Promise<WriteResult<{ cefr: string | null }>> {
  const { data: lexeme, error } = await supabase
    .from('lexemes')
    .select('id, cefr')
    .eq('id', lexemeId)
    .eq('status', 'PUBLISHED')
    .maybeSingle();
  if (error) return { ok: false, error: 'Не вдалося додати слово. Перевірте інтернет.', permanent: false };
  if (!lexeme) return { ok: false, error: 'Цього слова вже немає у словнику.', permanent: true };
  const res = await addWord(supabase, userId, lexemeId, now, 'saveDictionaryWord');
  if (!res.ok) return { ...res, error: 'Не вдалося додати слово. Перевірте інтернет.' };
  return { ok: true, cefr: (lexeme.cefr as string | null) ?? null };
}

/**
 * Текст прочитано → reading_progress (один рядок на текст; повторне читання оновлює результат і лічильник).
 * Дата — пізніша з наявної й нової (дія з черги, старша за останнє читання, дату не відкочує).
 */
export async function writeReadingCompleted(
  supabase: SupabaseClient,
  userId: string,
  input: { textId: string; correct: number; total: number },
  now: Date,
): Promise<WriteResult<{ cefr: string | null }>> {
  const { data: text, error: textError } = await supabase
    .from('reading_texts')
    .select('id, cefr')
    .eq('id', input.textId)
    .eq('status', 'PUBLISHED')
    .maybeSingle();
  if (textError) return { ok: false, error: 'Не вдалося зберегти прогрес. Перевірте інтернет.', permanent: false };
  if (!text) return { ok: false, error: 'Текст не знайдено.', permanent: true };

  const { data: existing, error: readError } = await supabase
    .from('reading_progress')
    .select('id, read_count, completed_at')
    .eq('user_id', userId)
    .eq('text_id', input.textId)
    .maybeSingle();
  if (readError) return { ok: false, error: 'Не вдалося зберегти прогрес. Перевірте інтернет.', permanent: false };

  const at = now.toISOString();
  const prevAt = existing?.completed_at ? Date.parse(existing.completed_at as string) : NaN;
  const { error } = existing
    ? await supabase
        .from('reading_progress')
        .update({
          correct_count: input.correct,
          question_count: input.total,
          read_count: ((existing.read_count as number) ?? 1) + 1,
          completed_at: Number.isFinite(prevAt) && prevAt > now.getTime() ? (existing.completed_at as string) : at,
        })
        .eq('id', existing.id as string)
    : await supabase
        .from('reading_progress')
        .insert({ user_id: userId, text_id: input.textId, correct_count: input.correct, question_count: input.total, completed_at: at });
  if (error) {
    console.error('completeReading:', error.message);
    return { ok: false, error: 'Не вдалося зберегти прогрес. Перевірте інтернет.', permanent: false };
  }
  return { ok: true, cefr: (text.cefr as string | null) ?? null };
}

/**
 * Відповідь у «Помилках» → новий розклад повторення помилки (lib/mistakes.ts). Права — RLS (лише своя).
 * `keepNewer` (з офлайн-черги): помилку вже повторили пізніше — розклад не чіпаємо (`stale`).
 * Уже засвоєну не змінюємо.
 */
export async function writeMistakeRating(
  supabase: SupabaseClient,
  userId: string,
  errorId: string,
  correct: boolean,
  now: Date,
  { keepNewer = false }: { keepNewer?: boolean } = {},
): Promise<WriteResult<{ resolved: boolean; attempt: number; changed: boolean }>> {
  const { data: row, error: readError } = await supabase
    .from('user_errors')
    .select('id, correct_streak, review_count, resolved_at, last_reviewed_at')
    .eq('id', errorId)
    .eq('user_id', userId)
    .maybeSingle();
  if (readError) return { ok: false, error: 'Не вдалося зберегти відповідь. Перевірте інтернет.', permanent: false };
  if (!row) return { ok: false, error: 'Помилку не знайдено.', permanent: true };
  const reviewCount = (row.review_count as number | null) ?? 0;
  if (row.resolved_at) return { ok: true, resolved: true, attempt: reviewCount, changed: false };
  const reviewedMs = row.last_reviewed_at ? Date.parse(row.last_reviewed_at as string) : NaN;
  if (keepNewer && Number.isFinite(reviewedMs) && reviewedMs > now.getTime()) {
    return { ok: true, resolved: false, attempt: reviewCount, changed: false };
  }

  const next = scheduleMistake({ correctStreak: (row.correct_streak as number | null) ?? 0, reviewCount }, correct, now);
  const { error } = await supabase
    .from('user_errors')
    .update({
      correct_streak: next.correctStreak,
      review_count: next.reviewCount,
      next_review_at: next.nextReviewAt.toISOString(),
      last_reviewed_at: now.toISOString(),
      resolved_at: next.resolvedAt ? next.resolvedAt.toISOString() : null,
    })
    .eq('id', errorId);
  if (error) {
    console.error('writeMistakeRating:', error.message);
    return { ok: false, error: 'Не вдалося зберегти відповідь. Перевірте інтернет.', permanent: false };
  }
  return { ok: true, resolved: Boolean(next.resolvedAt), attempt: next.reviewCount, changed: true };
}
