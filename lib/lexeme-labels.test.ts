// Мітки живої лексики (lib/lexeme-labels.ts). Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  DEFAULT_LABELS, REGIONS, REGION_LABELS, REGISTERS, REGISTER_LABELS, USAGE_TAGS, USAGE_TAG_LABELS, toggleTag, validateLabels,
} from './lexeme-labels.ts';

test('Мітки: переліки як у CHECK M24 (6 регістрів, 9 регіонів з великої літери, 11 ознак), у кожного — підпис', () => {
  assert.deepEqual([...REGISTERS], ['standard', 'formal', 'informal', 'colloquial', 'slang', 'vulgar']);
  assert.equal(REGIONS.length, 9);
  assert.equal(REGIONS[0], 'general');
  for (const r of REGIONS.slice(1)) assert.match(r, /^[A-Z][a-z]+$/);
  assert.equal(USAGE_TAGS.length, 11);
  assert.ok(USAGE_TAGS.includes('offensive') && USAGE_TAGS.includes('kajkavian'));
  for (const r of REGISTERS) assert.ok(REGISTER_LABELS[r]);
  for (const r of REGIONS) assert.ok(REGION_LABELS[r]);
  for (const t of USAGE_TAGS) assert.ok(USAGE_TAG_LABELS[t]);
});

test('Мітки: звичайне слово — standard / general / [] і проходить перевірку', () => {
  assert.deepEqual(DEFAULT_LABELS, { register: 'standard', regionality: 'general', usage_tags: [] });
  assert.deepEqual(validateLabels(DEFAULT_LABELS), []);
  assert.deepEqual(validateLabels({ register: 'slang', regionality: 'Zagreb', usage_tags: ['youth_slang', 'anglicism'] }), []);
});

test('Мітки: без значення чи з невідомим значенням — помилка', () => {
  assert.equal(validateLabels({}).length, 3);
  assert.equal(validateLabels({ register: '', regionality: 'general', usage_tags: [] }).length, 1);
  assert.equal(validateLabels({ register: 'regional', regionality: 'general', usage_tags: [] }).length, 1); // старе значення
  assert.equal(validateLabels({ register: 'standard', regionality: 'dalmatia', usage_tags: [] }).length, 1); // з малої літери
  assert.equal(validateLabels({ register: 'standard', regionality: 'general', usage_tags: null }).length, 1);
  assert.equal(validateLabels({ register: 'standard', regionality: 'general', usage_tags: ['regionalism'] }).length, 1);
  assert.equal(validateLabels({ register: 'standard', regionality: 'general', usage_tags: ['idiom', 'idiom'] }).length, 1);
});

test('Мітки: toggleTag вмикає й вимикає ознаку, без повторів, у порядку переліку', () => {
  assert.deepEqual(toggleTag([], 'anglicism'), ['anglicism']);
  assert.deepEqual(toggleTag(['anglicism'], 'youth_slang'), ['youth_slang', 'anglicism']);
  assert.deepEqual(toggleTag(['youth_slang', 'anglicism'], 'anglicism'), ['youth_slang']);
});
