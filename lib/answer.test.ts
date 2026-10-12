// Тести перевірки введеного слова (VS-001) і прикладу з пропуском. Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { checkTypedAnswer, maskExample, answerVariants, editDistance, firstExample, BLANK } from './answer.ts';

test('точна відповідь — без урахування регістру, пробілів і розділових знаків', () => {
  assert.equal(checkTypedAnswer('kuća', 'kuća').verdict, 'exact');
  assert.equal(checkTypedAnswer('  Kuća! ', 'kuća').verdict, 'exact');
  assert.equal(checkTypedAnswer('baviti  se', 'baviti se').verdict, 'exact');
});

test('без діакритик — зараховано, але з позначкою', () => {
  const r = checkTypedAnswer('kuca', 'kuća');
  assert.equal(r.verdict, 'diacritics');
  assert.equal(r.correct, true);
  assert.equal(r.expected, 'kuća');
  assert.equal(checkTypedAnswer('zivotinja', 'životinja').verdict, 'diacritics');
  assert.equal(checkTypedAnswer('odjeca', 'odjeća').verdict, 'diacritics');
});

test('одна одруківка в довгому слові — зараховано як «майже»', () => {
  assert.equal(checkTypedAnswer('supermarkt', 'supermarket').verdict, 'typo');
  assert.equal(checkTypedAnswer('zivotnja', 'životinja').verdict, 'typo');
});

test('короткі слова — без поблажок на одруківки', () => {
  assert.equal(checkTypedAnswer('bek', 'bok').verdict, 'wrong');
  assert.equal(checkTypedAnswer('more', 'mora').verdict, 'wrong');
});

test('неправильна і порожня відповідь', () => {
  assert.deepEqual(checkTypedAnswer('hvala', 'bok'), { verdict: 'wrong', correct: false, expected: 'bok' });
  assert.equal(checkTypedAnswer('   ', 'bok').verdict, 'empty');
  assert.equal(checkTypedAnswer('', 'bok').correct, false);
});

test('кілька варіантів леми: будь-який правильний', () => {
  assert.deepEqual(answerVariants('tipkovnica / tastatura'), ['tipkovnica', 'tastatura']);
  assert.equal(checkTypedAnswer('tastatura', 'tipkovnica / tastatura').verdict, 'exact');
  assert.equal(checkTypedAnswer('ona', 'ona (pl)').verdict, 'exact');
});

test('editDistance', () => {
  assert.equal(editDistance('kuca', 'kuca'), 0);
  assert.equal(editDistance('kuca', 'kuce'), 1);
  assert.equal(editDistance('motor', 'mtor'), 1);
  assert.equal(editDistance('', 'abc'), 3);
});

test('приклад з пропуском: ховає слово і його відмінкові форми', () => {
  assert.deepEqual(maskExample('Idemo na more ljeti.', 'more'), { text: `Idemo na ${BLANK} ljeti.`, found: true });
  assert.deepEqual(maskExample('Učim hrvatski jezik.', 'jezik'), { text: `Učim hrvatski ${BLANK}.`, found: true });
  assert.equal(maskExample('Ostaviti napojnicu za uslugu.', 'napojnica za uslugu').text, `Ostaviti ${BLANK} za ${BLANK}.`);
  assert.equal(maskExample('Želim rezervirati stol za dvoje.', 'rezervirati').text, `Želim ${BLANK} stol za dvoje.`);
  assert.equal(maskExample('Popravak vodokotlića u kupaonici.', 'vodokotlić').text, `Popravak ${BLANK} u kupaonici.`);
});

test('короткі слова: відмінки ховаються, схожі чужі слова — ні', () => {
  assert.equal(maskExample('Idem kući.', 'kuća').text, `Idem ${BLANK}.`);
  assert.equal(maskExample('Moramo ići na more.', 'more').text, `Moramo ići na ${BLANK}.`);
  assert.equal(maskExample('Stan je na trećem katu.', 'kat').text, `Stan je na trećem ${BLANK}.`);
});

test('приклад без слова — found = false (не показуємо до відповіді)', () => {
  const r = maskExample('Hvala lijepa.', 'kuća');
  assert.equal(r.found, false);
  assert.equal(r.text, 'Hvala lijepa.');
});

test('firstExample бере перший непорожній рядок', () => {
  assert.equal(firstExample(['  Hvala lijepa. ']), 'Hvala lijepa.');
  assert.equal(firstExample([]), undefined);
  assert.equal(firstExample(null), undefined);
  assert.equal(firstExample(['', 'Drugi.']), 'Drugi.');
});
