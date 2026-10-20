import { test } from 'node:test';
import assert from 'node:assert/strict';
import { activityLevel, activityWeek, learningStreak } from './progress.ts';

const NOW = new Date('2026-10-20T09:00:00Z'); // вівторок, 11:00 у Варшаві

test('тиждень: 7 днів, сьогодні — останній, підписи українською (Вт, не Вв)', () => {
  const week = activityWeek([], NOW, 'Europe/Warsaw');
  assert.equal(week.length, 7);
  assert.equal(week[6].date, '2026-10-20');
  assert.equal(week[6].label, 'Вт');
  assert.equal(week[0].label, 'Ср');
  assert.ok(week.every((d) => d.count === 0 && d.level === 0));
});

test('заняття о 00:30 за Варшавою — сьогоднішній день, а не вчорашній (UTC)', () => {
  const week = activityWeek(['2026-10-19T22:30:00Z'], NOW, 'Europe/Warsaw');
  assert.equal(week[6].count, 1);
  assert.equal(week[5].count, 0);
  const utc = activityWeek(['2026-10-19T22:30:00Z'], NOW, 'UTC');
  assert.equal(utc[5].count, 1);
});

test('рівні насиченості', () => {
  assert.deepEqual([0, 1, 5, 6, 15, 16, 30, 31].map(activityLevel), [0, 1, 1, 2, 2, 3, 3, 4]);
  const week = activityWeek(Array.from({ length: 7 }, () => '2026-10-20T08:00:00Z'), NOW, 'Europe/Warsaw');
  assert.equal(week[6].level, 2);
});

test('серія: дні поспіль; сьогодні ще не вчилися — рахуємо від учора', () => {
  const ts = ['2026-10-19T10:00:00Z', '2026-10-18T10:00:00Z', '2026-10-18T11:00:00Z', '2026-10-16T10:00:00Z'];
  assert.equal(learningStreak(ts, NOW, 'Europe/Warsaw'), 2);
  assert.equal(learningStreak([...ts, '2026-10-20T07:00:00Z'], NOW, 'Europe/Warsaw'), 3);
  assert.equal(learningStreak(['2026-10-17T10:00:00Z'], NOW, 'Europe/Warsaw'), 0);
  assert.equal(learningStreak([], NOW, 'Europe/Warsaw'), 0);
  assert.equal(learningStreak(['не дата'], NOW, 'Europe/Warsaw'), 0);
});
