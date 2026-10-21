import { test } from 'node:test';
import assert from 'node:assert/strict';
import { displayName, greetingFor, hourIn, nextLesson, suggestAssessment, todayLevel, weekCheer, type TodayAssessment, type TodayLesson } from './today.ts';

test('година й привітання — у часовому поясі користувача', () => {
  const t = new Date('2026-10-20T09:30:00Z');
  assert.equal(hourIn(t, 'Europe/Warsaw'), 11);
  assert.equal(greetingFor(t, 'Europe/Warsaw'), 'Dobro jutro');
  assert.equal(greetingFor(new Date('2026-10-20T11:00:00Z'), 'Europe/Warsaw'), 'Dobar dan');
  assert.equal(greetingFor(new Date('2026-10-20T17:30:00Z'), 'Europe/Warsaw'), 'Dobra večer');
  assert.equal(greetingFor(new Date('2026-10-20T00:30:00Z'), 'Europe/Warsaw'), 'Dobra večer'); // 02:30 — ще ніч
  assert.equal(hourIn(t, 'Not/AZone'), 9);
});

const L = (id: string, m: number, u: number, o: number): TodayLesson => ({ id, title_ua: `Урок ${id}`, module_order: m, unit_order: u, order_index: o });

test('наступний урок — перший непройдений у порядку модуль → юніт → урок', () => {
  const lessons = [L('c', 2, 1, 1), L('a', 1, 1, 1), L('b', 1, 1, 2)];
  assert.deepEqual(nextLesson(lessons, new Set()), { lesson: lessons[1], done: 0, total: 3 });
  assert.equal(nextLesson(lessons, new Set(['a'])).lesson?.id, 'b');
  assert.equal(nextLesson(lessons, new Set(['b'])).lesson?.id, 'a'); // пропущений раніше урок — першим
  assert.deepEqual(nextLesson(lessons, new Set(['a', 'b', 'c'])), { lesson: null, done: 3, total: 3 });
  assert.deepEqual(nextLesson([], new Set()), { lesson: null, done: 0, total: 0 });
});

test('рівень для «Продовжити» і ім’я', () => {
  assert.equal(todayLevel('A1', ['A0', 'A1']), 'A1');
  assert.equal(todayLevel('B1', ['A0', 'A1']), 'A0');
  assert.equal(todayLevel(null, ['A0', 'A1']), 'A0');
  assert.equal(displayName('Serhii Havryliuk', 'x@y.z'), 'Serhii');
  assert.equal(displayName('', 'dasha@example.com'), 'dasha');
  assert.equal(displayName(null, null), 'друже');
});

test('weekCheer: підбадьорення за днями тижня', () => {
  assert.match(weekCheer(0), /Почніть сьогодні/);
  assert.match(weekCheer(1), /початок/);
  assert.match(weekCheer(3), /ритм/);
  assert.match(weekCheer(5), /Чудовий/);
  assert.match(weekCheer(7), /Цілий тиждень/);
});

test('sessionCheer: підбадьорення за часткою правильних, без «провалу»', async () => {
  const { sessionCheer } = await import('./today.ts');
  assert.deepEqual(sessionCheer(10, 10), { emoji: '🎉', title: 'Чудово!' });
  assert.equal(sessionCheer(8, 10).emoji, '🎉');
  assert.equal(sessionCheer(5, 10).emoji, '💪');
  assert.equal(sessionCheer(4, 10).emoji, '🌱');
  assert.equal(sessionCheer(0, 0).emoji, '🌱');
  assert.equal(sessionCheer(-1, 3).emoji, '🌱');
});

// ---------------------------------------------------------------- пропозиція перевірки
const ML = (id: string, m: number, o: number): TodayLesson => ({
  id, title_ua: `Урок ${id}`, module_order: m, unit_order: 1, order_index: o, module_id: `mod${m}`, module_title: `Модуль ${m}`,
});
// 6 модулів по 2 уроки
const LESSONS6 = [1, 2, 3, 4, 5, 6].flatMap((m) => [ML(`${m}a`, m, 1), ML(`${m}b`, m, 2)]);
const TESTS: TodayAssessment[] = [
  ...[1, 2, 3, 4, 5, 6].map((m) => ({ id: `t${m}`, slug: `a0-m0${m}`, kind: 'module', module_id: `mod${m}`, estimated_minutes: 8 })),
  { id: 'tmid', slug: 'a0-mid', kind: 'mid', module_id: null, estimated_minutes: 15 },
  { id: 'tfin', slug: 'a0-final', kind: 'final', module_id: null, estimated_minutes: 20 },
];
const doneUpTo = (lastModule: number, extra: string[] = []) =>
  new Set([...LESSONS6.filter((l) => l.module_order <= lastModule).map((l) => l.id), ...extra]);

test('перевірка: модуль не пройдено повністю — нічого не пропонуємо', () => {
  assert.equal(suggestAssessment(LESSONS6, new Set(), TESTS, new Set()), null);
  assert.equal(suggestAssessment(LESSONS6, new Set(['1a']), TESTS, new Set()), null);
});

test('перевірка: модуль пройдено — пропонуємо перевірку саме цього модуля', () => {
  assert.deepEqual(suggestAssessment(LESSONS6, doneUpTo(1, ['2a']), TESTS, new Set()), {
    slug: 'a0-m01', kind: 'module', moduleOrder: 1, moduleTitle: 'Модуль 1', minutes: 8,
  });
});

test('перевірка: найсвіжіша з неспробуваних; уже почату не пропонуємо', () => {
  assert.equal(suggestAssessment(LESSONS6, doneUpTo(3), TESTS, new Set())?.slug, 'a0-m03');
  assert.equal(suggestAssessment(LESSONS6, doneUpTo(3), TESTS, new Set(['t3']))?.slug, 'a0-m02');
  assert.equal(suggestAssessment(LESSONS6, doneUpTo(3), TESTS, new Set(['t1', 't2', 't3'])), null);
});

test('перевірка: середина — після модулів 1–5, фінал — після всіх', () => {
  const tried15 = new Set(['t1', 't2', 't3', 't4', 't5']);
  assert.equal(suggestAssessment(LESSONS6, doneUpTo(4), TESTS, tried15), null);
  assert.equal(suggestAssessment(LESSONS6, doneUpTo(5), TESTS, tried15)?.slug, 'a0-mid');
  assert.equal(suggestAssessment(LESSONS6, doneUpTo(6), TESTS, new Set())?.slug, 'a0-final');
  assert.equal(suggestAssessment(LESSONS6, doneUpTo(6), TESTS, new Set(['tfin']))?.slug, 'a0-m06');
  // пропущений урок у модулі 3 — фіналу й середини ще немає, модуль 3 не пропонуємо
  const skipped = doneUpTo(6);
  skipped.delete('3b');
  assert.equal(suggestAssessment(LESSONS6, skipped, TESTS, new Set(['t6']))?.slug, 'a0-m05');
});

test('перевірка: уроки без модуля або без перевірок — нічого', () => {
  assert.equal(suggestAssessment([L('x', 1, 1, 1)], new Set(['x']), TESTS, new Set()), null);
  assert.equal(suggestAssessment(LESSONS6, doneUpTo(6), [], new Set()), null);
});
