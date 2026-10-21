/**
 * Аналітика навчання (§71–73 ТЗ) — чиста логіка без бази даних і без браузера.
 *
 * Подія складається з назви (лише зі списку §71) і властивостей (§72).
 * Поширені властивості винесені в окремі колонки analytics_events
 * (lesson_id, lexeme_id, level, success, duration_ms…), решта — у jsonb `properties`.
 */

/** Назви подій з §71 (+ тести рівня §60). Додавати нові — лише разом з оновленням docs/ANALYTICS.md. */
export const EVENT_NAMES = [
  'app_open',
  'onboarding_started',
  'onboarding_completed',
  'placement_started',
  'placement_completed',
  'assessment_started',
  'assessment_completed',
  'lesson_started',
  'lesson_completed',
  'exercise_started',
  'exercise_completed',
  'review_started',
  'review_completed',
  'speaking_started',
  'speaking_completed',
  'conversation_started',
  'conversation_completed',
  'reading_started',
  'reading_completed',
  'word_saved',
  'word_mastered',
  'what_to_say_used',
  'what_did_i_hear_used',
  'subscription_started',
  'subscription_cancelled',
  // службова: як браузер відпрацював розпізнавання мовлення (діагностика Safari, 2026-10-21); не навчальна подія
  'speech_diagnostic',
] as const;

export type EventName = (typeof EVENT_NAMES)[number];

const LEVELS = ['A0', 'A1', 'A2', 'B1', 'B2'] as const;
const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const MAX_PROPERTIES_BYTES = 4000;

/** Властивості, які клієнт може передати (§72 + кілька службових). */
export interface EventProps {
  session_id?: string;
  level?: string;
  module_id?: string;
  unit_id?: string;
  lesson_id?: string;
  skill?: string;
  lexeme_id?: string;
  exercise_id?: string;
  exercise_type?: string;
  difficulty?: number | string;
  duration_ms?: number;
  success?: boolean;
  attempt?: number;
  source?: string;
  path?: string;
  /** Довільні числа для підсумків (кількість карток, правильних відповідей тощо) */
  count?: number;
  correct_count?: number;
  added_to_review?: number;
  /** Результат перевірки введеного слова: exact / diacritics / typo / wrong */
  verdict?: string;
  /** Ситуації (phrases / conversations) */
  situation?: string;
  phrase_id?: string;
  /** Онбординг і тест рівня */
  goals?: string;
  daily_goal_minutes?: number;
  self_level?: string;
  estimated_level?: string;
  recommended_start?: string;
  confidence?: string;
  /** Тести рівня (§60): module / mid / final, адреса тесту, частка правильних */
  assessment_kind?: string;
  assessment_slug?: string;
  score?: number;
  /** speech_diagnostic: послідовність подій розпізнавання («st@0 au@120 … end@4100») і платформа */
  speech_trace?: string;
  speech_platform?: string;
  device?: string;
  app_version?: string;
}

/** Рядок для вставки в public.analytics_events (без user_id — його ставить сервер). */
export interface AnalyticsRow {
  event_name: EventName;
  session_id: string | null;
  lesson_id: string | null;
  lexeme_id: string | null;
  level: string | null;
  success: boolean | null;
  duration_ms: number | null;
  device: string | null;
  app_version: string | null;
  properties: Record<string, unknown>;
  occurred_at: string;
}

export function isEventName(name: unknown): name is EventName {
  return typeof name === 'string' && (EVENT_NAMES as readonly string[]).includes(name);
}

const uuidOrNull = (v: unknown): string | null => (typeof v === 'string' && UUID_RE.test(v) ? v : null);

const shortText = (v: unknown, max = 64): string | null =>
  typeof v === 'string' && v.trim() ? v.trim().slice(0, max) : null;

const nonNegativeInt = (v: unknown, max = 86_400_000): number | null =>
  typeof v === 'number' && Number.isFinite(v) && v >= 0 ? Math.min(Math.round(v), max) : null;

/**
 * Перевіряє і нормалізує подію. Повертає null, якщо подія некоректна —
 * аналітика ніколи не повинна ламати навчання, тому помилки не кидаються.
 */
export function buildAnalyticsRow(name: unknown, props: EventProps = {}, now: Date = new Date()): AnalyticsRow | null {
  if (!isEventName(name)) return null;
  if (props === null || typeof props !== 'object' || Array.isArray(props)) return null;

  const level = typeof props.level === 'string' && (LEVELS as readonly string[]).includes(props.level) ? props.level : null;

  // Усе, що не винесено в колонки, — у properties (лише прості значення, з обмеженням розміру)
  const extra: Record<string, unknown> = {};
  const columnKeys = new Set(['session_id', 'lesson_id', 'lexeme_id', 'level', 'success', 'duration_ms', 'device', 'app_version']);
  for (const [key, value] of Object.entries(props)) {
    if (columnKeys.has(key) || value === undefined || value === null) continue;
    if (!/^[a-z][a-z0-9_]{0,39}$/.test(key)) continue;
    if (typeof value === 'string') extra[key] = value.slice(0, 200);
    else if (typeof value === 'number' && Number.isFinite(value)) extra[key] = value;
    else if (typeof value === 'boolean') extra[key] = value;
  }
  if (JSON.stringify(extra).length > MAX_PROPERTIES_BYTES) return null;

  return {
    event_name: name,
    session_id: uuidOrNull(props.session_id),
    lesson_id: uuidOrNull(props.lesson_id),
    lexeme_id: uuidOrNull(props.lexeme_id),
    level,
    success: typeof props.success === 'boolean' ? props.success : null,
    duration_ms: nonNegativeInt(props.duration_ms),
    device: shortText(props.device, 16),
    app_version: shortText(props.app_version, 32),
    properties: extra,
    occurred_at: now.toISOString(),
  };
}

/** Грубий тип пристрою з User-Agent: для аналітики цього достатньо. */
export function deviceFromUserAgent(ua: string | null | undefined): string {
  if (!ua) return 'unknown';
  if (/iPad|Tablet/i.test(ua)) return 'tablet';
  if (/Mobi|Android|iPhone/i.test(ua)) return 'mobile';
  return 'desktop';
}
