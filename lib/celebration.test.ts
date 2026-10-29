// Святковий екран після уроку (lib/celebration.ts). Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  CONFETTI_COLORS, answerStreakNote, assessmentCheer, confettiPieces, lessonCelebration, roleplayCheer, roleplayTiles, streakNote,
} from './celebration.ts';

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

test('Рольова гра: 🎉 з конфеті лише коли завдання виконано; 💪 — розмова була; 🌱 — нічого не сказали', () => {
  assert.deepEqual(roleplayCheer(true, 4), { emoji: '🎉', title: 'Завдання виконано!', celebrate: true });
  assert.equal(roleplayCheer(false, 3).emoji, '💪');
  assert.equal(roleplayCheer(false, 3).celebrate, false);
  assert.equal(roleplayCheer(false, 0).emoji, '🌱');
});

test('Рольова гра: плитки реплік і фраз на повторення, українські форми', () => {
  assert.deepEqual(roleplayTiles({ userTurns: 5, errorsSaved: 2 }).map((t) => [t.emoji, t.value, t.label, t.tone]), [
    ['💬', '5', 'ваших реплік', 'success'],
    ['🔁', '2', 'фрази на повторення', 'warning'],
  ]);
  assert.equal(roleplayTiles({ userTurns: 1, errorsSaved: 0 })[0].label, 'ваша репліка');
  assert.deepEqual(roleplayTiles({ userTurns: 0, errorsSaved: 0 }), []);
});

test('Перевірка рівня: пройдено — 🎉 і конфеті; ні — 💪 / 🌱 без «провалу»', () => {
  assert.deepEqual(assessmentCheer(true, 0.9), { emoji: '🎉', title: 'Пройдено!', celebrate: true });
  assert.equal(assessmentCheer(false, 0.65).emoji, '💪');
  assert.equal(assessmentCheer(false, 0.2).emoji, '🌱');
  for (const c of [assessmentCheer(false, 0.65), assessmentCheer(false, 0.2)]) {
    assert.equal(c.celebrate, false);
    assert.doesNotMatch(c.title, /провал|не склали|погано/i);
  }
});

test('Вправи уроку: серія правильних поспіль — з третьої', () => {
  assert.equal(answerStreakNote(0), null);
  assert.equal(answerStreakNote(2), null);
  assert.equal(answerStreakNote(3), '🔥 3 поспіль!');
  assert.equal(answerStreakNote(7), '🔥 7 поспіль!');
});
