// «Ситуації» у радісному стилі: групи, кількість, рівні (lib/situations.ts). Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { SITUATIONS, SITUATION_GROUPS, groupSituations, situationCounts, sortedLevels } from './situations.ts';

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
