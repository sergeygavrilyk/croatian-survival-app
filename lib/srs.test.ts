// Тести логіки SRS. Запуск: node --test --experimental-strip-types lib/srs.test.ts
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { scheduleReview, normalizeCroatian, NEW_CARD, MIN_EASE, MAX_EASE } from './srs.ts';

const now = new Date('2026-10-12T15:30:00');

test('нова картка, «Знаю» → повтор завтра', () => {
  const r = scheduleReview(NEW_CARD, true, now);
  assert.equal(r.intervalDays, 1);
  assert.equal(r.repetitionCount, 1);
  assert.equal(r.nextReviewDate.toDateString(), new Date('2026-10-13').toDateString());
  assert.equal(r.nextReviewDate.getHours(), 0);
});

test('другий успіх → 3 дні, третій → interval × ease', () => {
  const r1 = scheduleReview(NEW_CARD, true, now);
  const r2 = scheduleReview(r1, true, now);
  assert.equal(r2.intervalDays, 3);
  const r3 = scheduleReview(r2, true, now);
  assert.equal(r3.intervalDays, Math.round(3 * r2.easeFactor));
  assert.ok(r3.intervalDays > r2.intervalDays);
});

test('«Не знаю» → сьогодні, скидання серії, lapse для вивченої картки', () => {
  const learned = scheduleReview(scheduleReview(NEW_CARD, true, now), true, now);
  const r = scheduleReview(learned, false, now);
  assert.equal(r.intervalDays, 0);
  assert.equal(r.repetitionCount, 0);
  assert.equal(r.lapses, 1);
  assert.equal(r.nextReviewDate.getTime(), now.getTime());
  assert.ok(r.easeFactor < learned.easeFactor);
});

test('«Не знаю» на новій картці — не lapse', () => {
  assert.equal(scheduleReview(NEW_CARD, false, now).lapses, 0);
});

test('ease не виходить за межі', () => {
  let s = { ...NEW_CARD };
  for (let i = 0; i < 30; i++) s = scheduleReview(s, false, now);
  assert.equal(s.easeFactor, MIN_EASE);
  for (let i = 0; i < 30; i++) s = scheduleReview(s, true, now);
  assert.equal(s.easeFactor, MAX_EASE);
});

test('інтервал завжди росте при успіхах (навіть з мінімальним ease)', () => {
  let s = { ...NEW_CARD, easeFactor: MIN_EASE };
  let last = 0;
  for (let i = 0; i < 8; i++) {
    s = scheduleReview(s, true, now);
    assert.ok(s.intervalDays > last, `крок ${i}: ${s.intervalDays} > ${last}`);
    last = s.intervalDays;
  }
});

test('normalizeCroatian', () => {
  assert.equal(normalizeCroatian('  Kožna jakna '), 'kozna jakna');
  assert.equal(normalizeCroatian('Čaša, ćevapi, đak, šuma, žena'), 'casa, cevapi, dak, suma, zena');
});
