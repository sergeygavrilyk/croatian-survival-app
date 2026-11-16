import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  BUILD_KEY,
  PHRASES_MARKER,
  REFRESH_LIMIT,
  buildAction,
  pickRefreshPaths,
  refreshHeaderValue,
  refreshOutcome,
} from './offline-refresh.ts';

const O = 'https://app.example';

test('рішення власника: оновлюємо до 30 найсвіжіших збережених сторінок', () => {
  assert.equal(REFRESH_LIMIT, 30);
  assert.equal(BUILD_KEY, 'cs_offline_build_v1');
});

test('збірка: перший запуск — запам\'ятати; інша — оновити; та сама чи невідома — нічого', () => {
  assert.equal(buildAction(null, 'b1'), 'record');
  assert.equal(buildAction('', 'b1'), 'record');
  assert.equal(buildAction('b1', 'b1'), 'none');
  assert.equal(buildAction('b1', 'b2'), 'refresh');
  assert.equal(buildAction('b1', ''), 'none');
  assert.equal(buildAction(null, undefined), 'none');
});

test('які сторінки: найсвіжіші першими, свого сайту, без API / входу / адмінки, без повторів, ≤ ліміту', () => {
  const urls = [
    `${O}/lesson/1`,
    `${O}/api/tts?t=x`,
    `${O}/login`,
    'https://other.example/lesson/2',
    `${O}/reading/3`,
    `${O}/lessons?level=A1`,
    `${O}/lesson/1`,
    `${O}/admin`,
    'не адреса',
    `${O}/situations/pharmacy`,
  ];
  assert.deepEqual(pickRefreshPaths(urls, O), ['/situations/pharmacy', '/lesson/1', '/lessons?level=A1', '/reading/3']);
  assert.deepEqual(pickRefreshPaths(urls, O, 2), ['/situations/pharmacy', '/lesson/1']);
  const many = Array.from({ length: 50 }, (_, i) => `${O}/lesson/${i}`);
  const picked = pickRefreshPaths(many, O);
  assert.equal(picked.length, 30);
  assert.equal(picked[0], '/lesson/49');
  assert.deepEqual(pickRefreshPaths([], O), []);
});

test('ситуацію «лише фрази» оновлюємо так само лише фразами, решту — повністю', () => {
  assert.equal(PHRASES_MARKER, 'data-offline-copy="phrases"');
  assert.equal(refreshHeaderValue('/situations/bank', `<div ${PHRASES_MARKER}>`), 'page');
  assert.equal(refreshHeaderValue('/situations/bank', '<div class="x">'), 'full', 'відкрита з мережею — повна');
  assert.equal(refreshHeaderValue('/situations/bank', null), 'full');
  assert.equal(refreshHeaderValue('/lesson/1', `<div ${PHRASES_MARKER}>`), 'full', 'позначка лише для ситуацій');
});

test('відповідь: 200 — оновлено, 404 / 410 — сторінки немає, переадресація — вхід скінчився', () => {
  assert.equal(refreshOutcome(200), 'updated');
  assert.equal(refreshOutcome(404), 'gone');
  assert.equal(refreshOutcome(410), 'gone');
  assert.equal(refreshOutcome(0, 'opaqueredirect'), 'signed_out');
  assert.equal(refreshOutcome(307), 'signed_out');
  assert.equal(refreshOutcome(500), 'failed');
  assert.equal(refreshOutcome(0, 'error'), 'failed');
});
