import { test } from 'node:test';
import assert from 'node:assert/strict';
import { displayName, greetingFor, hourIn, nextLesson, todayLevel, weekCheer, type TodayLesson } from './today.ts';

test('година й привітання — у часовому поясі користувача', () => {
  const t = new Date('2026-10-20T09:30:00Z');
  assert.equal(hourIn(t, 'Europe/Warsaw'), 11);
  assert.equal(greetingFor(t, 'Europe/Warsaw'), 'Dobro jutro');
  assert.equal(greetingFor(new Date('2026-10-20T11:00:00Z'), 'Europe/Warsaw'), 'Dobar dan');
  assert.equal(greetingFor(new Date('2026-10-20T17:30:00Z'), 'Europe/Warsaw'), 'Dobra večer');
  assert.equal(greetingFor(new Date('2026-10-20T00:30:00Z'), 'Europe/Warsaw'), 'Dobra večer'); // 02:30 — ще ніч
  assert.equal(hourIn(t, 'Not/AZone'), 9);
});

const L = (id: string, m: number, u: number, o: number): TodayLesson => ({ id, title_ua: `Урок ${id}`, module_order: m, unit_order: u, order_index: o });

test('наступний урок — перший непройдений у порядку модуль → юніт → урок', () => {
  const lessons = [L('c', 2, 1, 1), L('a', 1, 1, 1), L('b', 1, 1, 2)];
  assert.deepEqual(nextLesson(lessons, new Set()), { lesson: lessons[1], done: 0, total: 3 });
  assert.equal(nextLesson(lessons, new Set(['a'])).lesson?.id, 'b');
  assert.equal(nextLesson(lessons, new Set(['b'])).lesson?.id, 'a'); // пропущений раніше урок — першим
  assert.deepEqual(nextLesson(lessons, new Set(['a', 'b', 'c'])), { lesson: null, done: 3, total: 3 });
  assert.deepEqual(nextLesson([], new Set()), { lesson: null, done: 0, total: 0 });
});

test('рівень для «Продовжити» і ім’я', () => {
  assert.equal(todayLevel('A1', ['A0', 'A1']), 'A1');
  assert.equal(todayLevel('B1', ['A0', 'A1']), 'A0');
  assert.equal(todayLevel(null, ['A0', 'A1']), 'A0');
  assert.equal(displayName('Serhii Havryliuk', 'x@y.z'), 'Serhii');
  assert.equal(displayName('', 'dasha@example.com'), 'dasha');
  assert.equal(displayName(null, null), 'друже');
});

test('weekCheer: підбадьорення за днями тижня', () => {
  assert.match(weekCheer(0), /Почніть сьогодні/);
  assert.match(weekCheer(1), /початок/);
  assert.match(weekCheer(3), /ритм/);
  assert.match(weekCheer(5), /Чудовий/);
  assert.match(weekCheer(7), /Цілий тиждень/);
});

test('sessionCheer: підбадьорення за часткою правильних, без «провалу»', async () => {
  const { sessionCheer } = await import('./today.ts');
  assert.deepEqual(sessionCheer(10, 10), { emoji: '🎉', title: 'Чудово!' });
  assert.equal(sessionCheer(8, 10).emoji, '🎉');
  assert.equal(sessionCheer(5, 10).emoji, '💪');
  assert.equal(sessionCheer(4, 10).emoji, '🌱');
  assert.equal(sessionCheer(0, 0).emoji, '🌱');
  assert.equal(sessionCheer(-1, 3).emoji, '🌱');
});
