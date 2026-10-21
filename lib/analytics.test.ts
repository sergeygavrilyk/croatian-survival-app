// Тести валідації подій аналітики. Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { buildAnalyticsRow, deviceFromUserAgent, isEventName, EVENT_NAMES } from './analytics.ts';

const now = new Date('2026-10-12T15:00:00Z');
const LESSON = 'c0000000-0000-0000-0000-000000000001';
const LEXEME = '22222222-2222-2222-2222-222222222222';

test('усі події з §71 дозволені, вигадані — ні', () => {
  assert.equal(EVENT_NAMES.length, 26);
  assert.ok(isEventName('assessment_completed'));
  assert.ok(isEventName('lesson_completed'));
  assert.ok(!isEventName('lesson_finished'));
  assert.equal(buildAnalyticsRow('hack_the_db', {}, now), null);
  assert.equal(buildAnalyticsRow(undefined, {}, now), null);
});

test('поширені властивості йдуть у колонки, решта — у properties', () => {
  const row = buildAnalyticsRow('exercise_completed', {
    lesson_id: LESSON, lexeme_id: LEXEME, level: 'A1', success: true, duration_ms: 1234.6,
    exercise_type: 'fill_in_the_blank', attempt: 2, session_id: '5f0c7a8e-1b2c-4d3e-8f90-123456789abc',
  }, now)!;
  assert.equal(row.event_name, 'exercise_completed');
  assert.equal(row.lesson_id, LESSON);
  assert.equal(row.lexeme_id, LEXEME);
  assert.equal(row.level, 'A1');
  assert.equal(row.success, true);
  assert.equal(row.duration_ms, 1235);
  assert.equal(row.session_id, '5f0c7a8e-1b2c-4d3e-8f90-123456789abc');
  assert.deepEqual(row.properties, { exercise_type: 'fill_in_the_blank', attempt: 2 });
  assert.equal(row.occurred_at, now.toISOString());
});

test('некоректні значення відкидаються, а не ламають подію', () => {
  const row = buildAnalyticsRow('lesson_started', {
    lesson_id: 'not-a-uuid', level: 'C2', duration_ms: -5, session_id: '123',
  }, now)!;
  assert.equal(row.lesson_id, null);
  assert.equal(row.level, null);
  assert.equal(row.duration_ms, null);
  assert.equal(row.session_id, null);
});

test('properties: лише прості значення з безпечними ключами', () => {
  const props = { source: 'lesson', nested: { a: 1 }, 'Bad-Key': 'x', list: [1, 2], count: Number.NaN } as never;
  const row = buildAnalyticsRow('word_saved', props, now)!;
  assert.deepEqual(row.properties, { source: 'lesson' });
});

test('завеликі properties — подія відкидається', () => {
  const big: Record<string, string> = {};
  for (let i = 0; i < 40; i++) big[`k${i}`] = 'x'.repeat(200);
  assert.equal(buildAnalyticsRow('app_open', big as never, now), null);
});

test('properties не можуть бути масивом чи null', () => {
  assert.equal(buildAnalyticsRow('app_open', [] as never, now), null);
  assert.equal(buildAnalyticsRow('app_open', null as never, now), null);
});

test('вправа «написати слово» з тренажера: verdict і source — у properties', () => {
  const row = buildAnalyticsRow('exercise_completed', {
    lexeme_id: LEXEME, level: 'A1', exercise_type: 'type_word', source: 'trainer', success: true, attempt: 1, duration_ms: 4200, verdict: 'diacritics',
  }, now)!;
  assert.equal(row.success, true);
  assert.deepEqual(row.properties, { exercise_type: 'type_word', source: 'trainer', attempt: 1, verdict: 'diacritics' });
});

test('тип пристрою з User-Agent', () => {
  assert.equal(deviceFromUserAgent('Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) Mobile/15E148'), 'mobile');
  assert.equal(deviceFromUserAgent('Mozilla/5.0 (Linux; Android 14; Pixel 8) Mobile Safari/537.36'), 'mobile');
  assert.equal(deviceFromUserAgent('Mozilla/5.0 (iPad; CPU OS 17_0 like Mac OS X)'), 'tablet');
  assert.equal(deviceFromUserAgent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) Chrome/130.0'), 'desktop');
  assert.equal(deviceFromUserAgent(null), 'unknown');
});
