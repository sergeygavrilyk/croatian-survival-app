// Святковий екран після уроку (lib/celebration.ts). Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { CONFETTI_COLORS, confettiPieces, lessonCelebration, streakNote } from './celebration.ts';

test('Свято: нові слова й серія → дві плитки «+N нових слів» і «🔥 N днів поспіль»', () => {
  const c = lessonCelebration({ newWords: 22, lessonWords: 22, streak: 5 });
  assert.deepEqual(c.tiles.map((t) => [t.emoji, t.value, t.label, t.tone]), [
    ['📚', '+22', 'нові слова', 'success'],
    ['🔥', '5', 'днів поспіль', 'warning'],
  ]);
  assert.equal(c.reviewNote, 'Нові слова чекають на вас у повторенні завтра.');
  assert.equal(c.streakNote, '5 днів поспіль — так тримати!');
});

test('Свято: українські форми множини', () => {
  const label = (n: number) => lessonCelebration({ newWords: n, lessonWords: n, streak: n }).tiles.map((t) => t.label);
  assert.deepEqual(label(1), ['нове слово', 'день поспіль']);
  assert.deepEqual(label(3), ['нові слова', 'дні поспіль']);
  assert.deepEqual(label(11), ['нових слів', 'днів поспіль']);
  assert.deepEqual(label(21), ['нове слово', 'день поспіль']);
  assert.equal(lessonCelebration({ newWords: 1, lessonWords: 20, streak: null }).reviewNote, 'Нове слово чекає на вас у повторенні завтра.');
});

test('Свято: урок удруге — «N слів повторили», без підказки про завтра', () => {
  const c = lessonCelebration({ newWords: 0, lessonWords: 24, streak: 2 });
  assert.deepEqual(c.tiles[0], { emoji: '📚', value: '24', label: 'слова повторили', tone: 'success' });
  assert.equal(c.reviewNote, null);
});

test('Свято: серія невідома (null) або 0 — плитки й рядка серії немає; урок без слів — без плитки слів', () => {
  assert.deepEqual(lessonCelebration({ newWords: 0, lessonWords: 0, streak: null }), { tiles: [], streakNote: null, reviewNote: null });
  assert.equal(lessonCelebration({ newWords: 3, lessonWords: 3, streak: 0 }).tiles.length, 1);
});

test('Серія: перший день, круглі дати, звичайні дні — без тиску й провини', () => {
  assert.equal(streakNote(1), 'Перший день серії! Завтра — другий 🔥');
  assert.equal(streakNote(7), 'Тиждень поспіль! Ви чудово тримаєте ритм.');
  assert.equal(streakNote(30), 'Місяць поспіль! Неймовірна наполегливість.');
  assert.equal(streakNote(4), '4 дні поспіль — так тримати!');
  for (let n = 1; n <= 400; n++) assert.doesNotMatch(streakNote(n)!, /не перерив|втрат|згорить|пропуст/i);
});

test('Конфеті: однаковий seed — однаковий набір; значення в межах', () => {
  const a = confettiPieces('lesson', 48);
  assert.deepEqual(a, confettiPieces('lesson', 48));
  assert.notDeepEqual(a, confettiPieces('other', 48));
  assert.equal(a.length, 48);
  for (const p of a) {
    assert.ok(p.left >= 0 && p.left <= 100);
    assert.ok(p.delay >= 0 && p.delay <= 600);
    assert.ok(p.duration >= 1800 && p.duration <= 3400);
    assert.ok(p.color >= 0 && p.color < CONFETTI_COLORS.length);
    assert.ok(p.width >= 6 && p.height >= p.width);
    if (p.round) assert.equal(p.height, p.width);
  }
  assert.equal(confettiPieces('x', 999).length, 150);
  assert.equal(confettiPieces('x', -5).length, 0);
});
