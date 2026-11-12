import { test } from 'node:test';
import assert from 'node:assert/strict';
import { isUuid, newWordProgress, wordExamples } from './word-save.ts';

test('isUuid: лише id запису', () => {
  assert.equal(isUuid('04850d32-d7fe-4c4e-9041-d41cdf9e369a'), true);
  assert.equal(isUuid('04850D32-D7FE-4C4E-9041-D41CDF9E369A'), true);
  assert.equal(isUuid('pomidor'), false);
  assert.equal(isUuid(''), false);
  assert.equal(isUuid(null), false);
  assert.equal(isUuid(42), false);
  assert.equal(isUuid("04850d32-d7fe-4c4e-9041-d41cdf9e369a' or 1=1"), false);
});

test('нове слово в повтореннях — на сьогодні', () => {
  const now = new Date('2026-11-12T14:00:00Z');
  assert.deepEqual(newWordProgress('u1', 'l1', now), {
    user_id: 'u1',
    lexeme_id: 'l1',
    interval_days: 0,
    repetition_count: 0,
    next_review_date: '2026-11-12T14:00:00.000Z',
  });
});

test('приклади слова: рядки, без повторів, не більше max', () => {
  assert.deepEqual(wordExamples(['Salata od pomidora.', '  Salata   od pomidora. ', 'Ponesi šugaman.', 'Treći.']), [
    'Salata od pomidora.',
    'Ponesi šugaman.',
  ]);
  assert.deepEqual(wordExamples(['A.', 'B.', 'C.'], 3), ['A.', 'B.', 'C.']);
  assert.deepEqual(wordExamples([null, 7, '', ' ', 'Dobar dan.']), ['Dobar dan.']);
  assert.deepEqual(wordExamples(null), []);
  assert.deepEqual(wordExamples('Salata.'), []);
  assert.deepEqual(wordExamples({}), []);
});
