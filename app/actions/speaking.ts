'use server';

import { createClient } from '@/utils/supabase/server';
import { trackEvent } from '@/app/actions/analytics';
import { evaluateSpeech, speakingSource, type SpeechEvaluation } from '@/lib/speaking';
import { isSituationCode } from '@/lib/situations';

type Mode = 'repeat' | 'produce';
const isMode = (m: unknown): m is Mode => m === 'repeat' || m === 'produce';
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const PROVIDER_RE = /^[a-z0-9_.-]{2,40}$/;

/**
 * Починає заняття говорінням (speaking_sessions). Повертає id або null — тоді просто не зберігаємо.
 * lessonId — «Скажіть уголос» в уроці (source = 'lesson', 2026-10-21).
 */
export async function startSpeakingSession(input: {
  situation?: string;
  lessonId?: string;
  mode: Mode;
  provider?: string;
}): Promise<string | null> {
  try {
    if (!isMode(input.mode)) return null;
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return null;
    const situation = input.situation && isSituationCode(input.situation) ? input.situation : null;
    const lessonId = input.lessonId && UUID_RE.test(input.lessonId) ? input.lessonId : null;
    const source = speakingSource({ lessonId, situation });
    const provider = input.provider && PROVIDER_RE.test(input.provider) ? input.provider : 'web_speech';
    const { data, error } = await supabase
      .from('speaking_sessions')
      .insert({ user_id: user.id, source, situation, lesson_id: lessonId, mode: input.mode, provider })
      .select('id')
      .single();
    if (error) {
      console.error('speaking_sessions:', error.message);
      return null;
    }
    await trackEvent('speaking_started', {
      source,
      situation: situation ?? undefined,
      lesson_id: lessonId ?? undefined,
      exercise_type: input.mode,
    });
    return data.id as string;
  } catch (err) {
    console.error('startSpeakingSession:', err);
    return null;
  }
}

/**
 * Зберігає спробу. Оцінку рахуємо на сервері тією ж функцією, що й у браузері, —
 * клієнтському вердикту не довіряємо. Аудіо не приймаємо й не зберігаємо (§97).
 */
export async function recordSpeakingAttempt(input: {
  sessionId: string | null;
  phraseId: string | null;
  targetText: string;
  mode: Mode;
  transcripts: string[];
  retryNumber: number;
  durationMs: number;
  provider?: string;
}): Promise<SpeechEvaluation | null> {
  try {
    if (!isMode(input.mode) || typeof input.targetText !== 'string') return null;
    const target = input.targetText.trim().slice(0, 300);
    if (!target) return null;
    const transcripts = (Array.isArray(input.transcripts) ? input.transcripts : [])
      .filter((t): t is string => typeof t === 'string')
      .slice(0, 5)
      .map((t) => t.slice(0, 500));
    const evaluation = evaluateSpeech(target, transcripts);

    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return evaluation;

    const { error } = await supabase.from('speaking_attempts').insert({
      user_id: user.id,
      session_id: input.sessionId && UUID_RE.test(input.sessionId) ? input.sessionId : null,
      phrase_id: input.phraseId && UUID_RE.test(input.phraseId) ? input.phraseId : null,
      target_text: target,
      mode: input.mode,
      transcript: evaluation.transcript ? evaluation.transcript.slice(0, 500) : null,
      verdict: evaluation.verdict,
      match_score: evaluation.score,
      missed_words: evaluation.practiceWords,
      retry_number: Math.min(Math.max(Math.trunc(input.retryNumber) || 0, 0), 50),
      duration_ms: Number.isFinite(input.durationMs) ? Math.min(Math.max(Math.round(input.durationMs), 0), 120000) : null,
      provider: input.provider && PROVIDER_RE.test(input.provider) ? input.provider : 'web_speech',
    });
    if (error) console.error('speaking_attempts:', error.message);
    return evaluation;
  } catch (err) {
    console.error('recordSpeakingAttempt:', err);
    return null;
  }
}

/** Завершує заняття: час, кількість спроб, подія speaking_completed. */
export async function finishSpeakingSession(input: {
  sessionId: string | null;
  situation?: string;
  lessonId?: string;
  mode: Mode;
  phrases: number;
  understood: number;
  attempts: number;
  durationMs: number;
}): Promise<void> {
  try {
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return;
    const attempts = Math.min(Math.max(Math.trunc(input.attempts) || 0, 0), 10000);
    if (input.sessionId && UUID_RE.test(input.sessionId)) {
      await supabase
        .from('speaking_sessions')
        .update({ ended_at: new Date().toISOString(), attempts_count: attempts })
        .eq('id', input.sessionId)
        .eq('user_id', user.id);
    }
    const situation = input.situation && isSituationCode(input.situation) ? input.situation : undefined;
    const lessonId = input.lessonId && UUID_RE.test(input.lessonId) ? input.lessonId : undefined;
    await trackEvent('speaking_completed', {
      source: speakingSource({ lessonId, situation }),
      situation,
      lesson_id: lessonId,
      exercise_type: isMode(input.mode) ? input.mode : undefined,
      count: Math.max(0, Math.trunc(input.phrases) || 0),
      correct_count: Math.max(0, Math.trunc(input.understood) || 0),
      attempt: attempts,
      duration_ms: input.durationMs,
      success: input.understood > 0,
    });
  } catch (err) {
    console.error('finishSpeakingSession:', err);
  }
}
