/**
 * Абстракція AI (§78): продукт працює з інтерфейсом, а не з конкретним SDK.
 * Реалізація зараз — Gemini (lib/ai-gemini.ts). Інший провайдер = новий файл з тим самим інтерфейсом.
 */
import type { AiFeature } from './ai-usage.ts';

export interface AIMessage {
  role: 'user' | 'assistant';
  content: string;
}

export interface AIRequest {
  /** Системна інструкція (роль, правила, формат) */
  system: string;
  messages: AIMessage[];
  /** Для обліку витрат (ai_usage_events.feature) */
  feature: AiFeature;
  /** Відповідь — строго JSON */
  json?: boolean;
  temperature?: number;
  maxOutputTokens?: number;
}

export interface AIResult {
  text: string;
  model: string;
  inputTokens?: number;
  outputTokens?: number;
  latencyMs: number;
}

export class AIError extends Error {
  constructor(public code: 'not_configured' | 'provider_error' | 'invalid_output' | 'rate_limited', message?: string) {
    super(message ?? code);
    this.name = 'AIError';
  }
}

export interface AIProvider {
  readonly id: string;
  /** Звичайна відповідь (chat) */
  chat(request: AIRequest): Promise<AIResult>;
  /** Структурована відповідь: JSON → перевірка parse(); некоректне — AIError('invalid_output') */
  structuredOutput<T>(request: AIRequest, parse: (raw: string) => T | null): Promise<{ value: T; result: AIResult }>;
  // evaluate(), generate_content(), classify() (§78) — додаються, коли з'являться відповідні функції
}
