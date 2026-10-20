import { test } from 'node:test';
import assert from 'node:assert/strict';
import { moduleShortTitle, wordInitial, wordThemes } from './word-theme.ts';

const row = (itemId: string, level: string, moduleOrder: number, lessonOrder = 1, status = 'PUBLISHED', title = `Модуль ${level}.${moduleOrder} — Тема`) => ({
  item_id: itemId,
  lessons: { order_index: lessonOrder, status, units: { order_index: 1, status: 'PUBLISHED', modules: { level_code: level, order_index: moduleOrder, title_ua: title, title_hr: null, status: 'PUBLISHED' } } },
});

test('wordThemes: модуль, де слово трапляється найраніше', () => {
  const themes = wordThemes([
    row('kava', 'A1', 2),
    row('kava', 'A0', 7, 3, 'PUBLISHED', 'Модуль A0.7 — Hrana (їжа)'),
    row('kava', 'A0', 7, 5),
    row('bok', 'A0', 1),
  ]);
  assert.deepEqual(themes.get('kava'), { level: 'A0', moduleOrder: 7, icon: '🍽️', title: 'Hrana (їжа)' });
  assert.equal(themes.get('bok')?.icon, '👋');
  assert.equal(themes.size, 2);
});

test('wordThemes: неопубліковане й зіпсоване пропускаємо, масиви PostgREST розуміємо', () => {
  const themes = wordThemes([
    row('a', 'A0', 3, 1, 'DRAFT'),
    { item_id: 'b', lessons: [{ order_index: 1, units: [{ order_index: 1, modules: [{ level_code: 'a0', order_index: 8, title_ua: 'Модуль A0.8 — Kupovina' }] }] }] },
    { item_id: 'c', lessons: null },
    { item_id: 42 },
    null,
    row('d', 'C1', 1),
  ]);
  assert.equal(themes.has('a'), false);
  assert.deepEqual(themes.get('b'), { level: 'A0', moduleOrder: 8, icon: '🛒', title: 'Kupovina' });
  assert.equal(themes.has('c'), false);
  assert.equal(themes.has('d'), false);
  assert.equal(wordThemes(null).size, 0);
});

test('moduleShortTitle', () => {
  assert.equal(moduleShortTitle('Модуль A0.10 — Survival Croatian (виживання)'), 'Survival Croatian (виживання)');
  assert.equal(moduleShortTitle('Модуль A1.7 – Здоров’я'), 'Здоров’я');
  assert.equal(moduleShortTitle('Pozdrav!'), 'Pozdrav!');
  assert.equal(moduleShortTitle(null), '');
});

test('wordInitial: хорватські двознаки — одна літера', () => {
  assert.equal(wordInitial('ljubav'), 'Lj');
  assert.equal(wordInitial('Njemačka'), 'Nj');
  assert.equal(wordInitial('džep'), 'Dž');
  assert.equal(wordInitial('čaj'), 'Č');
  assert.equal(wordInitial('  dobar dan'), 'D');
  assert.equal(wordInitial('…i'), 'I');
  assert.equal(wordInitial(''), '?');
  assert.equal(wordInitial(null), '?');
});
