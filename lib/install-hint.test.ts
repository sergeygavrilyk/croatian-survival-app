import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  SNOOZE_DAYS,
  detectPlatform,
  installHintKind,
  isSnoozed,
  isStandalone,
  parseDismissal,
  serializeDismissal,
  type InstallHintInput,
} from './install-hint.ts';

const DAY = 24 * 60 * 60 * 1000;
const NOW = Date.UTC(2026, 10, 16, 12);

const IPHONE = 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Mobile/15E148 Safari/604.1';
const IPAD = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Safari/605.1.15';
const ANDROID = 'Mozilla/5.0 (Linux; Android 15; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0 Mobile Safari/537.36';
const WINDOWS = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0 Safari/537.36';

const base: InstallHintInput = { standalone: false, platform: 'ios', canPrompt: false, dismissal: null, lessonsDone: 1, now: NOW };

test('платформа: iPhone, iPad (називає себе Mac, але сенсорний), Android, решта', () => {
  assert.equal(detectPlatform(IPHONE), 'ios');
  assert.equal(detectPlatform(IPAD, 5), 'ios');
  assert.equal(detectPlatform(IPAD, 0), 'other', 'справжній Mac — не iPhone');
  assert.equal(detectPlatform(ANDROID), 'android');
  assert.equal(detectPlatform(WINDOWS), 'other');
  assert.equal(detectPlatform(''), 'other');
});

test('застосунок уже з іконки — display-mode або navigator.standalone (iPhone)', () => {
  assert.equal(isStandalone(true, undefined), true);
  assert.equal(isStandalone(false, true), true);
  assert.equal(isStandalone(false, false), false);
  assert.equal(isStandalone(false, 'true'), false);
});

test('яку підказку показати', () => {
  assert.equal(installHintKind(base), 'ios');
  assert.equal(installHintKind({ ...base, platform: 'android', canPrompt: true }), 'native');
  assert.equal(installHintKind({ ...base, platform: 'other', canPrompt: true }), 'native', "комп'ютер з Chrome");
  assert.equal(installHintKind({ ...base, platform: 'ios', canPrompt: true }), 'ios', 'на iPhone — завжди кроки');
  assert.equal(installHintKind({ ...base, platform: 'android', canPrompt: false }), null, 'браузер не дав встановити — мовчимо');
  assert.equal(installHintKind({ ...base, platform: 'other' }), null);
  assert.equal(installHintKind({ ...base, standalone: true }), null, 'уже встановлено');
  assert.equal(installHintKind({ ...base, lessonsDone: 0 }), null, 'спершу перший урок');
});

test('«Не зараз» — 14 днів, «Готово» — 60, встановлено — назавжди', () => {
  assert.equal(SNOOZE_DAYS.later, 14);
  assert.equal(SNOOZE_DAYS.done, 60);
  const later = { reason: 'later' as const, at: NOW - 13 * DAY };
  assert.equal(isSnoozed(later, NOW), true);
  assert.equal(isSnoozed({ ...later, at: NOW - 14 * DAY }, NOW), false);
  assert.equal(isSnoozed({ reason: 'done', at: NOW - 59 * DAY }, NOW), true);
  assert.equal(isSnoozed({ reason: 'done', at: NOW - 61 * DAY }, NOW), false);
  assert.equal(isSnoozed({ reason: 'installed', at: NOW - 400 * DAY }, NOW), true);
  assert.equal(isSnoozed({ reason: 'later', at: NOW + DAY }, NOW), false, 'дата з майбутнього не ховає назавжди');
  assert.equal(isSnoozed(null, NOW), false);
  assert.equal(installHintKind({ ...base, dismissal: later }), null);
});

test('збережене відкладання: читаємо лише правильний запис', () => {
  assert.deepEqual(parseDismissal(serializeDismissal('done', NOW)), { reason: 'done', at: NOW });
  assert.equal(parseDismissal(null), null);
  assert.equal(parseDismissal('не json'), null);
  assert.equal(parseDismissal('{"reason":"never","at":1}'), null);
  assert.equal(parseDismissal('{"reason":"later","at":"вчора"}'), null);
  assert.equal(parseDismissal('null'), null);
});
