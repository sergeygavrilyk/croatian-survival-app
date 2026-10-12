import { test } from 'node:test';
import assert from 'node:assert/strict';
import { annotateOriginal, evaluateSpeech, foldDiacritics, speechTokens } from './speaking.ts';

test('мовлення: точний збіг (регістр і розділові знаки не важать) → «чудово»', () => {
  const r = evaluateSpeech('Dobar dan, trebam pomoć.', ['dobar dan trebam pomoć']);
  assert.equal(r.verdict, 'great');
  assert.equal(r.score, 1);
  assert.deepEqual(r.practiceWords, []);
});

test('мовлення: розпізнавач загубив діакритики — це не помилка вимови', () => {
  assert.equal(evaluateSpeech('Gdje je ljekarna?', ['gdje je ljekarna']).verdict, 'great');
  assert.equal(evaluateSpeech('Trebam pomoć', ['trebam pomoc']).verdict, 'great');
  assert.equal(foldDiacritics('đak'), 'dak');
});

test('мовлення: одне слово не почули → «зрозуміло» + слово для практики', () => {
  const r = evaluateSpeech('Mogu li platiti karticom?', ['mogu li platiti']);
  assert.equal(r.verdict, 'understandable');
  assert.deepEqual(r.practiceWords, ['karticom']);
  assert.deepEqual(r.words.map((w) => w.status), ['ok', 'ok', 'ok', 'missed']);
});

test('мовлення: схоже слово (одна літера) → «close», а не пропуск', () => {
  const r = evaluateSpeech('Imate li slobodan stol?', ['imate li slobodna stol']);
  assert.equal(r.words[2].status, 'close');
  assert.equal(r.verdict, 'understandable');
  assert.deepEqual(r.practiceWords, ['slobodan']);
});

test('мовлення: зайві слова не знижують оцінку, порядок враховано', () => {
  assert.equal(evaluateSpeech('Račun, molim.', ['eee račun molim vas']).verdict, 'great');
});

test('мовлення: половина змісту → «майже», без головних слів → «ще раз», тиша → no_speech', () => {
  assert.equal(evaluateSpeech('Gdje je autobusni kolodvor?', ['gdje je']).verdict, 'retry');
  assert.equal(evaluateSpeech('Gdje je autobusni kolodvor?', ['gdje je kolodvor']).verdict, 'understandable');
  assert.equal(evaluateSpeech('Mogu li platiti karticom?', ['mogu platiti']).verdict, 'almost');
  assert.equal(evaluateSpeech('Gdje je autobusni kolodvor?', ['dobro jutro']).verdict, 'retry');
  assert.equal(evaluateSpeech('Gdje je autobusni kolodvor?', ['', '  ']).verdict, 'no_speech');
  assert.equal(evaluateSpeech('Gdje je autobusni kolodvor?', []).verdict, 'no_speech');
});

test('мовлення: з кількох варіантів розпізнавання береться найкращий', () => {
  const r = evaluateSpeech('Hvala lijepa.', ['vala lepa', 'hvala lijepa']);
  assert.equal(r.verdict, 'great');
  assert.equal(r.transcript, 'hvala lijepa');
});

test('мовлення: службові слова важать менше за повнозначні', () => {
  const missedShort = evaluateSpeech('Idem u trgovinu', ['idem trgovinu']);
  const missedLong = evaluateSpeech('Idem u trgovinu', ['idem u']);
  assert.ok(missedShort.score > missedLong.score);
  assert.deepEqual(speechTokens('«Bok!» — rekao je.'), ['bok', 'rekao', 'je']);
});

test('мовлення: позначки накладаються на оригінальний текст із розділовими знаками', () => {
  const target = 'Dobar dan, trebam — pomoć!';
  const r = evaluateSpeech(target, ['dobar dan trebam']);
  assert.deepEqual(annotateOriginal(target, r.words), [
    { text: 'Dobar', status: 'ok' },
    { text: 'dan,', status: 'ok' },
    { text: 'trebam', status: 'ok' },
    { text: '—', status: null },
    { text: 'pomoć!', status: 'missed' },
  ]);
});
