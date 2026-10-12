/**
 * AIProvider на Gemini (лише сервер). Кожен виклик записується в ai_usage_events (§74).
 * Модель — змінна оточення GEMINI_MODEL (за замовчуванням та сама, що й для перекладу).
 */
import { GoogleGenerativeAI } from '@google/generative-ai';
import { recordAiUsage } from '@/lib/ai-usage-server';
import { AIError, type AIProvider, type AIRequest, type AIResult } from '@/lib/ai-provider';

const DEFAULT_MODEL = 'gemini-3.5-flash';

function client() {
  const key = process.env.GEMINI_API_KEY;
  if (!key) throw new AIError('not_configured', 'GEMINI_API_KEY не налаштовано');
  return new GoogleGenerativeAI(key);
}

async function chat(request: AIRequest): Promise<AIResult> {
  const modelName = process.env.GEMINI_MODEL || DEFAULT_MODEL;
  const startedAt = Date.now();
  try {
    const model = client().getGenerativeModel({
      model: modelName,
      systemInstruction: request.system,
      generationConfig: {
        temperature: request.temperature ?? 0.7,
        maxOutputTokens: request.maxOutputTokens ?? 600,
        ...(request.json ? { responseMimeType: 'application/json' } : {}),
      },
    });
    // Gemini: ролі user / model; історія має починатися з user
    const contents = request.messages.map((m) => ({ role: m.role === 'assistant' ? 'model' : 'user', parts: [{ text: m.content }] }));
    if (contents.length === 0 || contents[0].role !== 'user') contents.unshift({ role: 'user', parts: [{ text: 'Počni.' }] });

    const res = await model.generateContent({ contents });
    const text = res.response.text();
    const usage = res.response.usageMetadata;
    const result: AIResult = {
      text,
      model: modelName,
      inputTokens: usage?.promptTokenCount,
      outputTokens: usage?.candidatesTokenCount,
      latencyMs: Date.now() - startedAt,
    };
    await recordAiUsage({
      feature: request.feature,
      provider: 'gemini',
      model: modelName,
      inputTokens: result.inputTokens,
      outputTokens: result.outputTokens,
      latencyMs: result.latencyMs,
    });
    return result;
  } catch (err) {
    if (err instanceof AIError) throw err;
    await recordAiUsage({
      feature: request.feature,
      provider: 'gemini',
      model: modelName,
      latencyMs: Date.now() - startedAt,
      success: false,
      errorCode: err instanceof Error ? err.name : 'unknown',
    });
    throw new AIError('provider_error', err instanceof Error ? err.message : String(err));
  }
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
