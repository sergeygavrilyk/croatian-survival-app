// Тести сценаріїв VS-001 / VS-002 на сховищі в пам'яті (без бази). Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { rateCard, completeLesson, trackEvent, startOfTomorrow, type LearningRepo, type ReviewHistoryEntry } from './learning.ts';
import type { SrsState, SrsResult } from './srs.ts';
import type { AnalyticsRow } from './analytics.ts';

const USER = '11111111-1111-1111-1111-111111111111';
const LESSON = 'c0000000-0000-0000-0000-000000000001';
const BOK = '22222222-2222-2222-2222-222222222222';
const HVALA = '33333333-3333-3333-3333-333333333333';
const now = new Date('2026-10-12T15:30:00');
const silent = () => {};

type Failing = Partial<Record<keyof LearningRepo, boolean>>;

/** Проста реалізація сховища в пам'яті + можливість «зламати» будь-який метод. */
function memoryRepo(fail: Failing = {}) {
  const progress = new Map<string, SrsState & { nextReviewDate: Date }>();
  const history: ReviewHistoryEntry[] = [];
  const lessons = new Map<string, string>();
  const events: { userId: string; row: AnalyticsRow }[] = [];
  const lessonItems = new Map<string, string[]>([[LESSON, [BOK, HVALA, BOK]]]);
  const key = (u: string, l: string) => `${u}:${l}`;
  const guard = (name: keyof LearningRepo) => { if (fail[name]) throw new Error(`${name} failed`); };

  const repo: LearningRepo = {
    async getCardState(u, l) { guard('getCardState'); const p = progress.get(key(u, l)); return p ? { ...p } : null; },
    async saveCardState(u, l, next: SrsResult) { guard('saveCardState'); progress.set(key(u, l), { ...next }); },
    async addReviewHistory(e) { guard('addReviewHistory'); history.push(e); },
    async markLessonCompleted(u, lessonId) { guard('markLessonCompleted'); lessons.set(key(u, lessonId), 'completed'); },
    async getLessonLexemeIds(lessonId) { guard('getLessonLexemeIds'); return lessonItems.get(lessonId) ?? []; },
    async addToReviewIfAbsent(u, ids, dueAt) {
      guard('addToReviewIfAbsent');
      let added = 0;
      for (const id of ids) {
        if (progress.has(key(u, id))) continue;
        progress.set(key(u, id), { easeFactor: 2.5, intervalDays: 1, repetitionCount: 0, lapses: 0, nextReviewDate: dueAt });
        added++;
      }
      return added;
    },
    async logEvent(u, row) { guard('logEvent'); events.push({ userId: u, row }); },
  };
  return { repo, progress, history, lessons, events, key };
}

// ---------------------------------------------------------------- VS-001

test('VS-001: нове слово, «Знаю» → стан збережено, історія записана, повтор завтра', async () => {
  const m = memoryRepo();
  const res = await rateCard(m.repo, { userId: USER, lexemeId: BOK, rating: 1, responseTimeMs: 1500.4, now }, silent);
  assert.equal(res.intervalDays, 1);
  const saved = m.progress.get(m.key(USER, BOK))!;
  assert.equal(saved.repetitionCount, 1);
  assert.equal(saved.nextReviewDate.toDateString(), startOfTomorrow(now).toDateString());
  assert.equal(m.history.length, 1);
  assert.equal(m.history[0].result, 1);
  assert.equal(m.history[0].responseTimeMs, 1500);
  assert.equal(m.history[0].prev.intervalDays, 0);
});

test('VS-001: «Не знаю» після вивчення → повтор сьогодні, lapse', async () => {
  const m = memoryRepo();
  await rateCard(m.repo, { userId: USER, lexemeId: BOK, rating: 1, now }, silent);
  await rateCard(m.repo, { userId: USER, lexemeId: BOK, rating: 1, now }, silent);
  const res = await rateCard(m.repo, { userId: USER, lexemeId: BOK, rating: 0, now }, silent);
  assert.equal(res.intervalDays, 0);
  assert.equal(m.progress.get(m.key(USER, BOK))!.lapses, 1);
  assert.equal(m.history.length, 3);
});

test('VS-001: некоректна оцінка — помилка, нічого не записано', async () => {
  const m = memoryRepo();
  await assert.rejects(rateCard(m.repo, { userId: USER, lexemeId: BOK, rating: 5, now }, silent));
  assert.equal(m.progress.size, 0);
  assert.equal(m.history.length, 0);
});

test('VS-001: збій збереження стану — помилка для користувача', async () => {
  const m = memoryRepo({ saveCardState: true });
  await assert.rejects(rateCard(m.repo, { userId: USER, lexemeId: BOK, rating: 1, now }, silent), /saveCardState failed/);
});

test('VS-001: збій історії не ламає відповідь', async () => {
  const m = memoryRepo({ addReviewHistory: true });
  const res = await rateCard(m.repo, { userId: USER, lexemeId: BOK, rating: 1, now }, silent);
  assert.equal(res.success, true);
  assert.equal(m.progress.size, 1);
});

// ---------------------------------------------------------------- VS-002

test('VS-002: завершення уроку → прогрес уроку, слова в повторення на завтра, подія lesson_completed', async () => {
  const m = memoryRepo();
  const res = await completeLesson(m.repo, {
    userId: USER, lessonId: LESSON, now,
    context: { session_id: '5f0c7a8e-1b2c-4d3e-8f90-123456789abc', duration_ms: 90_000, level: 'A0' },
  }, silent);
  assert.equal(res.addedToReview, 2); // BOK і HVALA, дубль у lesson_items не рахується
  assert.equal(m.lessons.get(m.key(USER, LESSON)), 'completed');
  for (const id of [BOK, HVALA]) {
    const p = m.progress.get(m.key(USER, id))!;
    assert.equal(p.nextReviewDate.getTime(), startOfTomorrow(now).getTime());
  }
  assert.equal(m.events.length, 1);
  const ev = m.events[0].row;
  assert.equal(ev.event_name, 'lesson_completed');
  assert.equal(ev.lesson_id, LESSON);
  assert.equal(ev.level, 'A0');
  assert.equal(ev.duration_ms, 90_000);
  assert.deepEqual(ev.properties, { count: 2, added_to_review: 2 });
});

test('VS-002: слова, які вже вчаться, не скидаються при завершенні уроку', async () => {
  const m = memoryRepo();
  await rateCard(m.repo, { userId: USER, lexemeId: BOK, rating: 1, now }, silent);
  await rateCard(m.repo, { userId: USER, lexemeId: BOK, rating: 1, now }, silent); // інтервал 3 дні
  const res = await completeLesson(m.repo, { userId: USER, lessonId: LESSON, now }, silent);
  assert.equal(res.addedToReview, 1); // лише HVALA
  assert.equal(m.progress.get(m.key(USER, BOK))!.intervalDays, 3);
});

test('VS-002: повторне завершення уроку нічого не дублює', async () => {
  const m = memoryRepo();
  await completeLesson(m.repo, { userId: USER, lessonId: LESSON, now }, silent);
  const again = await completeLesson(m.repo, { userId: USER, lessonId: LESSON, now }, silent);
  assert.equal(again.addedToReview, 0);
  assert.equal(m.progress.size, 2);
});

test('VS-002: якщо прогрес уроку не зберігся — помилка (користувач може повторити)', async () => {
  const m = memoryRepo({ markLessonCompleted: true });
  await assert.rejects(completeLesson(m.repo, { userId: USER, lessonId: LESSON, now }, silent));
  assert.equal(m.progress.size, 0);
  assert.equal(m.events.length, 0);
});

test('VS-002: збій SRS або аналітики не ламає завершення уроку', async () => {
  const m = memoryRepo({ addToReviewIfAbsent: true, logEvent: true });
  const res = await completeLesson(m.repo, { userId: USER, lessonId: LESSON, now }, silent);
  assert.equal(res.success, true);
  assert.equal(res.addedToReview, 0);
  assert.equal(m.lessons.get(m.key(USER, LESSON)), 'completed');
});

// ---------------------------------------------------------------- аналітика

test('trackEvent: валідна подія записується, невалідна — ні, збій бази не кидає помилку', async () => {
  const m = memoryRepo();
  assert.equal(await trackEvent(m.repo, USER, 'word_saved', { lexeme_id: BOK, source: 'lesson' }, now, silent), true);
  assert.equal(await trackEvent(m.repo, USER, 'drop_table', {}, now, silent), false);
  assert.equal(m.events.length, 1);
  assert.equal(m.events[0].userId, USER);

  const broken = memoryRepo({ logEvent: true });
  assert.equal(await trackEvent(broken.repo, USER, 'app_open', {}, now, silent), false);
});
