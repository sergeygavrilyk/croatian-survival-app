import { test } from 'node:test';
import assert from 'node:assert/strict';
import { daysAgoIso, nowMs } from './clock.ts';

test('nowMs: поточний час у мс', () => {
  const before = Date.now();
  const t = nowMs();
  assert.ok(t >= before && t <= Date.now());
});

test('daysAgoIso: рівно N діб тому, ISO', () => {
  const now = Date.UTC(2026, 9, 21, 12, 0, 0);
  assert.equal(daysAgoIso(8, now), '2026-10-13T12:00:00.000Z');
  assert.equal(daysAgoIso(0, now), '2026-10-21T12:00:00.000Z');
  assert.match(daysAgoIso(1), /^\d{4}-\d{2}-\d{2}T/);
});
