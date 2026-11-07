'use server';

import { createClient } from '@/utils/supabase/server';
import { checkWriting, MAX_ANSWER, parseWritingTask } from '@/lib/writing';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
type Outcome = 'correct' | 'wrong' | 'skipped';
const isOutcome = (o: unknown): o is Outcome => o === 'correct' || o === 'wrong' || o === 'skipped';

/**
 * Спроба «Напишіть повідомлення» / «Перекажіть другу» (§57, §58): зберігає ЛИШЕ ТЕКСТ (рішення власника 2026-11-05)
 * у writing_attempts / mediation_attempts. Пункти перераховує сервер тією самою lib/writing.ts за завданням з бази.
 * Діакритики в хорватській відповіді («doci → doći») → «Мої помилки» (user_errors, source = writing).
 * Збій не заважає уроку: повертає false.
 */
export async function recordWritingAttempt(input: {
  exerciseId: string;
  lessonId: string | null;
  text: string;
  outcome: Outcome;
  inputMode: 'typed' | 'voice';
}): Promise<boolean> {
  try {
    if (!UUID_RE.test(input.exerciseId) || !isOutcome(input.outcome) || typeof input.text !== 'string') return false;
    const text = input.text.trim().slice(0, MAX_ANSWER);
    if (!text) return false;
    const supabase = await createClient();
    const { data: { user } } = await supabase.auth.getUser();
    if (!user) return false;

    const { data: ex, error: exError } = await supabase
      .from('exercises')
      .select('id, exercise_type, task')
      .eq('id', input.exerciseId)
      .eq('status', 'PUBLISHED')
      .maybeSingle();
    if (exError || !ex) return false;
    const task = parseWritingTask(ex.exercise_type as string, ex.task);
    if (!task) return false;
    const check = checkWriting(task, text);
    // «правильно» лише якщо сервер теж бачить усі пункти
    const outcome: Outcome = input.outcome === 'correct' && !check.correct ? 'wrong' : input.outcome;
    const row = {
      user_id: user.id,
      exercise_id: ex.id as string,
      lesson_id: input.lessonId && UUID_RE.test(input.lessonId) ? input.lessonId : null,
      text,
      points_total: check.total,
      points_ok: check.done,
      outcome,
      input_mode: input.inputMode === 'voice' ? 'voice' : 'typed',
    };
    const { error } = task.type === 'mediation'
      ? await supabase.from('mediation_attempts').insert({ ...row, direction: task.direction })
      : await supabase.from('writing_attempts').insert(row);
    if (error) {
      console.error('writing attempt:', error.message);
      return false;
    }

    if (check.diacritics.length > 0 && outcome !== 'skipped') {
      const corrected = check.diacritics.map((d) => d.correct);
      const { data: open } = await supabase
        .from('user_errors')
        .select('corrected_text')
        .eq('user_id', user.id)
        .is('resolved_at', null)
        .in('corrected_text', corrected)
        .limit(20);
      const already = new Set((open ?? []).map((r: { corrected_text: string }) => r.corrected_text));
      const fresh = check.diacritics.filter((d) => !already.has(d.correct));
      if (fresh.length > 0) {
        const { error: mistakesError } = await supabase.from('user_errors').insert(
          fresh.map((d) => ({
            user_id: user.id,
            source: 'writing',
            original_text: d.written.slice(0, 300),
            corrected_text: d.correct.slice(0, 300),
            explanation_ua: `Діакритика: пишемо «${d.correct}», а не «${d.written}».`.slice(0, 300),
            error_type: 'spelling',
          })),
        );
        if (mistakesError) console.error('writing user_errors:', mistakesError.message);
      }
    }
    return true;
  } catch (err) {
    console.error('recordWritingAttempt:', err instanceof Error ? err.message : err);
    return false;
  }
}
