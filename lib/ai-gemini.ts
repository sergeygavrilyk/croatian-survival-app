/**
 * AIProvider на Gemini (лише сервер). Кожна спроба записується в ai_usage_events (§74).
 *
 * Стійкість (рішення власника 2026-10-13):
 *   * моделі пробуємо по черзі: GEMINI_MODEL → GEMINI_FALLBACK_MODELS (типові — у lib/ai-fallback.ts);
 *   * до наступної моделі переходимо, якщо поточна перевантажена (503 / 429), вимкнена (404)
 *     або не відповіла вчасно; помилки ключа / доступу не повторюємо;
 *   * якщо не відповіла жодна — AIError('unavailable'), користувач бачить «спробуйте за хвилину».
 */
import { GoogleGenerativeAI } from '@google/generative-ai';
import { recordAiUsage } from '@/lib/ai-usage-server';
import { AIError, type AIProvider, type AIRequest, type AIResult } from '@/lib/ai-provider';
import { buildModelChain, classifyAiFailure, shouldTryNextModel } from '@/lib/ai-fallback';

/** Скільки чекаємо одну модель, мс (10 с: 2026-10-13 перевантажена модель «висіла» по 15 с, і репліка в рольовій грі йшла 30+ с) */
const ATTEMPT_TIMEOUT_MS = 10_000;

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

function client() {
  const key = process.env.GEMINI_API_KEY;
  if (!key) throw new AIError('not_configured', 'GEMINI_API_KEY не налаштовано');
  return new GoogleGenerativeAI(key);
}

async function chatWithModel(genAI: GoogleGenerativeAI, modelName: string, request: AIRequest): Promise<AIResult> {
  const startedAt = Date.now();
  const model = genAI.getGenerativeModel(
    {
      model: modelName,
      systemInstruction: request.system,
      generationConfig: {
        temperature: request.temperature ?? 0.7,
        maxOutputTokens: request.maxOutputTokens ?? 600,
        ...(request.json ? { responseMimeType: 'application/json' } : {}),
      },
    },
    { timeout: ATTEMPT_TIMEOUT_MS },
  );
  // Gemini: ролі user / model; історія має починатися з user
  const contents = request.messages.map((m) => ({ role: m.role === 'assistant' ? 'model' : 'user', parts: [{ text: m.content }] }));
  if (contents.length === 0 || contents[0].role !== 'user') contents.unshift({ role: 'user', parts: [{ text: 'Počni.' }] });

  const res = await model.generateContent({ contents });
  const usage = res.response.usageMetadata;
  return {
    text: res.response.text(),
    model: modelName,
    inputTokens: usage?.promptTokenCount,
    outputTokens: usage?.candidatesTokenCount,
    latencyMs: Date.now() - startedAt,
  };
}

async function chat(request: AIRequest): Promise<AIResult> {
  const genAI = client();
  const chain = buildModelChain(process.env.GEMINI_MODEL, process.env.GEMINI_FALLBACK_MODELS);
  let lastMessage = 'no models';

  for (let i = 0; i < chain.length; i++) {
    const modelName = chain[i];
    const startedAt = Date.now();
    try {
      const result = await chatWithModel(genAI, modelName, request);
      await recordAiUsage({
        feature: request.feature,
        provider: 'gemini',
        model: modelName,
        inputTokens: result.inputTokens,
        outputTokens: result.outputTokens,
        latencyMs: result.latencyMs,
      });
      if (i > 0) console.warn(`AI: відповіла запасна модель ${modelName} (спроба ${i + 1})`);
      return result;
    } catch (err) {
      lastMessage = err instanceof Error ? err.message : String(err);
      const kind = classifyAiFailure(lastMessage);
      await recordAiUsage({
        feature: request.feature,
        provider: 'gemini',
        model: modelName,
        latencyMs: Date.now() - startedAt,
        success: false,
        errorCode: kind,
      });
      console.warn(`AI: модель ${modelName} — ${kind}: ${lastMessage.slice(0, 200)}`);
      if (!shouldTryNextModel(kind)) throw new AIError('provider_error', lastMessage);
      if (i < chain.length - 1) await sleep(300);
    }
  }
  // Жодна модель не відповіла — тимчасова недоступність
  throw new AIError('unavailable', lastMessage);
}

async function structuredOutput<T>(request: AIRequest, parse: (raw: string) => T | null) {
  const result = await chat({ ...request, json: true });
  const value = parse(result.text);
  if (value === null) throw new AIError('invalid_output', 'Некоректна відповідь AI');
  return { value, result };
}

export const gemini: AIProvider = { id: 'gemini', chat, structuredOutput };

/** Поточний провайдер AI. Заміна провайдера — лише тут. */
export function getAIProvider(): AIProvider {
  return gemini;
}
