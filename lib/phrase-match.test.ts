import { test } from 'node:test';
import assert from 'node:assert/strict';
import { cacheKey, findVerifiedMatch, normalizeUa, searchKeyword, translationAlternatives, type VerifiedCandidate } from './phrase-match.ts';

const DB: VerifiedCandidate[] = [
  { hr: 'Gdje je blagajna?', ua: 'Де каса?', kind: 'phrase' },
  { hr: 'Oprostite, ne razumijem.', ua: 'Вибачте, я не розумію.', kind: 'phrase' },
  { hr: 'upomoć', ua: 'допоможіть!; на допомогу!', kind: 'lexeme', rank: 900 },
  { hr: 'izvolite', ua: 'прошу (вам)', kind: 'lexeme', rank: 50 },
  { hr: 'kava', ua: 'кава', kind: 'lexeme', rank: 300 },
  { hr: 'kavica', ua: 'кава', kind: 'lexeme', rank: 2000 },
];

test('нормалізація: регістр, розділові знаки, апострофи, дужки', () => {
  assert.equal(normalizeUa('  Де  КАСА?! '), 'де каса');
  assert.equal(normalizeUa("Обов'язково"), normalizeUa('Обов’язково'));
  assert.equal(normalizeUa('прошу (вам)'), 'прошу');
});

test('значення перекладу розбиваються за ; і /', () => {
  assert.deepEqual(translationAlternatives('допоможіть!; на допомогу!'), ['допоможіть', 'на допомогу']);
  assert.deepEqual(translationAlternatives('сік / сок'), ['сік', 'сок']);
});

test('точний збіг з фразою — без урахування регістру й знаків', () => {
  assert.deepEqual(findVerifiedMatch('де каса', DB), { hr: 'Gdje je blagajna?', ua: 'Де каса?', kind: 'phrase' });
  assert.equal(findVerifiedMatch('вибачте я не розумію', DB)?.hr, 'Oprostite, ne razumijem.');
});

test('збіг з одним зі значень слова; з кількох слів — найчастіше', () => {
  assert.equal(findVerifiedMatch('На допомогу!', DB)?.hr, 'upomoć');
  assert.equal(findVerifiedMatch('Кава', DB)?.hr, 'kava');
  assert.equal(findVerifiedMatch('прошу', DB)?.hr, 'izvolite');
});

test('частковий збіг не рахується — тоді питаємо AI', () => {
  assert.equal(findVerifiedMatch('де каса в цьому магазині', DB), null);
  assert.equal(findVerifiedMatch('каса', DB), null);
  assert.equal(findVerifiedMatch('   ', DB), null);
});

test('ключове слово для пошуку в БД — найдовше, з екрануванням шаблонів', () => {
  assert.equal(searchKeyword('Де найближча аптека?'), 'найближча');
  assert.equal(searchKeyword('100%_знижка'), '100\\%\\_знижка');
  assert.equal(searchKeyword('!'), null);
});

test('ключ кешу однаковий для різного написання', () => {
  assert.equal(cacheKey('Де каса?'), cacheKey('  де КАСА '));
  assert.ok(cacheKey('а'.repeat(500)).length <= 300);
});
