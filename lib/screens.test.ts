import { test } from 'node:test';
import assert from 'node:assert/strict';
import { pluralUk } from './format.ts';
import { summarizeSituations, situationMeta, isKnownSituation } from './situations.ts';
import { scorePlacement, shouldStopAfterLevel, type PlacementItem } from './placement.ts';
import { validateOnboarding } from './onboarding.ts';
import { summarizeProgress, dayKey } from './progress.ts';

// ------------------------------------------------------------ формат
test('українська множина', () => {
  const f = ['фраза', 'фрази', 'фраз'] as const;
  assert.deepEqual([1, 2, 4, 5, 11, 12, 14, 21, 22, 25, 101, 111].map((n) => pluralUk(n, f)),
    ['фраза', 'фрази', 'фрази', 'фраз', 'фраз', 'фраз', 'фраз', 'фраза', 'фрази', 'фраз', 'фраза', 'фраз']);
});

// ------------------------------------------------------------ ситуації
test('ситуації: зведення, порядок, порожні не показуються', () => {
  const list = summarizeSituations(
    [{ situation: 'health', cefr: 'A1' }, { situation: 'health', cefr: 'A0' }, { situation: 'basics', cefr: 'A0' },
     { situation: null, cefr: 'A1' }, { situation: 'zzz_new', cefr: null }],
    [{ situation: 'health', level: 'A1' }, { situation: 'it_work', level: 'A2' }],
  );
  assert.deepEqual(list.map((s) => s.code), ['basics', 'health', 'it_work', 'zzz_new']);
  const health = list.find((s) => s.code === 'health')!;
  assert.equal(health.phrases, 2);
  assert.equal(health.dialogues, 1);
  assert.deepEqual(health.levels, ['A0', 'A1']);
  assert.equal(situationMeta(health), 'A0–A1 · 2 фрази · 1 діалог');
  assert.equal(situationMeta({ phrases: 5, dialogues: 0, levels: ['A1'] }), 'A1 · 5 фраз');
  assert.equal(isKnownSituation('bank'), true);
  assert.equal(isKnownSituation('../admin'), false);
});

// ------------------------------------------------------------ тест рівня
// Як у placement-v1: по 4 питання на A0–B1 і 8 на B2
const LEVELS = ['A0', 'A1', 'A2', 'B1', 'B2'];
const PER_LEVEL = [4, 4, 4, 4, 8];
const ITEMS: PlacementItem[] = LEVELS.flatMap((cefr, li) =>
  Array.from({ length: PER_LEVEL[li] }, (_, k) => ({ id: `${cefr}-${k}`, cefr, skill: k % 2 ? 'grammar' : 'vocabulary', correct_index: (li + k) % 4 })));
const answer = (correctPerLevel: number[]) =>
  ITEMS.map((it) => {
    const li = LEVELS.indexOf(it.cefr);
    const k = Number(it.id.split('-')[1]);
    return { item_id: it.id, chosen: k < correctPerLevel[li] ? it.correct_index : (it.correct_index + 1) % 4 };
  });

test('тест рівня: усе неправильно → починати з A0', () => {
  const r = scorePlacement(ITEMS, answer([0, 0, 0, 0, 0]));
  assert.equal(r.estimated, 'A0');
  assert.equal(r.recommendedStart, 'A0');
  assert.equal(r.confidence, 'high');
});

test('тест рівня: A0 і A1 пройдено, A2 ні → оцінка A1, старт A2', () => {
  const r = scorePlacement(ITEMS, answer([4, 3, 1, 0, 0]));
  assert.equal(r.estimated, 'A1');
  assert.equal(r.recommendedStart, 'A2');
  assert.equal(r.confidence, 'high');
  assert.deepEqual(r.scoreByLevel.A1, { correct: 3, total: 4 });
  assert.equal(r.answers.length, 24);
});

test('тест рівня: межа нечітка (2 з 4) → середня впевненість', () => {
  assert.equal(scorePlacement(ITEMS, answer([4, 2, 0, 0, 0])).confidence, 'medium');
});

test('тест рівня: пройдено вищий рівень після проваленого → низька впевненість', () => {
  const r = scorePlacement(ITEMS, answer([4, 1, 4, 0, 0]));
  assert.equal(r.estimated, 'A0');
  assert.equal(r.confidence, 'low');
});

test('тест рівня: B1 пройдено, B2 — 5 з 8 (нижче 75 %) → оцінка B1, старт B2', () => {
  const r = scorePlacement(ITEMS, answer([4, 4, 4, 4, 5]));
  assert.equal(r.estimated, 'B1');
  assert.equal(r.recommendedStart, 'B2');
  assert.deepEqual(r.scoreByLevel.B2, { correct: 5, total: 8 });
  assert.equal(r.confidence, 'medium');
});

test('тест рівня: B2 — 6 з 8 → оцінка B2, старт B2 (вище немає)', () => {
  const r = scorePlacement(ITEMS, answer([4, 4, 4, 4, 6]));
  assert.equal(r.estimated, 'B2');
  assert.equal(r.recommendedStart, 'B2');
  assert.equal(r.confidence, 'high');
});

test('тест рівня: зупинка на рівні й «Не знаю» — пропущені питання рахуються як неправильні', () => {
  const partial = [
    ...ITEMS.filter((i) => i.cefr === 'A0').map((i) => ({ item_id: i.id, chosen: i.correct_index })),
    ...ITEMS.filter((i) => i.cefr === 'A1').map((i) => ({ item_id: i.id, chosen: null })),
  ];
  const r = scorePlacement(ITEMS, partial);
  assert.equal(r.estimated, 'A0');
  assert.equal(r.recommendedStart, 'A1');
  assert.equal(r.scoreByLevel.B1.correct, 0);
  assert.equal(shouldStopAfterLevel({ correct: 1, total: 4 }), true);
  assert.equal(shouldStopAfterLevel({ correct: 2, total: 4 }), false);
});

// ------------------------------------------------------------ онбординг
test('онбординг: коректні дані проходять, дублікати мети прибираються', () => {
  const r = validateOnboarding({ goals: ['work', 'work', 'documents'], dailyGoalMinutes: 15, level: 'A1', timezone: 'Europe/Zagreb' });
  assert.deepEqual(r, { ok: true, data: { learning_goals: ['work', 'documents'], daily_goal_minutes: 15, current_level: 'A1', timezone: 'Europe/Zagreb' } });
});

test('онбординг: некоректні значення відхиляються', () => {
  assert.equal(validateOnboarding({ goals: [], dailyGoalMinutes: 15, level: 'A1' }).ok, false);
  assert.equal(validateOnboarding({ goals: ['hack'], dailyGoalMinutes: 15, level: 'A1' }).ok, false);
  assert.equal(validateOnboarding({ goals: ['work'], dailyGoalMinutes: 7, level: 'A1' }).ok, false);
  assert.equal(validateOnboarding({ goals: ['work'], dailyGoalMinutes: 15, level: 'C2' }).ok, false);
  const bad = validateOnboarding({ goals: ['work'], dailyGoalMinutes: 15, level: 'A0', timezone: "'; drop" });
  assert.equal(bad.ok && bad.data.timezone, null);
});

// ------------------------------------------------------------ прогрес
test('прогрес: слова, повторення і активність за 7 днів у часовому поясі', () => {
  const now = new Date('2026-10-12T22:30:00Z'); // у Загребі (UTC+2) вже 13-те, 00:30
  const s = summarizeProgress({
    now,
    timeZone: 'Europe/Zagreb',
    lessonsCompleted: 1,
    cards: [
      { interval_days: 0, next_review_date: '2026-10-12T08:00:00Z', cefr: 'A0' },
      { interval_days: 1, next_review_date: '2026-10-13T08:00:00Z', cefr: 'A0' },
      { interval_days: 25, next_review_date: '2026-11-05T08:00:00Z', cefr: 'A1' },
    ],
    reviews: [
      { created_at: '2026-10-12T22:10:00Z' }, // 13.10 у Загребі
      { created_at: '2026-10-12T10:00:00Z' },
      { created_at: '2026-10-07T10:00:00Z' },
      { created_at: '2026-10-01T10:00:00Z' }, // поза 7 днями
      { created_at: 'not a date' },
    ],
  });
  assert.equal(s.inLearning, 3);
  assert.equal(s.dueNow, 1);
  assert.equal(s.learned, 2);
  assert.equal(s.longTerm, 1);
  assert.deepEqual(s.byLevel, [{ level: 'A0', count: 2 }, { level: 'A1', count: 1 }]);
  assert.equal(s.activity.length, 7);
  assert.equal(s.activity[6].date, '2026-10-13');
  assert.equal(s.activity[6].label, 'Вт');
  assert.equal(s.activity[6].count, 1);
  assert.equal(s.activity[5].count, 1);
  assert.equal(s.activity[0].date, '2026-10-07');
  assert.equal(s.reviews7, 3);
  assert.equal(s.activeDays, 3);
});

test('прогрес: невідомий часовий пояс → UTC, без падіння', () => {
  assert.equal(dayKey(new Date('2026-10-12T23:30:00Z'), 'Mars/Base'), '2026-10-12');
});
