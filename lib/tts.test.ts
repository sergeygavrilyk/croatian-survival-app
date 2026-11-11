import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { checkTtsText, quotaAllows, secondsUntilUtcMidnight, TTS_DAILY_LIMIT, TTS_MAX_CHARS } from './tts.ts';

test('ліміти озвучення — за рішенням власника 2026-11-11: 300 символів, 300 запитів на добу', () => {
  assert.equal(TTS_MAX_CHARS, 300);
  assert.equal(TTS_DAILY_LIMIT, 300);
});

test('checkTtsText: порожній текст → 400', () => {
  for (const raw of [null, undefined, '', '   ', '\n\t']) {
    const r = checkTtsText(raw);
    assert.equal(r.ok, false);
    if (!r.ok) assert.equal(r.status, 400);
  }
});

test('checkTtsText: рівно 300 символів — можна, 301 — 413', () => {
  const ok = checkTtsText('a'.repeat(TTS_MAX_CHARS));
  assert.equal(ok.ok, true);
  const tooLong = checkTtsText('a'.repeat(TTS_MAX_CHARS + 1));
  assert.equal(tooLong.ok, false);
  if (!tooLong.ok) assert.equal(tooLong.status, 413);
});

test('checkTtsText: зайві пробіли не рахуються, хорватські літери лишаються', () => {
  const r = checkTtsText('  Dobar   dan,\n Dašo!  ');
  assert.deepEqual(r, { ok: true, text: 'Dobar dan, Dašo!' });
});

test('checkTtsText: найдовший шматок тексту для читання (180) проходить', () => {
  assert.equal(checkTtsText('ž'.repeat(180)).ok, true);
});

test('secondsUntilUtcMidnight: до півночі UTC, щонайменше 1 с', () => {
  assert.equal(secondsUntilUtcMidnight(new Date(Date.UTC(2026, 10, 11, 23, 0, 0))), 3600);
  assert.equal(secondsUntilUtcMidnight(new Date(Date.UTC(2026, 10, 11, 0, 0, 0))), 86400);
  assert.equal(secondsUntilUtcMidnight(new Date(Date.UTC(2026, 11, 31, 23, 59, 59, 500))), 1);
});

test('quotaAllows: ліміт вичерпано → ні; є запас → так', () => {
  assert.equal(quotaAllows([{ allowed: false, used: 300, daily_limit: 300 }], null), false);
  assert.equal(quotaAllows([{ allowed: true, used: 5, daily_limit: 300 }], null), true);
  assert.equal(quotaAllows({ allowed: false, used: 300, daily_limit: 300 }, null), false);
});

test('quotaAllows: збій лічильника не ламає озвучення', () => {
  assert.equal(quotaAllows(null, { message: 'function does not exist' }), true);
  assert.equal(quotaAllows([], null), true);
  assert.equal(quotaAllows([{ allowed: null, used: null, daily_limit: null }], null), true);
});

test('денний ліміт у міграції M22 збігається з TTS_DAILY_LIMIT', () => {
  const sql = readFileSync(new URL('../supabase/migrations/20261111100000_m22_tts_daily_usage.sql', import.meta.url), 'utf8');
  const m = sql.match(/v_limit\s+constant\s+integer\s*:=\s*(\d+)/);
  assert.ok(m, 'у consume_tts_quota() є v_limit constant integer := N');
  assert.equal(Number(m[1]), TTS_DAILY_LIMIT);
});
