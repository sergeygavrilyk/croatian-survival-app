// Тести черги прогресу на телефоні (офлайн без втрат, 2026-11-16). Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import {
  enqueueOp, isNetworkError, isOfflineOp, newOp, OFFLINE_OP_KINDS, pendingCount, QUEUE_MAX_AGE_DAYS, QUEUE_MAX_OPS,
  peekExpiredNotice, queueKey, readQueue, readUserIdCookie, removeOps, syncBatches, syncRetryDelay, takeExpiredNotice, type OfflineOp,
} from './offline-queue.ts';
import type { KeyValueStorage } from './offline-copy.ts';

const A = 'a0000000-0000-4000-8000-0000000000a1';
const B = 'b0000000-0000-4000-8000-0000000000b1';
const LESSON = 'c0000000-0000-0000-0000-000000000001';
const DAY = 24 * 60 * 60 * 1000;
const NOW = Date.parse('2026-11-16T12:00:00Z');

function memoryStorage(initial: Record<string, string> = {}): KeyValueStorage & { data: Map<string, string> } {
  const data = new Map(Object.entries(initial));
  return {
    data,
    get length() { return data.size; },
    key: (i) => [...data.keys()][i] ?? null,
    getItem: (k) => data.get(k) ?? null,
    setItem: (k, v) => { data.set(k, v); },
    removeItem: (k) => { data.delete(k); },
  };
}

function brokenStorage(): KeyValueStorage {
  const fail = () => { throw new Error('storage disabled'); };
  return { length: 0, key: fail, getItem: fail, setItem: fail, removeItem: fail };
}

let seq = 0;
function op(kind: OfflineOp['kind'], userId: string, atMs: number, payload: Record<string, unknown> = { lesson_id: LESSON }): OfflineOp {
  seq++;
  return newOp(kind, userId, payload, new Date(atMs), `00000000-0000-4000-8000-${String(seq).padStart(12, '0')}`);
}

test('види дій збігаються з CHECK у міграції M28 (client_ops)', () => {
  const sql = readFileSync(new URL('../supabase/migrations/20261116120000_m28_client_ops.sql', import.meta.url), 'utf8');
  const m = sql.match(/kind in \(([^)]*)\)/);
  assert.ok(m, 'у міграції є перелік видів');
  const kinds = [...m[1].matchAll(/'([a-z_]+)'/g)].map((x) => x[1]);
  assert.deepEqual(kinds, [...OFFLINE_OP_KINDS]);
});

test('межі черги — рішення власника 2026-11-16: 14 днів і 200 дій', () => {
  assert.equal(QUEUE_MAX_AGE_DAYS, 14);
  assert.equal(QUEUE_MAX_OPS, 200);
});

test('додати, прочитати, прибрати; порядок — за часом дії', () => {
  const s = memoryStorage();
  const late = op('lesson_completed', A, NOW - 1000);
  const early = op('event', A, NOW - 5000, { name: 'lesson_started', props: {} });
  assert.equal(enqueueOp(s, late, NOW).ok, true);
  assert.equal(enqueueOp(s, early, NOW).size, 2);
  assert.deepEqual(readQueue(s, A, NOW).ops.map((o) => o.op_id), [early.op_id, late.op_id]);
  assert.equal(pendingCount(s, A, NOW), 2);
  assert.equal(removeOps(s, A, [early.op_id]), 1);
  assert.deepEqual(readQueue(s, A, NOW).ops.map((o) => o.op_id), [late.op_id]);
  assert.equal(removeOps(s, A, [late.op_id]), 1);
  assert.equal(s.data.has(queueKey(A)), false, 'порожня черга не займає місця');
});

test('той самий номер дії двічі — один запис', () => {
  const s = memoryStorage();
  const one = op('lesson_completed', A, NOW - 1000);
  enqueueOp(s, one, NOW);
  assert.equal(enqueueOp(s, { ...one }, NOW).size, 1);
  assert.equal(pendingCount(s, A, NOW), 1);
});

test('черга одного акаунта не віддається іншому', () => {
  const s = memoryStorage();
  enqueueOp(s, op('lesson_completed', A, NOW - 1000), NOW);
  assert.equal(pendingCount(s, B, NOW), 0);
  // підкладений у чужу чергу запис іншого користувача не читається
  s.data.set(queueKey(B), JSON.stringify({ f: 1, ops: [op('lesson_completed', A, NOW - 1000)] }));
  assert.equal(pendingCount(s, B, NOW), 0);
  assert.equal(pendingCount(s, null, NOW), 0);
});

test('понад 200 дій — першими відкидаємо найстаріші події, прогрес лишається', () => {
  const s = memoryStorage();
  const lesson = op('lesson_completed', A, NOW - 10 * 60_000);
  enqueueOp(s, lesson, NOW);
  for (let i = 0; i < QUEUE_MAX_OPS; i++) enqueueOp(s, op('event', A, NOW - 9 * 60_000 + i, { name: 'exercise_completed', props: {} }), NOW);
  const { ops } = readQueue(s, A, NOW);
  assert.equal(ops.length, QUEUE_MAX_OPS);
  assert.ok(ops.some((o) => o.op_id === lesson.op_id), 'завершення уроку не відкинуто');
  // лише прогрес — відкидаємо найстаріший
  const p = memoryStorage();
  const first = op('word_saved', A, NOW - 60_000, { source: 'dictionary', lexeme_id: LESSON });
  enqueueOp(p, first, NOW);
  for (let i = 0; i < QUEUE_MAX_OPS; i++) enqueueOp(p, op('word_saved', A, NOW - 50_000 + i, { source: 'dictionary', lexeme_id: LESSON }), NOW);
  const res = readQueue(p, A, NOW).ops;
  assert.equal(res.length, QUEUE_MAX_OPS);
  assert.equal(res.some((o) => o.op_id === first.op_id), false);
});

test('старші за 14 днів — відкидаємо, повідомлення — один раз', () => {
  const s = memoryStorage();
  const old = op('lesson_completed', A, NOW - 10 * DAY);
  const fresh = op('lesson_completed', A, NOW - DAY);
  enqueueOp(s, old, NOW);
  enqueueOp(s, fresh, NOW);
  const later = NOW + 5 * DAY; // old — 15 днів
  assert.equal(pendingCount(s, A, later), 1, 'задавнену не рахуємо');
  const first = readQueue(s, A, later);
  assert.equal(first.expired, 1);
  assert.deepEqual(first.ops.map((o) => o.op_id), [fresh.op_id]);
  assert.equal(readQueue(s, A, later).expired, 0, 'вдруге не рахуємо');
  assert.equal(peekExpiredNotice(s, A), 1);
  assert.equal(peekExpiredNotice(s, A), 1, 'перегляд не прибирає позначку');
  assert.equal(takeExpiredNotice(s, A), 1);
  assert.equal(takeExpiredNotice(s, A), 0, 'повідомлення показуємо один раз');
  assert.equal(enqueueOp(s, op('lesson_completed', A, later - 20 * DAY), later).ok, false, 'задавнену дію не додаємо');
});

test('пошкоджене сховище й невідомий вид — без падіння', () => {
  const s = memoryStorage({ [queueKey(A)]: '{not json' });
  assert.deepEqual(readQueue(s, A, NOW).ops, []);
  s.data.set(queueKey(A), JSON.stringify({ f: 1, ops: [{ op_id: 'x', kind: 'drop_table' }, op('lesson_completed', A, NOW - 1000)] }));
  assert.equal(readQueue(s, A, NOW).ops.length, 1);
  s.data.set(queueKey(A), JSON.stringify({ f: 99, ops: [] }));
  assert.equal(readQueue(s, A, NOW).ops.length, 0);
  assert.equal(isOfflineOp({ ...op('event', A, NOW), kind: 'unknown' }), false);
  const broken = brokenStorage();
  assert.deepEqual(readQueue(broken, A, NOW), { ops: [], expired: 0 });
  assert.equal(enqueueOp(broken, op('lesson_completed', A, NOW - 1000), NOW).ok, false);
  assert.equal(removeOps(broken, A, ['x']), 0);
  assert.equal(takeExpiredNotice(broken, A), 0);
  assert.equal(peekExpiredNotice(broken, A), 0);
  assert.equal(pendingCount(broken, A, NOW), 0);
  assert.equal(enqueueOp(null, op('lesson_completed', A, NOW - 1000), NOW).ok, false);
});

test('пакети по 20 і паузи між спробами 5 с → 30 с → 2 хв', () => {
  assert.deepEqual(syncBatches(Array.from({ length: 45 }, (_, i) => i)).map((b) => b.length), [20, 20, 5]);
  assert.deepEqual(syncBatches([]), []);
  assert.equal(syncRetryDelay(1), 5_000);
  assert.equal(syncRetryDelay(2), 30_000);
  assert.equal(syncRetryDelay(3), 120_000);
  assert.equal(syncRetryDelay(10), 120_000);
  assert.equal(syncRetryDelay(0), 5_000);
});

test('id користувача з cookie cs_uid', () => {
  assert.equal(readUserIdCookie(`a=1; cs_uid=${A}; b=2`), A);
  assert.equal(readUserIdCookie(`cs_uid=${A.toUpperCase()}`), A);
  assert.equal(readUserIdCookie('cs_uid=not-a-uuid'), null);
  assert.equal(readUserIdCookie('other=1'), null);
  assert.equal(readUserIdCookie(''), null);
  assert.equal(readUserIdCookie(null), null);
});

test('збій мережі — у чергу; відмова сервера — ні', () => {
  assert.equal(isNetworkError(new TypeError('Failed to fetch')), true);
  assert.equal(isNetworkError(new Error('Load failed')), true);
  assert.equal(isNetworkError(new Error('Не авторизовано')), false);
  assert.equal(isNetworkError(new Error('Не авторизовано'), false), true, 'браузер каже «офлайн» — у чергу');
  assert.equal(isNetworkError(undefined), false);
});
