import { test } from 'node:test';
import assert from 'node:assert/strict';
import { GOAL_MODULES, GOAL_SHARE, goalModules } from './goals.ts';
import { LEARNING_GOALS } from './onboarding.ts';

test('мети: кожна мета з онбордингу має мапу модулів, номери в межах рівня', () => {
  for (const g of LEARNING_GOALS) {
    const map = GOAL_MODULES[g.key];
    assert.ok(map, g.key);
    for (const m of map.A0) assert.ok(m >= 1 && m <= 11, `${g.key} A0.${m}`);
    for (const m of map.A1) assert.ok(m >= 1 && m <= 13, `${g.key} A1.${m}`);
    assert.ok(map.A2.length > 0, `${g.key}: A2 без модулів`);
    for (const m of map.A2) assert.ok(m >= 1 && m <= 13, `${g.key} A2.${m} (A2.14 — підсумок, без мети)`);
  }
  assert.equal(GOAL_SHARE, 1 / 3);
});

test('мети: нові «Навчання» і «Туризм і подорожі» (2026-11-08)', () => {
  const keys = LEARNING_GOALS.map((g) => g.key);
  assert.ok(keys.includes('study'));
  assert.equal(LEARNING_GOALS.find((g) => g.key === 'travel')?.label, 'Туризм і подорожі');
  assert.deepEqual(goalModules(['study'], 'A1'), [12]);
  assert.deepEqual(goalModules(['travel'], 'A0'), [8, 10, 11]);
});

test('мети: кілька мет — об’єднання без повторів; невідомі мета й рівень — порожньо', () => {
  assert.deepEqual(goalModules(['documents', 'travel'], 'A0'), [8, 10, 11]);
  assert.deepEqual(goalModules(['work', 'documents'], 'A1'), [6, 7, 12]);
  assert.deepEqual(goalModules(['hack'], 'A1'), []);
  assert.deepEqual(goalModules(['travel'], 'B1'), []);
  assert.deepEqual(goalModules([], 'A0'), []);
});

test('мети: модулі A2 v2 (2026-11-15) — за темою модуля', () => {
  assert.deepEqual(goalModules(['work'], 'A2'), [5]);
  assert.deepEqual(goalModules(['study'], 'A2'), [2]);
  assert.deepEqual(goalModules(['travel'], 'A2'), [1, 11]);
  assert.deepEqual(goalModules(['documents', 'daily_life'], 'A2'), [6, 7, 8, 9, 12]);
  assert.deepEqual(goalModules(['social'], 'A2'), [4, 10, 13]);
});
