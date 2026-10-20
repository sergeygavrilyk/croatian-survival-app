import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  buildModelChain, classifyAiFailure, shouldTryNextModel, outputTokenLimit, isTruncatedFinish, DEFAULT_PRIMARY_MODEL, MAX_MODELS,
  THINKING_HEADROOM_TOKENS,
} from './ai-fallback.ts';

test('ланцюжок моделей: типовий — основна + запасні', () => {
  assert.deepEqual(buildModelChain(undefined, undefined), [DEFAULT_PRIMARY_MODEL, 'gemini-3.8-flash', 'gemini-3.5-flash-lite']);
});

test('ланцюжок моделей: зі змінних оточення, без повторів і порожніх', () => {
  assert.deepEqual(buildModelChain('gemini-x', ' gemini-y , ,gemini-x,gemini-z '), ['gemini-x', 'gemini-y', 'gemini-z']);
  assert.deepEqual(buildModelChain('  ', ''), buildModelChain(undefined, undefined));
});

test('ланцюжок моделей: не довший за MAX_MODELS і без дивних назв', () => {
  const chain = buildModelChain('a1', 'b1,c1,d1,e1,f1,bad name,../x');
  assert.equal(chain.length, MAX_MODELS);
  assert.ok(!chain.includes('bad name'));
});

test('класифікація збоїв Gemini', () => {
  assert.equal(classifyAiFailure('[503 Service Unavailable] This model is currently experiencing high demand. Please try again later.'), 'overloaded');
  assert.equal(classifyAiFailure('[429 Too Many Requests] Resource has been exhausted'), 'overloaded');
  assert.equal(classifyAiFailure('[404 Not Found] models/gemini-1.0-pro is not found for API version v1beta'), 'model_unavailable');
  assert.equal(classifyAiFailure('This model is no longer available'), 'model_unavailable');
  assert.equal(classifyAiFailure('Request timed out'), 'timeout');
  assert.equal(classifyAiFailure('[400 Bad Request] API key not valid. Please pass a valid API key.'), 'fatal');
  assert.equal(classifyAiFailure('[403 Forbidden] Permission denied'), 'fatal');
  assert.equal(classifyAiFailure('щось зовсім незрозуміле'), 'fatal');
});

test('наступну модель пробуємо лише для тимчасових збоїв і вимкнених моделей', () => {
  assert.equal(shouldTryNextModel('overloaded'), true);
  assert.equal(shouldTryNextModel('model_unavailable'), true);
  assert.equal(shouldTryNextModel('timeout'), true);
  assert.equal(shouldTryNextModel('truncated'), true);
  assert.equal(shouldTryNextModel('fatal'), false);
});

test('обірвана відповідь (MAX_TOKENS) — збій «truncated», пробуємо наступну модель', () => {
  assert.equal(isTruncatedFinish('MAX_TOKENS'), true);
  assert.equal(isTruncatedFinish('max_tokens'), true);
  assert.equal(isTruncatedFinish('STOP'), false);
  assert.equal(isTruncatedFinish(undefined), false);
  assert.equal(classifyAiFailure('truncated: finishReason MAX_TOKENS'), 'truncated');
  assert.equal(shouldTryNextModel(classifyAiFailure('truncated: finishReason MAX_TOKENS')), true);
});

test('ліміт токенів: відповідь + запас на роздуми моделі', () => {
  assert.equal(outputTokenLimit(200), 200 + THINKING_HEADROOM_TOKENS);
  assert.equal(outputTokenLimit(undefined), 600 + THINKING_HEADROOM_TOKENS);
  assert.equal(outputTokenLimit(0), 600 + THINKING_HEADROOM_TOKENS);
  assert.ok(outputTokenLimit(200) >= 1200, 'переклад з лімітом 200 більше не обривається на роздумах');
});
