// «Ситуації» у радісному стилі: групи, кількість, рівні (lib/situations.ts). Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  ALL_LEVELS,
  SITUATIONS,
  SITUATION_GROUPS,
  groupSituations,
  levelFilterOptions,
  matchesLevel,
  situationCounts,
  sortedLevels,
} from './situations.ts';

test('Групи: кожна відома ситуація — рівно в одній групі', () => {
  const all = SITUATION_GROUPS.flatMap((g) => g.codes);
  assert.equal(new Set(all).size, all.length, 'код у двох групах');
  assert.deepEqual([...all].sort(), SITUATIONS.map((s) => s.code).sort());
});

test('Групи: порядок груп і ситуацій зберігається, невідомі — в «Інше», порожні групи сховано', () => {
  const items = [{ code: 'health' }, { code: 'basics' }, { code: 'zzz_new' }, { code: 'shopping' }];
  const g = groupSituations(items);
  assert.deepEqual(g.map((x) => x.key), ['everyday', 'home', 'other']);
  assert.deepEqual(g[0].items.map((x) => x.code), ['basics', 'shopping']);
  assert.deepEqual(g[2], { key: 'other', label: 'Інше', items: [{ code: 'zzz_new' }] });
  assert.deepEqual(groupSituations([]), []);
});

test('Кількість фраз і діалогів — українською, без рівнів', () => {
  assert.equal(situationCounts({ phrases: 9, dialogues: 1 }), '9 фраз · 1 діалог');
  assert.equal(situationCounts({ phrases: 2, dialogues: 0 }), '2 фрази');
  assert.equal(situationCounts({ phrases: 0, dialogues: 3 }), '3 діалоги');
});

test('Рівні: без повторів і порожніх, від A0 до B2', () => {
  assert.deepEqual(sortedLevels(['A1', null, 'A0', 'A1', undefined, 'B2', 'XX', '']), ['A0', 'A1', 'B2']);
});

test('Фільтр за рівнем: «Усі» + рівні від нижчого з кількістю; без рівня — лише в «Усі»', () => {
  const levels = ['A1', 'A0', 'A1', null, 'A2', 'A0', 'A1'];
  assert.deepEqual(levelFilterOptions(levels), [
    { key: ALL_LEVELS, label: 'Усі', count: 7 },
    { key: 'A0', label: 'A0', count: 2 },
    { key: 'A1', label: 'A1', count: 3 },
    { key: 'A2', label: 'A2', count: 1 },
  ]);
  const shown = levels.filter((l) => matchesLevel(l, 'A1'));
  assert.deepEqual(shown, ['A1', 'A1', 'A1']);
  assert.equal(levels.filter((l) => matchesLevel(l, ALL_LEVELS)).length, 7);
});

test('Фільтр за рівнем: один рівень або жодного — кнопок немає', () => {
  assert.deepEqual(levelFilterOptions(['A0', 'A0', null]), []);
  assert.deepEqual(levelFilterOptions([]), []);
});
