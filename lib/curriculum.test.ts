import { test } from 'node:test';
import assert from 'node:assert/strict';
import { groupByParent, lessonsHref, pickLessonsLevel } from './curriculum.ts';

test('pickLessonsLevel: рівень з адреси, інакше A0', () => {
  assert.equal(pickLessonsLevel('A1'), 'A1');
  assert.equal(pickLessonsLevel('B2'), 'B2');
  assert.equal(pickLessonsLevel('a1'), 'A0');
  assert.equal(pickLessonsLevel('C1'), 'A0');
  assert.equal(pickLessonsLevel(undefined), 'A0');
  assert.equal(pickLessonsLevel(['A1']), 'A0');
});

test('lessonsHref: A0 — просто /lessons, інші рівні — з параметром', () => {
  assert.equal(lessonsHref('A0'), '/lessons');
  assert.equal(lessonsHref('A1'), '/lessons?level=A1');
  assert.equal(lessonsHref(null), '/lessons');
});

test('groupByParent: порядок рядків зберігається, порожні батьки — порожній список, чужі рядки відкидаємо', () => {
  const lessons = [
    { id: 'l1', unit_id: 'u2' },
    { id: 'l2', unit_id: 'u1' },
    { id: 'l3', unit_id: 'u2' },
    { id: 'l4', unit_id: 'u-other' },
  ];
  assert.deepEqual(groupByParent(['u1', 'u2', 'u3'], lessons, 'unit_id'), {
    u1: [{ id: 'l2', unit_id: 'u1' }],
    u2: [{ id: 'l1', unit_id: 'u2' }, { id: 'l3', unit_id: 'u2' }],
    u3: [],
  });
  assert.deepEqual(groupByParent([], lessons, 'unit_id'), {});
  assert.deepEqual(groupByParent<{ id: string; unit_id: string }, 'unit_id'>(['u1'], null, 'unit_id'), { u1: [] });
});
