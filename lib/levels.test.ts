import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  LEVEL_CODES, LEVEL_STYLES, assessmentIcon, isLevelAtMost, isLevelCode, levelRank, levelStyle, levelsPresent, moduleIcon,
  nearestLowerLevel, nextLevelCode, previousLevelCode,
} from './levels.ts';

test('кожен рівень має свій колір', () => {
  const solids = LEVEL_CODES.map((l) => LEVEL_STYLES[l].solid);
  assert.equal(new Set(solids).size, LEVEL_CODES.length);
  for (const l of LEVEL_CODES) {
    assert.match(LEVEL_STYLES[l].soft, new RegExp(`level-${l.toLowerCase()}-soft`));
    assert.ok(LEVEL_STYLES[l].name.length > 0);
  }
});

test('levelStyle: регістр і невідомий рівень', () => {
  assert.equal(levelStyle('a1'), LEVEL_STYLES.A1);
  assert.equal(levelStyle(' B2 '), LEVEL_STYLES.B2);
  assert.equal(levelStyle('C1'), LEVEL_STYLES.A0);
  assert.equal(levelStyle(null), LEVEL_STYLES.A0);
});

test('moduleIcon: за рівнем і номером', () => {
  assert.equal(moduleIcon('A0', 1), '👋');
  assert.equal(moduleIcon('A0', 7), '🍽️');
  assert.equal(moduleIcon('A0', 10), '🆘');
  assert.equal(moduleIcon('a1', 4), '🚌');
  assert.equal(moduleIcon('A1', 7), '💻');
  assert.equal(moduleIcon('A1', 8), '🩺');
  assert.equal(moduleIcon('A1', 13), '🏆');
  assert.equal(moduleIcon('B2', 12), '🏆');
});

test('moduleIcon: новий модуль — за назвою, інакше 📚', () => {
  assert.equal(moduleIcon('A1', 14, 'Модуль A1.14 — Далмація і Задар'), '⛵');
  assert.equal(moduleIcon('A2', 15, 'Modul A2.15 — Hrana i restorani'), '🍽️');
  assert.equal(moduleIcon('C1', 1, 'Щось нове'), '📚');
  assert.equal(moduleIcon(null, null), '📚');
});

test('moduleIcon: без прапорів (у Windows показуються літерами)', () => {
  for (const level of LEVEL_CODES) {
    for (let order = 1; order <= 13; order++) {
      const icon = moduleIcon(level, order);
      assert.ok(![...icon].some((ch) => { const c = ch.codePointAt(0)!; return c >= 0x1f1e6 && c <= 0x1f1ff; }), `${level}.${order}`);
    }
  }
});

test('assessmentIcon: модуль — емодзі модуля, середина — 🚩, фінал — 🏆', () => {
  assert.equal(assessmentIcon('module', 'A0', 7), moduleIcon('A0', 7));
  assert.equal(assessmentIcon('mid', 'A1', null), '🚩');
  assert.equal(assessmentIcon('final', 'A0'), '🏆');
});

test('ARCH-03: порядок рівнів, наступний і попередній — з одного списку', () => {
  assert.deepEqual([...LEVEL_CODES], ['A0', 'A1', 'A2', 'B1', 'B2']);
  assert.ok(isLevelCode('B1'));
  assert.ok(!isLevelCode('b1'));
  assert.ok(!isLevelCode('C1'));
  assert.ok(!isLevelCode(null));
  assert.equal(levelRank('A0'), 0);
  assert.equal(levelRank('B2'), 4);
  assert.equal(levelRank('C1'), -1);
  assert.equal(levelRank(null), -1);
  assert.equal(nextLevelCode('A1'), 'A2');
  assert.equal(nextLevelCode('B2'), null);
  assert.equal(nextLevelCode('x'), null);
  assert.equal(previousLevelCode('A2'), 'A1');
  assert.equal(previousLevelCode('B1'), 'A2');
  assert.equal(previousLevelCode('A0'), null);
  assert.equal(previousLevelCode('x'), null);
  assert.ok(isLevelAtMost('A0', 'A1'));
  assert.ok(isLevelAtMost('A1', 'A1'));
  assert.ok(!isLevelAtMost('A2', 'A1'));
  assert.ok(!isLevelAtMost(null, 'A1'));
});

test('ARCH-03: рівні з бази — без повторів, у порядку, невідомі пропущено; новий рівень видно одразу', () => {
  assert.deepEqual(levelsPresent(['A1', 'A0', 'A1', null, 'C1', undefined, 'A2']), ['A0', 'A1', 'A2']);
  assert.deepEqual(levelsPresent([]), []);
  // опублікували перевірки B1 — рівень з'являється без правки коду
  assert.deepEqual(levelsPresent(['A0', 'A1', 'A2', 'B1']), ['A0', 'A1', 'A2', 'B1']);
});

test('ARCH-03: найближчий нижчий наявний рівень', () => {
  assert.equal(nearestLowerLevel('B1', ['A0', 'A1', 'A2']), 'A2');
  assert.equal(nearestLowerLevel('B2', ['A0', 'A1']), 'A1');
  assert.equal(nearestLowerLevel('A0', ['A0', 'A1']), null);
  assert.equal(nearestLowerLevel('A2', ['B1']), null);
  assert.equal(nearestLowerLevel('C1', ['A0']), null);
});
