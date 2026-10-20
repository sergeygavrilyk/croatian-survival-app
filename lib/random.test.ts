import { test } from 'node:test';
import assert from 'node:assert/strict';
import { newSeed, seededRandom } from './random.ts';
import { shuffleTiles } from './mistakes.ts';
import { quizOptions, pickQuiz } from './interference.ts';

test('однаковий seed — однакова послідовність (сервер і браузер перемішують однаково)', () => {
  const a = seededRandom('abc:1');
  const b = seededRandom('abc:1');
  const xs = Array.from({ length: 5 }, () => a());
  assert.deepEqual(Array.from({ length: 5 }, () => b()), xs);
  assert.ok(xs.every((x) => x >= 0 && x < 1));
});

test('різні seed — різний порядок', () => {
  const items = Array.from({ length: 10 }, (_, i) => i);
  const orders = new Set(['s1', 's2', 's3', 's4'].map((s) => shuffleTiles(items, seededRandom(s)).join(',')));
  assert.ok(orders.size > 1);
});

test('плитки й варіанти з seed — відтворювані', () => {
  const tiles = ['Tako', 'je', 'tak', 'dobro.'];
  assert.deepEqual(shuffleTiles(tiles, seededRandom('x:id1')), shuffleTiles(tiles, seededRandom('x:id1')));
  const e = { incorrect_text: 'U mene je auto.', correct_text: 'Imam auto.' };
  assert.deepEqual(quizOptions(e, seededRandom('q')), quizOptions(e, seededRandom('q')));
  const items = Array.from({ length: 12 }, (_, i) => ({ id: `e${i}`, category: 'gender' as const }));
  assert.deepEqual(pickQuiz(items, { random: seededRandom('s') }), pickQuiz(items, { random: seededRandom('s') }));
});

test('newSeed — короткий непорожній рядок', () => {
  const s = newSeed();
  assert.match(s, /^[a-z0-9]{1,8}$/);
});
