import { test } from 'node:test';
import assert from 'node:assert/strict';
import { countUk, dictionarySearchTerm, posLabelUk } from './format.ts';

test('частина мови українською', () => {
  assert.equal(posLabelUk('noun'), 'іменник');
  assert.equal(posLabelUk('VERB'), 'дієслово');
  assert.equal(posLabelUk('adjective'), 'прикметник');
  assert.equal(posLabelUk('phrase'), 'вираз');
  assert.equal(posLabelUk('word'), null);
  assert.equal(posLabelUk(null), null);
  assert.equal(posLabelUk('щось нове'), null);
});

test('пошук у словнику: без символів, що ламають фільтр', () => {
  assert.equal(dictionarySearchTerm('  bijela  mačka '), 'bijela mačka');
  assert.equal(dictionarySearchTerm('a,b(c)%_*'), 'a b c');
  assert.equal(dictionarySearchTerm("комп'ютер"), 'комп_ютер');
  assert.equal(dictionarySearchTerm('комп’ютер'), 'комп_ютер');
  assert.equal(dictionarySearchTerm("'"), null);
  assert.equal(dictionarySearchTerm('   '), null);
  assert.equal(dictionarySearchTerm('x'.repeat(100))!.length, 60);
});

test('countUk', () => {
  assert.equal(countUk(21, ['слово', 'слова', 'слів']), '21 слово');
});
