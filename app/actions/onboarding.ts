'use server';

import { createClient } from '@/utils/supabase/server';
import { trackEvent } from '@/app/actions/analytics';
import { scorePlacement, type PlacementAnswer, type PlacementResult } from '@/lib/placement';
import { validateOnboarding, type OnboardingInput } from '@/lib/onboarding';

const PLACEMENT_SLUG = 'placement-v1';

export interface PlacementQuestion {
  id: string;
  cefr: string;
  skill: string;
  prompt_ua: string;
  prompt_hr: string | null;
  options: string[];
}

/**
 * Питання тесту рівня — лише опубліковані і без правильних відповідей
 * (оцінка рахується на сервері). null — тест ще не опубліковано.
 */
export async function getPlacementTest(): Promise<{ assessmentId: string; questions: PlacementQuestion[] } | null> {
  const supabase = await createClient();
  const { data: assessment } = await supabase
    .from('assessments')
    .select('id')
    .eq('slug', PLACEMENT_SLUG)
    .eq('status', 'PUBLISHED')
    .maybeSingle();
  if (!assessment) return null;

  const { data: items, error } = await supabase
    .from('assessment_items')
    .select('id, cefr, skill, prompt_ua, prompt_hr, options')
    .eq('assessment_id', assessment.id)
    .eq('status', 'PUBLISHED')
    .order('order_index', { ascending: true });
  if (error || !items || items.length === 0) return null;

  return {
    assessmentId: assessment.id,
    questions: items.map((i) => ({ ...i, options: Array.isArray(i.options) ? i.options.map(String) : [] })),
  };
}

export interface PlacementReviewItem {
  prompt_ua: string;
  prompt_hr: string | null;
  chosen: string | null;
  correctOption: string;
  correct: boolean;
  explanation: string | null;
}

/** Оцінює відповіді, зберігає спробу (assessment_attempts) і повертає результат з розбором. */
export async function submitPlacement(
  assessmentId: string,
  answers: PlacementAnswer[],
  startedAt: string | null,
): Promise<{ ok: true; result: Omit<PlacementResult, 'answers'>; review: PlacementReviewItem[] } | { ok: false; error: string }> {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб пройти тест.' };

  const { data: items, error } = await supabase
    .from('assessment_items')
    .select('id, cefr, skill, prompt_ua, prompt_hr, options, correct_index, explanation_ua')
    .eq('assessment_id', assessmentId)
    .eq('status', 'PUBLISHED')
    .order('order_index', { ascending: true });
  if (error || !items || items.length === 0) return { ok: false, error: 'Тест недоступний. Спробуйте пізніше.' };

  const result = scorePlacement(items, Array.isArray(answers) ? answers : []);
  const started = startedAt && !Number.isNaN(Date.parse(startedAt)) ? startedAt : null;

  const { error: insertError } = await supabase.from('assessment_attempts').insert({
    user_id: user.id,
    assessment_id: assessmentId,
    started_at: started,
    answers: result.answers,
    score_by_level: result.scoreByLevel,
    skill_profile: result.skillProfile,
    estimated_cefr: result.estimated,
    confidence: result.confidence,
    recommended_start: result.recommendedStart,
  });
  if (insertError) console.error('assessment_attempts:', insertError.message);

  await trackEvent('placement_completed', {
    estimated_level: result.estimated,
    recommended_start: result.recommendedStart,
    confidence: result.confidence,
    count: result.answers.length,
    correct_count: result.answers.filter((a) => a.correct).length,
    duration_ms: started ? Date.now() - Date.parse(started) : undefined,
    success: !insertError,
  });

  const byId = new Map(result.answers.map((a) => [a.item_id, a]));
  const review = items.map((i) => {
    const options = Array.isArray(i.options) ? i.options.map(String) : [];
    const a = byId.get(i.id);
    return {
      prompt_ua: i.prompt_ua,
      prompt_hr: i.prompt_hr,
      chosen: a && a.chosen !== null ? options[a.chosen] ?? null : null,
      correctOption: options[i.correct_index] ?? '',
      correct: Boolean(a?.correct),
      explanation: i.explanation_ua,
    };
  });

  const { answers: _omit, ...summary } = result;
  return { ok: true, result: summary, review };
}

/** Зберігає відповіді онбордингу в профіль і позначає онбординг завершеним. */
export async function completeOnboarding(input: OnboardingInput & { selfLevel?: string; viaPlacement?: boolean }): Promise<{ ok: true } | { ok: false; error: string }> {
  const checked = validateOnboarding(input);
  if (!checked.ok) return checked;

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб зберегти налаштування.' };

  const now = new Date().toISOString();
  const { error } = await supabase
    .from('profiles')
    .update({ ...checked.data, onboarding_completed: true, onboarding_completed_at: now, updated_at: now })
    .eq('id', user.id);
  if (error) {
    console.error('profiles onboarding:', error.message);
    return { ok: false, error: 'Не вдалося зберегти. Перевірте інтернет і спробуйте ще раз.' };
  }

  await trackEvent('onboarding_completed', {
    goals: checked.data.learning_goals.join(','),
    daily_goal_minutes: checked.data.daily_goal_minutes,
    level: checked.data.current_level,
    self_level: typeof input.selfLevel === 'string' ? input.selfLevel : undefined,
    source: input.viaPlacement ? 'placement' : 'self',
  });
  return { ok: true };
}
