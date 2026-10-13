import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  answerTiles, checkSentence, distractorTiles, isDue, MASTERY_STREAK, scheduleMistake, shuffleTiles,
} from './mistakes.ts';

test('помилки: порівняння без регістру й розділових знаків, діакритики окремо', () => {
  assert.equal(checkSentence('jednu kavu molim', 'Jednu kavu, molim.'), 'exact');
  assert.equal(checkSentence('Zelim cevapcice', 'Želim ćevapčiće.'), 'diacritics');
  assert.equal(checkSentence('jedna kava molim', 'Jednu kavu, molim.'), 'wrong');
  assert.equal(checkSentence('  ', 'Da.'), 'wrong');
});

test('помилки: плитки — слова відповіді й пастки зі сказаного користувачем', () => {
  assert.deepEqual(answerTiles('Jednu kavu, molim.'), ['Jednu', 'kavu,', 'molim.']);
  assert.deepEqual(distractorTiles('jedna kava molim', 'Jednu kavu, molim.'), ['jedna', 'kava']);
  assert.deepEqual(distractorTiles('tak dobro', 'Da, molim.'), ['tak', 'dobro']);
  assert.deepEqual(distractorTiles('Molim molim', 'Molim.'), []);
  assert.equal(distractorTiles('a b c d e f', 'x').length, 3);
});

test('помилки: перемішування не губить і не дублює плитки', () => {
  let seed = 1;
  const rnd = () => ((seed = (seed * 16807) % 2147483647) / 2147483647);
  const tiles = ['a', 'b', 'c', 'd'];
  assert.deepEqual(shuffleTiles(tiles, rnd).sort(), tiles);
});

test('помилки: засвоєно після двох правильних відповідей у різні дні', () => {
  const now = new Date('2026-10-13T10:00:00');
  const first = scheduleMistake({ correctStreak: 0, reviewCount: 0 }, true, now);
  assert.equal(first.correctStreak, 1);
  assert.equal(first.resolvedAt, null);
  assert.equal(first.nextReviewAt.getDate(), 14);
  assert.equal(first.nextReviewAt.getHours(), 0);
  const second = scheduleMistake(first, true, new Date('2026-10-14T09:00:00'));
  assert.equal(second.correctStreak, MASTERY_STREAK);
  assert.ok(second.resolvedAt);
  assert.equal(second.reviewCount, 2);
});

test('помилки: неправильна відповідь скидає серію і повертає помилку сьогодні', () => {
  const now = new Date('2026-10-13T10:00:00');
  const s = scheduleMistake({ correctStreak: 1, reviewCount: 3 }, false, now);
  assert.equal(s.correctStreak, 0);
  assert.equal(s.reviewCount, 4);
  assert.equal(s.nextReviewAt.getTime(), now.getTime());
  assert.equal(s.resolvedAt, null);
});

test('помилки: що чекає повторення', () => {
  const now = new Date('2026-10-13T10:00:00Z');
  assert.equal(isDue({ resolved_at: null, next_review_at: null }, now), true);
  assert.equal(isDue({ resolved_at: null, next_review_at: '2026-10-13T09:00:00Z' }, now), true);
  assert.equal(isDue({ resolved_at: null, next_review_at: '2026-10-14T00:00:00Z' }, now), false);
  assert.equal(isDue({ resolved_at: '2026-10-12T00:00:00Z', next_review_at: null }, now), false);
});
