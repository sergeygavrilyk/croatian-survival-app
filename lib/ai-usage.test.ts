import { test } from 'node:test';
import assert from 'node:assert/strict';
import { toAiUsageRow } from './ai-usage.ts';

test('коректна подія AI перетворюється на рядок таблиці', () => {
  const row = toAiUsageRow({
    feature: 'quick_translate', provider: 'Gemini', model: 'gemini-x',
    inputTokens: 120.4, outputTokens: 18, latencyMs: 812.6, properties: { chars_in: 24 },
  });
  assert.deepEqual(row, {
    feature: 'quick_translate', provider: 'gemini', model: 'gemini-x',
    input_tokens: 120, output_tokens: 18, characters: null, audio_ms: null, latency_ms: 813,
    cost_usd: null, success: true, error_code: null, properties: { chars_in: 24 },
  });
});

test('невідома функція або провайдер — подію не пишемо', () => {
  assert.equal(toAiUsageRow({ feature: 'hack' as never, provider: 'gemini' }), null);
  assert.equal(toAiUsageRow({ feature: 'tts', provider: 'Drop Table;' }), null);
  assert.equal(toAiUsageRow({ feature: 'tts', provider: '' }), null);
});

test('від\'ємні й нечислові значення відкидаються, довгі рядки обрізаються', () => {
  const row = toAiUsageRow({
    feature: 'tts', provider: 'google_translate_tts', inputTokens: -5, characters: Number.NaN,
    costUsd: -1, success: false, errorCode: 'x'.repeat(200), model: '  ',
  });
  assert.ok(row);
  assert.equal(row.input_tokens, null);
  assert.equal(row.characters, null);
  assert.equal(row.cost_usd, null);
  assert.equal(row.success, false);
  assert.equal(row.error_code?.length, 80);
  assert.equal(row.model, null);
});

test('завеликі properties не ламають запис — замінюються порожнім обʼєктом', () => {
  const row = toAiUsageRow({ feature: 'chat', provider: 'gemini', properties: { text: 'x'.repeat(5000) } });
  assert.deepEqual(row?.properties, {});
});
