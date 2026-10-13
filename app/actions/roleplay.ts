'use server';

import { createClient } from '@/utils/supabase/server';
import { trackEvent } from '@/app/actions/analytics';
import { getAIProvider } from '@/lib/ai-gemini';
import { AIError } from '@/lib/ai-provider';
import {
  DAILY_AI_TURNS_LIMIT,
  MAX_USER_TURNS,
  buildAssessmentPrompt,
  buildRoleplaySystemPrompt,
  collectErrors,
  getScenario,
  isCefr,
  parseAssessment,
  parseRoleplayTurn,
  sanitizeUserText,
  transcriptForAssessment,
  type Cefr,
  type Correction,
  type RoleplayAssessment,
  type RoleplayTurn,
} from '@/lib/roleplay';

type Fail = { ok: false; error: string };
type Supabase = Awaited<ReturnType<typeof createClient>>;

const START_INSTRUCTION = '[Почни розмову в ролі: привітайся і постав перше питання.]';
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

function aiErrorText(err: unknown): string {
  if (err instanceof AIError) {
    if (err.code === 'not_configured') return 'AI не налаштовано: немає ключа GEMINI_API_KEY у .env.local.';
    if (err.code === 'rate_limited') return 'Ліміт розмов з AI на сьогодні вичерпано. Повертайтеся завтра.';
    if (err.code === 'unavailable') return 'AI зараз перевантажений. Спробуйте ще раз за хвилину.';
  }
  return 'AI зараз не відповів як слід. Спробуйте ще раз.';
}

/** Денний ліміт викликів AI для рольової гри (§97: rate limiting). */
async function assertDailyLimit(supabase: Supabase, userId: string) {
  const dayStart = new Date();
  dayStart.setUTCHours(0, 0, 0, 0);
  const { count } = await supabase
    .from('ai_usage_events')
    .select('id', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('feature', 'roleplay')
    .gte('occurred_at', dayStart.toISOString());
  if ((count ?? 0) >= DAILY_AI_TURNS_LIMIT) throw new AIError('rate_limited');
}

/** Рівень (з профілю, за замовчуванням A1) і корисні фрази ситуації (§51: target vocabulary). */
async function loadLearnerContext(supabase: Supabase, userId: string, situation: string): Promise<{ level: Cefr; phrases: string[] }> {
  const [profileRes, phrasesRes] = await Promise.all([
    supabase.from('profiles').select('current_level').eq('id', userId).maybeSingle(),
    supabase.from('phrases').select('text_hr').eq('situation', situation).eq('status', 'PUBLISHED').limit(12),
  ]);
  const level = isCefr(profileRes.data?.current_level) ? profileRes.data!.current_level : 'A1';
  return { level, phrases: (phrasesRes.data ?? []).map((p) => p.text_hr as string) };
}

async function requireUser(supabase: Supabase) {
  const { data: { user } } = await supabase.auth.getUser();
  return user;
}

// ---------------------------------------------------------------- старт
export async function startRoleplay(
  situation: string,
): Promise<{ ok: true; conversationId: string; level: Cefr; turn: RoleplayTurn } | Fail> {
  const scenario = getScenario(situation);
  if (!scenario) return { ok: false, error: 'Такої ситуації немає.' };

  const supabase = await createClient();
  const user = await requireUser(supabase);
  if (!user) return { ok: false, error: 'Увійдіть, щоб почати розмову.' };

  let conversationId: string | null = null;
  try {
    await assertDailyLimit(supabase, user.id);
    const { level, phrases } = await loadLearnerContext(supabase, user.id, situation);

    const { data: conv, error } = await supabase
      .from('ai_conversations')
      .insert({ user_id: user.id, mode: 'roleplay', status: 'active', situation, level })
      .select('id')
      .single();
    if (error || !conv) return { ok: false, error: 'Не вдалося почати розмову. Перевірте інтернет.' };
    conversationId = conv.id as string;

    const { value: turn } = await getAIProvider().structuredOutput(
      {
        system: buildRoleplaySystemPrompt(scenario, level, phrases),
        messages: [{ role: 'user', content: START_INSTRUCTION }],
        feature: 'roleplay',
        temperature: 0.7,
        maxOutputTokens: 400,
      },
      parseRoleplayTurn,
    );

    await supabase.from('ai_messages').insert({
      conversation_id: conversationId,
      role: 'assistant',
      content: turn.reply_hr,
      translation_ua: turn.reply_ua || null,
    });
    await trackEvent('conversation_started', { source: 'roleplay', situation, level });
    return { ok: true, conversationId, level, turn: { ...turn, correction: null } };
  } catch (err) {
    console.error('startRoleplay:', err);
    if (conversationId) await supabase.from('ai_conversations').update({ status: 'failed' }).eq('id', conversationId);
    return { ok: false, error: aiErrorText(err) };
  }
}

// ---------------------------------------------------------------- репліка
export async function sendRoleplayMessage(
  conversationId: string,
  text: string,
): Promise<{ ok: true; turn: RoleplayTurn; userTurns: number; finished: boolean } | Fail> {
  const message = sanitizeUserText(text);
  if (!message) return { ok: false, error: 'Напишіть або скажіть репліку.' };
  if (!UUID_RE.test(conversationId)) return { ok: false, error: 'Розмову не знайдено.' };

  const supabase = await createClient();
  const user = await requireUser(supabase);
  if (!user) return { ok: false, error: 'Увійдіть, щоб продовжити розмову.' };

  const { data: conv } = await supabase
    .from('ai_conversations')
    .select('id, situation, level, user_turns, ended_at, goal_reached')
    .eq('id', conversationId)
    .maybeSingle();
  const scenario = conv?.situation ? getScenario(conv.situation) : null;
  if (!conv || !scenario) return { ok: false, error: 'Розмову не знайдено.' };
  if (conv.ended_at) return { ok: false, error: 'Розмову вже завершено.' };
  if (conv.user_turns >= MAX_USER_TURNS) return { ok: false, error: 'Розмова завершена — подивіться підсумок.' };

  try {
    await assertDailyLimit(supabase, user.id);
    const { phrases } = await loadLearnerContext(supabase, user.id, conv.situation);
    const level: Cefr = isCefr(conv.level) ? conv.level : 'A1';

    const { data: history } = await supabase
      .from('ai_messages')
      .select('role, content')
      .eq('conversation_id', conversationId)
      .in('role', ['user', 'assistant'])
      .order('created_at', { ascending: true })
      .limit(40);

    const { value: turn } = await getAIProvider().structuredOutput(
      {
        system: buildRoleplaySystemPrompt(scenario, level, phrases),
        messages: [
          { role: 'user', content: START_INSTRUCTION },
          ...(history ?? []).map((m) => ({ role: m.role as 'user' | 'assistant', content: m.content as string })),
          { role: 'user', content: message },
        ],
        feature: 'roleplay',
        temperature: 0.7,
        maxOutputTokens: 400,
      },
      parseRoleplayTurn,
    );

    const userTurns = conv.user_turns + 1;
    const finished = turn.goal_reached || userTurns >= MAX_USER_TURNS;
    await supabase.from('ai_messages').insert({
      conversation_id: conversationId,
      role: 'user',
      content: message,
      correction: turn.correction,
    });
    await supabase.from('ai_messages').insert({
      conversation_id: conversationId,
      role: 'assistant',
      content: turn.reply_hr,
      translation_ua: turn.reply_ua || null,
    });
    await supabase
      .from('ai_conversations')
      .update({ user_turns: userTurns, goal_reached: conv.goal_reached || turn.goal_reached, updated_at: new Date().toISOString() })
      .eq('id', conversationId);

    return { ok: true, turn, userTurns, finished };
  } catch (err) {
    console.error('sendRoleplayMessage:', err);
    return { ok: false, error: aiErrorText(err) };
  }
}

// ---------------------------------------------------------------- підсумок
export async function finishRoleplay(
  conversationId: string,
): Promise<{ ok: true; assessment: RoleplayAssessment | null; goalReached: boolean; errorsSaved: number } | Fail> {
  if (!UUID_RE.test(conversationId)) return { ok: false, error: 'Розмову не знайдено.' };
  const supabase = await createClient();
  const user = await requireUser(supabase);
  if (!user) return { ok: false, error: 'Увійдіть, щоб побачити підсумок.' };

  const { data: conv } = await supabase
    .from('ai_conversations')
    .select('id, situation, level, user_turns, ended_at, goal_reached, summary')
    .eq('id', conversationId)
    .maybeSingle();
  const scenario = conv?.situation ? getScenario(conv.situation) : null;
  if (!conv || !scenario) return { ok: false, error: 'Розмову не знайдено.' };

  // Повторний виклик — повертаємо збережений підсумок
  if (conv.ended_at) {
    const saved = conv.summary && typeof conv.summary === 'object' && 'assessment' in conv.summary ? (conv.summary.assessment as RoleplayAssessment | null) : null;
    return { ok: true, assessment: saved, goalReached: Boolean(conv.goal_reached), errorsSaved: 0 };
  }

  const level: Cefr = isCefr(conv.level) ? conv.level : 'A1';
  const { data: messages } = await supabase
    .from('ai_messages')
    .select('role, content, correction')
    .eq('conversation_id', conversationId)
    .in('role', ['user', 'assistant'])
    .order('created_at', { ascending: true })
    .limit(40);
  const history = (messages ?? []).map((m) => ({ role: m.role as 'user' | 'assistant', content: m.content as string }));

  let assessment: RoleplayAssessment | null = null;
  if (conv.user_turns > 0) {
    try {
      await assertDailyLimit(supabase, user.id);
      const { value } = await getAIProvider().structuredOutput(
        {
          system: buildAssessmentPrompt(scenario, level),
          messages: [{ role: 'user', content: transcriptForAssessment(history, scenario) }],
          feature: 'roleplay',
          temperature: 0.3,
          maxOutputTokens: 700,
        },
        parseAssessment,
      );
      assessment = value;
    } catch (err) {
      console.error('finishRoleplay assessment:', err); // підсумок без оцінки AI — розмову все одно завершуємо
    }
  }

  const corrections = (messages ?? [])
    .filter((m) => m.role === 'user' && m.correction && typeof m.correction === 'object')
    .map((m) => ({ original: m.content as string, correction: m.correction as Correction }));
  const errors = collectErrors(corrections, assessment);

  let errorsSaved = 0;
  if (errors.length > 0) {
    const { error } = await supabase.from('user_errors').insert(
      errors.map((e) => ({
        user_id: user.id,
        source: 'roleplay',
        conversation_id: conversationId,
        situation: conv.situation,
        original_text: e.original.slice(0, 300),
        corrected_text: e.corrected_hr.slice(0, 300),
        explanation_ua: e.explanation_ua.slice(0, 300),
        error_type: e.type,
      })),
    );
    if (error) console.error('user_errors:', error.message);
    else errorsSaved = errors.length;
  }

  const goalReached = Boolean(conv.goal_reached || assessment?.task_completed);
  await supabase
    .from('ai_conversations')
    .update({
      status: 'completed',
      ended_at: new Date().toISOString(),
      goal_reached: goalReached,
      summary: { assessment, errors_saved: errorsSaved },
      updated_at: new Date().toISOString(),
    })
    .eq('id', conversationId);

  await trackEvent('conversation_completed', {
    source: 'roleplay',
    situation: conv.situation,
    level,
    count: conv.user_turns,
    attempt: errorsSaved,
    success: goalReached,
  });

  return { ok: true, assessment, goalReached, errorsSaved };
}
