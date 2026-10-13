/**
 * Запасні моделі AI (чиста логіка, без SDK — тестується в ai-fallback.test.ts).
 *
 * Навіщо: одна модель Gemini може бути тимчасово перевантажена (503 «high demand»)
 * або вимкнена Google (404 / «no longer available»). Тоді пробуємо наступну модель
 * зі списку, а не показуємо помилку одразу.
 *
 * Рішення власника 2026-10-13: основна — gemini-3.6-flash, запасні — новіша
 * gemini-3.8-flash і легша gemini-3.5-flash-lite (інший пул потужностей).
 * Список можна змінити без зміни коду: GEMINI_MODEL і GEMINI_FALLBACK_MODELS (через кому).
 */

export const DEFAULT_PRIMARY_MODEL = 'gemini-3.6-flash';
export const DEFAULT_FALLBACK_MODELS = ['gemini-3.8-flash', 'gemini-3.5-flash-lite'] as const;
/** Скільки моделей пробуємо максимум (захист від надто довгого очікування) */
export const MAX_MODELS = 4;

export type AiFailureKind =
  | 'overloaded'        // 503 / 500 / 429 — тимчасово, інша модель може відповісти
  | 'model_unavailable' // 404 / модель вимкнена чи перейменована
  | 'timeout'           // не відповіла вчасно
  | 'fatal';            // ключ, доступ, некоректний запит — інша модель не допоможе

/** Тип збою за текстом помилки SDK. */
export function classifyAiFailure(message: string): AiFailureKind {
  const m = message.toLowerCase();
  if (/\b(400|401|403)\b|api key|permission|invalid argument|safety|blocked/.test(m)) return 'fatal';
  if (/\b404\b|not found|no longer (available|supported)|deprecated|is not supported for/.test(m)) return 'model_unavailable';
  if (/timed? ?out|timeout|aborted/.test(m)) return 'timeout';
  if (/\b(429|500|502|503|504)\b|high demand|overloaded|unavailable|resource.?exhausted|try again later|internal error/.test(m)) return 'overloaded';
  return 'fatal';
}

/** Чи варто пробувати наступну модель після такого збою. */
export function shouldTryNextModel(kind: AiFailureKind): boolean {
  return kind !== 'fatal';
}

/**
 * Порядок моделей: основна (GEMINI_MODEL або типова), далі запасні
 * (GEMINI_FALLBACK_MODELS або типові). Без повторів і порожніх, не більше MAX_MODELS.
 */
export function buildModelChain(primaryEnv?: string | null, fallbacksEnv?: string | null): string[] {
  const primary = primaryEnv?.trim() || DEFAULT_PRIMARY_MODEL;
  const fallbacks = fallbacksEnv?.trim()
    ? fallbacksEnv.split(',').map((s) => s.trim())
    : [...DEFAULT_FALLBACK_MODELS];
  const chain: string[] = [];
  for (const model of [primary, ...fallbacks]) {
    if (model && /^[a-z0-9][a-z0-9.\-]*$/i.test(model) && !chain.includes(model)) chain.push(model);
  }
  return chain.slice(0, MAX_MODELS);
}
