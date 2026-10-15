'use server';

import { createClient } from '@/utils/supabase/server';
import { trackEvent } from '@/app/actions/analytics';
import {
  attemptMeta, isLevelAssessmentSlug, mistakesToSave, nextLevel, optionsOf, scoreAssessment,
  type Area, type AreaScore, type GradableItem, type ItemResponse,
} from '@/lib/assessment';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const MAX_ITEMS = 60;
const MAX_TEXT = 300;

export interface AssessmentReviewItem {
  order: number;
  area: Area;
  prompt_ua: string;
  prompt_hr: string | null;
  /** Правильна відповідь (хорватською або українською — залежно від завдання) */
  correctText: string;
  given: string | null;
  correct: boolean;
  skipped: boolean;
  explanation: string | null;
}

export interface AssessmentResultView {
  slug: string;
  kind: string;
  cefr: string;
  score: number;
  correct: number;
  total: number;
  passed: boolean;
  passRatio: number;
  areaMinRatio: number;
  areaScores: Record<Area, AreaScore>;
  weakAreas: Area[];
  lessons: Array<{ id: string; title_ua: string }>;
  review: AssessmentReviewItem[];
  /** Фінальний тест пройдено → можна перейти на цей рівень */
  nextLevel: string | null;
  savedMistakes: number;
  attemptSaved: boolean;
}

/** Відповіді з браузера: лише очікувана форма, обрізана довжина (решту відкидаємо). */
function cleanResponses(input: unknown): ItemResponse[] {
  if (!Array.isArray(input)) return [];
  const out: ItemResponse[] = [];
  for (const r of input.slice(0, MAX_ITEMS)) {
    if (!r || typeof r !== 'object' || typeof (r as ItemResponse).item_id !== 'string' || !UUID_RE.test((r as ItemResponse).item_id)) continue;
    const x = r as ItemResponse;
    out.push({
      item_id: x.item_id,
      choice: typeof x.choice === 'number' && Number.isInteger(x.choice) ? x.choice : null,
      text: typeof x.text === 'string' ? x.text.slice(0, MAX_TEXT) : null,
      transcripts: Array.isArray(x.transcripts)
        ? x.transcripts.filter((t): t is string => typeof t === 'string').slice(0, 5).map((t) => t.slice(0, MAX_TEXT))
        : null,
      skipped: x.skipped === true,
    });
  }
  return out;
}

/**
 * Перевіряє тест (§60) на сервері: бал за навичками, «пройдено» за правилами власника,
 * спроба в assessment_attempts, помилки-фрази — у «Помилки» (user_errors), подія assessment_completed.
 */
export async function submitAssessment(
  slug: string,
  responses: unknown,
  startedAt: string | null,
): Promise<{ ok: true; result: AssessmentResultView } | { ok: false; error: string }> {
  if (!isLevelAssessmentSlug(slug)) return { ok: false, error: 'Тест не знайдено.' };
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб зберегти результат.' };

  const { data: assessment } = await supabase
    .from('assessments')
    .select('id, slug, kind, cefr, module_id, pass_ratio, area_min_ratio, title_ua')
    .eq('slug', slug)
    .eq('status', 'PUBLISHED')
    .maybeSingle();
  if (!assessment) return { ok: false, error: 'Тест не знайдено.' };

  const { data: rows, error } = await supabase
    .from('assessment_items')
    .select('id, order_index, area, item_type, prompt_ua, prompt_hr, options, correct_index, answer_text, weight, lesson_id, explanation_ua')
    .eq('assessment_id', assessment.id)
    .eq('status', 'PUBLISHED')
    .order('order_index', { ascending: true });
  if (error || !rows || rows.length === 0) return { ok: false, error: 'Тест недоступний. Спробуйте пізніше.' };

  const items = rows as Array<GradableItem & { order_index: number; prompt_ua: string; prompt_hr: string | null; explanation_ua: string | null }>;
  const clean = cleanResponses(responses);
  const result = scoreAssessment(items, clean, { passRatio: assessment.pass_ratio, areaMinRatio: assessment.area_min_ratio });
  const kind = assessment.kind as string;
  const cefr = assessment.cefr as string;
  const started = startedAt && !Number.isNaN(Date.parse(startedAt)) ? startedAt : null;

  const { error: insertError } = await supabase.from('assessment_attempts').insert({
    user_id: user.id,
    assessment_id: assessment.id,
    started_at: started,
    answers: result.graded.map((g) => ({ item_id: g.item_id, correct: g.correct, skipped: g.skipped, verdict: g.verdict })),
    score: result.score,
    passed: result.passed,
    area_scores: result.areaScores,
    skill_profile: Object.fromEntries(
      Object.entries(result.areaScores).map(([a, s]) => [a, s.total > 0 ? Math.round((s.correct / s.total) * 100) / 100 : null]),
    ),
    ...attemptMeta(kind, cefr, result),
  });
  if (insertError) console.error('assessment_attempts:', insertError.message);

  // Помилки-фрази → «Помилки» (повторення з плиток). Уже відкриті такі самі не дублюємо.
  let savedMistakes = 0;
  const toSave = mistakesToSave(items, result.graded);
  if (toSave.length > 0) {
    const { data: open } = await supabase
      .from('user_errors')
      .select('corrected_text')
      .eq('user_id', user.id)
      .is('resolved_at', null)
      .in('corrected_text', toSave.map((m) => m.corrected))
      .limit(100);
    const already = new Set<string>((open ?? []).map((r: { corrected_text: string }) => r.corrected_text));
    const fresh = toSave.filter((m) => !already.has(m.corrected));
    if (fresh.length > 0) {
      const byId = new Map(items.map((i) => [i.id, i]));
      const { error: mistakesError } = await supabase.from('user_errors').insert(
        fresh.map((m) => ({
          user_id: user.id,
          source: 'exercise',
          original_text: m.original,
          corrected_text: m.corrected,
          explanation_ua: (byId.get(m.item_id)?.explanation_ua ?? `${assessment.title_ua}: правильна відповідь.`).slice(0, 300),
          error_type: m.error_type,
        })),
      );
      if (mistakesError) console.error('assessment user_errors:', mistakesError.message);
      else savedMistakes = fresh.length;
    }
  }

  await trackEvent('assessment_completed', {
    level: cefr,
    module_id: (assessment.module_id as string | null) ?? undefined,
    assessment_kind: kind,
    assessment_slug: slug,
    score: result.score,
    count: result.total,
    correct_count: result.correct,
    success: result.passed,
    duration_ms: started ? Date.now() - Date.parse(started) : undefined,
  });

  let lessons: Array<{ id: string; title_ua: string }> = [];
  const lessonIds = result.lessonsToReview.slice(0, 5);
  if (lessonIds.length > 0) {
    const { data: lessonRows } = await supabase.from('lessons').select('id, title_ua').in('id', lessonIds).eq('status', 'PUBLISHED');
    const titles = new Map<string, string>((lessonRows ?? []).map((l: { id: string; title_ua: string }) => [l.id, l.title_ua]));
    lessons = lessonIds.filter((id) => titles.has(id)).map((id) => ({ id, title_ua: titles.get(id)! }));
  }

  const graded = new Map(result.graded.map((g) => [g.item_id, g]));
  const review: AssessmentReviewItem[] = items.map((i) => {
    const g = graded.get(i.id)!;
    return {
      order: i.order_index,
      area: g.area,
      prompt_ua: i.prompt_ua,
      prompt_hr: i.prompt_hr,
      correctText: i.item_type === 'multiple_choice' ? optionsOf(i.options)[i.correct_index ?? -1] ?? '' : (i.answer_text ?? ''),
      given: g.given,
      correct: g.correct,
      skipped: g.skipped,
      explanation: i.explanation_ua,
    };
  });

  return {
    ok: true,
    result: {
      slug,
      kind,
      cefr,
      score: result.score,
      correct: result.correct,
      total: result.total,
      passed: result.passed,
      passRatio: Number(assessment.pass_ratio),
      areaMinRatio: Number(assessment.area_min_ratio),
      areaScores: result.areaScores,
      weakAreas: result.weakAreas,
      lessons,
      review,
      nextLevel: kind === 'final' && result.passed ? nextLevel(cefr) : null,
      savedMistakes,
      attemptSaved: !insertError,
    },
  };
}

/**
 * Перейти на наступний рівень після фінального тесту. Перевіряємо, що фінал попереднього рівня
 * справді пройдено (спроба в базі), і лише тоді змінюємо profiles.current_level.
 */
export async function moveToLevel(level: string): Promise<{ ok: true } | { ok: false; error: string }> {
  const LEVELS = ['A1', 'A2', 'B1', 'B2'];
  if (!LEVELS.includes(level)) return { ok: false, error: 'Невідомий рівень.' };
  const prev = ['A0', 'A1', 'A2', 'B1'][LEVELS.indexOf(level)];
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) return { ok: false, error: 'Увійдіть, щоб змінити рівень.' };

  const { data: final } = await supabase.from('assessments').select('id').eq('slug', `${prev.toLowerCase()}-final`).maybeSingle();
  if (!final) return { ok: false, error: 'Спершу пройдіть фінальну перевірку рівня.' };
  const { data: passed } = await supabase
    .from('assessment_attempts')
    .select('id')
    .eq('user_id', user.id)
    .eq('assessment_id', final.id)
    .eq('passed', true)
    .limit(1)
    .maybeSingle();
  if (!passed) return { ok: false, error: 'Спершу пройдіть фінальну перевірку рівня.' };

  const { error } = await supabase
    .from('profiles')
    .update({ current_level: level, updated_at: new Date().toISOString() })
    .eq('id', user.id);
  if (error) {
    console.error('moveToLevel:', error.message);
    return { ok: false, error: 'Не вдалося змінити рівень. Перевірте інтернет.' };
  }
  return { ok: true };
}
