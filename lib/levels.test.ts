import { test } from 'node:test';
import assert from 'node:assert/strict';
import { LEVEL_CODES, LEVEL_STYLES, levelStyle, moduleIcon } from './levels.ts';

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
  assert.equal(moduleIcon('B2', 12), '🏆');
});

test('moduleIcon: новий модуль — за назвою, інакше 📚', () => {
  assert.equal(moduleIcon('A1', 11, 'Модуль A1.11 — Далмація і Задар'), '⛵');
  assert.equal(moduleIcon('A2', 15, 'Modul A2.15 — Hrana i restorani'), '🍽️');
  assert.equal(moduleIcon('C1', 1, 'Щось нове'), '📚');
  assert.equal(moduleIcon(null, null), '📚');
});

test('moduleIcon: без прапорів (у Windows показуються літерами)', () => {
  for (const level of LEVEL_CODES) {
    for (let order = 1; order <= 12; order++) {
      const icon = moduleIcon(level, order);
      assert.ok(![...icon].some((ch) => { const c = ch.codePointAt(0)!; return c >= 0x1f1e6 && c <= 0x1f1ff; }), `${level}.${order}`);
    }
  }
});
