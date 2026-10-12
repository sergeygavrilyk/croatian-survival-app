/**
 * Облік викликів AI і мовлення (§74, таблиця ai_usage_events — міграція M4b).
 * Чиста логіка без БД: перевірка і нормалізація рядка перед записом.
 */
export const AI_FEATURES = [
  'quick_translate', 'what_do_i_say', 'what_did_i_hear', 'chat', 'roleplay',
  'tts', 'stt', 'pronunciation', 'content_generation', 'other',
] as const;

export type AiFeature = (typeof AI_FEATURES)[number];

export interface AiUsageInput {
  feature: AiFeature;
  provider: string;
  model?: string | null;
  inputTokens?: number | null;
  outputTokens?: number | null;
  characters?: number | null;
  audioMs?: number | null;
  latencyMs?: number | null;
  costUsd?: number | null;
  success?: boolean;
  errorCode?: string | null;
  properties?: Record<string, string | number | boolean | null>;
}

export interface AiUsageRow {
  feature: AiFeature;
  provider: string;
  model: string | null;
  input_tokens: number | null;
  output_tokens: number | null;
  characters: number | null;
  audio_ms: number | null;
  latency_ms: number | null;
  cost_usd: number | null;
  success: boolean;
  error_code: string | null;
  properties: Record<string, string | number | boolean | null>;
}

const PROVIDER_RE = /^[a-z0-9_.-]{2,40}$/;
const MAX_PROPERTIES_BYTES = 2048;

function count(value: number | null | undefined): number | null {
  if (value === null || value === undefined || !Number.isFinite(value) || value < 0) return null;
  return Math.round(value);
}

function short(value: string | null | undefined, max: number): string | null {
  if (!value) return null;
  const trimmed = value.trim();
  return trimmed ? trimmed.slice(0, max) : null;
}

/** Повертає рядок для ai_usage_events або null, якщо подія некоректна (тоді нічого не пишемо). */
export function toAiUsageRow(input: AiUsageInput): AiUsageRow | null {
  if (!(AI_FEATURES as readonly string[]).includes(input.feature)) return null;
  const provider = input.provider?.trim().toLowerCase();
  if (!provider || !PROVIDER_RE.test(provider)) return null;

  let properties = input.properties ?? {};
  if (typeof properties !== 'object' || Array.isArray(properties)) properties = {};
  if (JSON.stringify(properties).length > MAX_PROPERTIES_BYTES) properties = {};

  const cost = input.costUsd;
  return {
    feature: input.feature,
    provider,
    model: short(input.model, 80),
    input_tokens: count(input.inputTokens),
    output_tokens: count(input.outputTokens),
    characters: count(input.characters),
    audio_ms: count(input.audioMs),
    latency_ms: count(input.latencyMs),
    cost_usd: cost !== null && cost !== undefined && Number.isFinite(cost) && cost >= 0 ? cost : null,
    success: input.success ?? true,
    error_code: short(input.errorCode, 80),
    properties,
  };
}
