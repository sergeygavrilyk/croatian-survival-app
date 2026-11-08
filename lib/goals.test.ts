import { test } from 'node:test';
import assert from 'node:assert/strict';
import { GOAL_MODULES, GOAL_SHARE, goalModules } from './goals.ts';
import { LEARNING_GOALS } from './onboarding.ts';

test('мети: кожна мета з онбордингу має мапу модулів, номери в межах рівня', () => {
  for (const g of LEARNING_GOALS) {
    const map = GOAL_MODULES[g.key];
    assert.ok(map, g.key);
    for (const m of map.A0) assert.ok(m >= 1 && m <= 10, `${g.key} A0.${m}`);
    for (const m of map.A1) assert.ok(m >= 1 && m <= 13, `${g.key} A1.${m}`);
  }
  assert.equal(GOAL_SHARE, 1 / 3);
});

test('мети: нові «Навчання» і «Туризм і подорожі» (2026-11-08)', () => {
  const keys = LEARNING_GOALS.map((g) => g.key);
  assert.ok(keys.includes('study'));
  assert.equal(LEARNING_GOALS.find((g) => g.key === 'travel')?.label, 'Туризм і подорожі');
  assert.deepEqual(goalModules(['study'], 'A1'), [12]);
  assert.deepEqual(goalModules(['travel'], 'A0'), [7, 9, 10]);
});

test('мети: кілька мет — об’єднання без повторів; невідомі мета й рівень — порожньо', () => {
  assert.deepEqual(goalModules(['documents', 'travel'], 'A0'), [7, 9, 10]);
  assert.deepEqual(goalModules(['work', 'documents'], 'A1'), [6, 7, 12]);
  assert.deepEqual(goalModules(['hack'], 'A1'), []);
  assert.deepEqual(goalModules(['travel'], 'B1'), []);
  assert.deepEqual(goalModules([], 'A0'), []);
});
