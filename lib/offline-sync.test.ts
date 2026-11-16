// Тести прийому офлайн-черги на сервері (офлайн без втрат, 2026-11-16). Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { isSettled, parseOpPayload, resolveOpTime, syncOps, syncSummary, type ApplyOutcome, type SyncDeps, type ValidOp } from './offline-sync.ts';
import { newOp, type OfflineOp } from './offline-queue.ts';

const USER = 'a0000000-0000-4000-8000-0000000000a1';
const OTHER = 'b0000000-0000-4000-8000-0000000000b1';
const LESSON = 'c0000000-0000-0000-0000-000000000001';
const TEXT = 'd0000000-0000-4000-8000-000000000001';
const NOW = new Date('2026-11-16T12:00:00Z');
const DAY = 24 * 60 * 60 * 1000;
const silent = () => {};

let seq = 0;
function op(kind: OfflineOp['kind'], payload: Record<string, unknown>, atMs = NOW.getTime() - 60_000, userId = USER): OfflineOp {
  seq++;
  return newOp(kind, userId, payload, new Date(atMs), `00000000-0000-4000-8000-${String(seq).padStart(12, '0')}`);
}

function deps(over: Partial<SyncDeps> = {}) {
  const journal = new Set<string>();
  const applied: { op: ValidOp; at: Date }[] = [];
  const d: SyncDeps = {
    userId: USER,
    now: NOW,
    async knownOpIds(ids) { return new Set(ids.filter((id) => journal.has(id))); },
    async apply(o, at): Promise<ApplyOutcome> { applied.push({ op: o, at }); return { status: 'ok' }; },
    async record(id) { journal.add(id); },
    log: silent,
    ...over,
  };
  return { d, journal, applied };
}

test('час дії: з майбутнього — час сервера, старше 14 днів — відмова', () => {
  const past = new Date(NOW.getTime() - 3 * DAY);
  assert.deepEqual(resolveOpTime(past.toISOString(), NOW), { ok: true, at: past });
  const future = resolveOpTime(new Date(NOW.getTime() + DAY).toISOString(), NOW);
  assert.ok(future.ok && future.at.getTime() === NOW.getTime());
  assert.deepEqual(resolveOpTime(new Date(NOW.getTime() - 15 * DAY).toISOString(), NOW), { ok: false, reason: 'too_old' });
  assert.deepEqual(resolveOpTime('учора', NOW), { ok: false, reason: 'bad_time' });
  assert.deepEqual(resolveOpTime(undefined, NOW), { ok: false, reason: 'bad_time' });
});

test('прийом: застосовано, номер записано; повтор того самого номера — «вже було»', async () => {
  const { d, journal, applied } = deps();
  const lesson = op('lesson_completed', { lesson_id: LESSON, duration_ms: 600000, level: 'A0' });
  assert.deepEqual(await syncOps([lesson], d), [{ op_id: lesson.op_id, status: 'ok' }]);
  assert.ok(journal.has(lesson.op_id));
  assert.equal(applied.length, 1);
  assert.equal(applied[0].at.toISOString(), lesson.at, 'дія — з часом, коли людина вчилася');
  // телефон надіслав ще раз (не встиг отримати відповідь)
  assert.deepEqual(await syncOps([lesson], d), [{ op_id: lesson.op_id, status: 'duplicate' }]);
  assert.equal(applied.length, 1, 'вдруге не застосовуємо');
  // двічі в одному пакеті
  const word = op('word_saved', { source: 'dictionary', lexeme_id: LESSON });
  const res = await syncOps([word, word], d);
  assert.deepEqual(res.map((r) => r.status).sort(), ['duplicate', 'ok']);
});

test('прийом: чужа дія лишається в черзі, некоректна — відмова, по черзі за часом', async () => {
  const { d, applied } = deps();
  const late = op('event', { name: 'exercise_completed', props: { success: true } }, NOW.getTime() - 1000);
  const early = op('reading_completed', { text_id: TEXT, correct: 2, total: 3 }, NOW.getTime() - 5000);
  const foreign = op('lesson_completed', { lesson_id: LESSON }, NOW.getTime() - 3000, OTHER);
  const old = op('lesson_completed', { lesson_id: LESSON }, NOW.getTime() - 15 * DAY);
  const bad = op('lesson_completed', { lesson_id: 'не uuid' });
  const res = await syncOps([late, foreign, early, old, bad, { kind: 'event' }, 'сміття'], d);
  const by = Object.fromEntries(res.map((r) => [r.op_id, r]));
  assert.equal(by[foreign.op_id].status, 'foreign');
  assert.equal(isSettled('foreign'), false);
  assert.deepEqual(by[old.op_id], { op_id: old.op_id, status: 'rejected', reason: 'too_old' });
  assert.deepEqual(by[bad.op_id], { op_id: bad.op_id, status: 'rejected', reason: 'bad_payload' });
  assert.equal(res.length, 5, 'записи без номера — мовчки пропущено');
  assert.deepEqual(applied.map((a) => a.op.kind), ['reading_completed', 'event'], 'у порядку, як людина вчилася');
});

test('прийом: збій бази — «спробувати пізніше», номер не записано', async () => {
  const { d, journal } = deps({ async apply() { throw new Error('db down'); } });
  const lesson = op('lesson_completed', { lesson_id: LESSON });
  assert.deepEqual(await syncOps([lesson], d), [{ op_id: lesson.op_id, status: 'retry', reason: 'apply' }]);
  assert.equal(journal.size, 0);
  assert.equal(isSettled('retry'), false);

  const broken = deps({ async knownOpIds() { throw new Error('journal down'); } });
  const res = await syncOps([lesson], broken.d);
  assert.equal(res[0].status, 'retry');
  assert.equal(broken.applied.length, 0, 'не знаємо журналу — нічого не застосовуємо');
});

test('прийом: відмова дії (немає тексту) — прибрати з черги; збій запису номера не скасовує дію', async () => {
  const { d } = deps({ async apply() { return { status: 'rejected', reason: 'not_found' }; } });
  const reading = op('reading_completed', { text_id: TEXT, correct: 1, total: 3 });
  const res = await syncOps([reading], d);
  assert.deepEqual(res, [{ op_id: reading.op_id, status: 'rejected', reason: 'not_found' }]);
  assert.equal(isSettled('rejected'), true);

  const noRecord = deps({ async record() { throw new Error('insert failed'); } });
  assert.equal((await syncOps([op('lesson_completed', { lesson_id: LESSON })], noRecord.d))[0].status, 'ok');
});

test('прийом: не більше 20 дій за раз', async () => {
  const { d, applied } = deps();
  const many = Array.from({ length: 25 }, (_, i) => op('event', { name: 'exercise_completed', props: {} }, NOW.getTime() - 100_000 + i));
  assert.equal((await syncOps(many, d)).length, 20);
  assert.equal(applied.length, 20);
  assert.deepEqual(await syncOps('не масив', d), []);
});

test('зміст дій: перевірка й нормалізація', () => {
  assert.deepEqual(parseOpPayload('reading_completed', { text_id: TEXT, correct: 9, total: 3 }), {
    kind: 'reading_completed', textId: TEXT, correct: 3, total: 3, durationMs: undefined, level: undefined,
  });
  assert.equal(parseOpPayload('word_saved', { source: 'reading', text_id: TEXT, lemma: '' }), null);
  assert.equal(parseOpPayload('word_saved', { source: 'reading', text_id: TEXT, lemma: 'x'.repeat(81) }), null);
  assert.deepEqual(parseOpPayload('word_saved', { source: 'reading', text_id: TEXT, lemma: ' kava ' }), {
    kind: 'word_saved', source: 'reading', textId: TEXT, lemma: 'kava',
  });
  assert.equal(parseOpPayload('word_saved', { source: 'lesson', lexeme_id: LESSON }), null);
  assert.equal(parseOpPayload('event', { name: 'drop_table', props: {} }), null);
  assert.equal(parseOpPayload('event', { name: 'offline_synced', props: {} }), null, 'службову подію сервера з черги не приймаємо');
  assert.deepEqual(parseOpPayload('event', { name: 'lesson_started', props: 'x' }), { kind: 'event', name: 'lesson_started', props: {} });
  assert.equal(parseOpPayload('srs_rating', { lexeme_id: LESSON, rating: 1 }), null, 'етап 2 — поки не приймаємо');
  assert.equal(parseOpPayload('lesson_completed', null), null);
  assert.equal(parseOpPayload('lesson_completed', { lesson_id: LESSON, session_id: 'x' })?.kind, 'lesson_completed');
});

test('підсумок для offline_synced: прийнято, відхилено, найдовше очікування', () => {
  const a = op('lesson_completed', { lesson_id: LESSON }, NOW.getTime() - 2 * DAY);
  const b = op('event', { name: 'lesson_started', props: {} }, NOW.getTime() - DAY);
  const c = op('lesson_completed', { lesson_id: LESSON }, NOW.getTime() - 3 * DAY);
  const summary = syncSummary(
    [{ op_id: a.op_id, status: 'ok' }, { op_id: b.op_id, status: 'ok' }, { op_id: c.op_id, status: 'rejected', reason: 'not_found' }],
    [a, b, c],
    NOW,
  );
  assert.deepEqual(summary, { count: 2, failed: 1, age_ms: 2 * DAY });
});
