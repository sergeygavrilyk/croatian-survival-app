import { test } from 'node:test';
import assert from 'node:assert/strict';
import { higherLevel, skillProgressRows, skillScores } from './skill-progress.ts';

const items = [
  { id: 'l1', skill: 'listening' }, { id: 'l2', skill: 'listening' }, { id: 'l3', skill: 'listening' },
  { id: 'w1', skill: 'writing' }, { id: 's1', skill: 'speaking' }, { id: 'x', skill: 'unknown' },
];
const graded = [
  { item_id: 'l1', correct: true, skipped: false }, { item_id: 'l2', correct: true, skipped: false },
  { item_id: 'l3', correct: false, skipped: false }, { item_id: 'w1', correct: true, skipped: false },
  { item_id: 's1', correct: false, skipped: true }, { item_id: 'x', correct: true, skipped: false },
];

test('skillScores: правильні / усього за навичкою; пропущене говоріння й невідома навичка — не рахуються', () => {
  const s = skillScores(items, graded);
  assert.deepEqual(s.get('listening'), { correct: 2, total: 3 });
  assert.deepEqual(s.get('writing'), { correct: 1, total: 1 });
  assert.equal(s.has('speaking'), false);
  assert.equal(s.size, 2);
});

test('skillProgressRows: бал — останній результат; рівень — лише з фіналу ≥ 70 %', () => {
  const s = skillScores(items, graded);
  assert.deepEqual(skillProgressRows('final', 'A1', s, []), [
    { skill: 'listening', level_estimate: null, xp_or_score: 67 },
    { skill: 'writing', level_estimate: 'A1', xp_or_score: 100 },
  ]);
  // перевірка модуля чи середини рівня не ставить
  assert.deepEqual(skillProgressRows('mid', 'A1', s, []).map((r) => r.level_estimate), [null, null]);
  assert.deepEqual(skillProgressRows('module', 'A1', s, []).map((r) => r.level_estimate), [null, null]);
});

test('skillProgressRows: рівень не знижується', () => {
  const s = skillScores(items, graded);
  const rows = skillProgressRows('final', 'A0', s, [{ skill: 'listening', level_estimate: 'A1' }, { skill: 'writing', level_estimate: 'A1' }]);
  assert.deepEqual(rows.map((r) => r.level_estimate), ['A1', 'A1']);
  const up = skillProgressRows('final', 'A2', s, [{ skill: 'writing', level_estimate: 'A1' }]);
  assert.equal(up.find((r) => r.skill === 'writing')?.level_estimate, 'A2');
});

test('higherLevel: порядок рівнів, невідомий ігнорується', () => {
  assert.equal(higherLevel('A0', 'A2'), 'A2');
  assert.equal(higherLevel('B1', 'A2'), 'B1');
  assert.equal(higherLevel(null, 'A1'), 'A1');
  assert.equal(higherLevel('X', null), null);
});
