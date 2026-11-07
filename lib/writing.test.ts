import { test } from 'node:test';
import assert from 'node:assert/strict';
import { answerLang, checkWriting, diacriticHints, parseWritingTask, pointDone, wordsOf, type WritingTask } from './writing.ts';

const doctor: WritingTask = parseWritingTask('write_message', {
  situation_ua: 'Ви не можете прийти до лікаря завтра. Напишіть SMS у поліклініку.',
  points: [
    { ua: 'хто ви', keys: [['zovem'], ['ja sam'], ['ovdje']] },
    { ua: 'що не прийдете завтра', keys: [['sutra', 'ne mog'], ['sutra', 'ne=', 'doć']] },
    { ua: 'попросіть інший термін', keys: [['termin']] },
  ],
  hints: ['termin', 'sutra', 'ne mogu doći', 'molim Vas'],
  models: ['Dobar dan, ovdje Olena Kovalenko. Sutra ne mogu doći na pregled. Molim Vas drugi termin. Hvala!'],
})!;

test('parseWritingTask: коректне завдання, некоректне — null', () => {
  assert.ok(doctor);
  assert.equal(doctor.points.length, 3);
  assert.equal(parseWritingTask('write_message', { situation_ua: 'x', points: [], models: ['a'] }), null);
  assert.equal(parseWritingTask('mediation', { situation_ua: 'x', points: [{ ua: 'a', keys: [['b']] }], models: ['a'] }), null, 'переказ без напряму');
  assert.equal(parseWritingTask('mediation', { situation_ua: 'x', direction: 'hr_ua', points: [{ ua: 'a', keys: [['b']] }], models: ['a'] }), null,
    'hr_ua без хорватського тексту');
  assert.equal(parseWritingTask('speaking', {}), null);
  assert.equal(parseWritingTask('write_message', null), null);
});

test('wordsOf: регістр, розділові знаки, діакритики (hr), апостроф (ua)', () => {
  assert.deepEqual(wordsOf('Sutra NE mogu doći!', 'hr'), ['sutra', 'ne', 'mogu', 'doci']);
  assert.deepEqual(wordsOf('Обов’язково, о 14:00', 'ua'), ["обов'язково", 'о', '14', '00']);
});

test('pointDone: основа, кілька слів, ціле слово', () => {
  const w = wordsOf('Mogu li dobiti drugi termin? Sutra ne mogu.', 'hr');
  assert.ok(pointDone(w, { ua: 'термін', keys: [['termin']] }, 'hr'));
  assert.ok(pointDone(w, { ua: 'не можу', keys: [['ne mog']] }, 'hr'));
  assert.ok(!pointDone(wordsOf('Nemam vremena', 'hr'), { ua: 'не', keys: [['ne=']] }, 'hr'), '«ne=» не збігається з «nemam»');
  assert.ok(!pointDone(w, { ua: 'ім’я', keys: [['zovem']] }, 'hr'));
});

test('checkWriting: усі пункти без діакритик — зараховано, з підказкою doci → doći', () => {
  const r = checkWriting(doctor, 'Dobar dan, ja sam Olena. Sutra ne mogu doci. Mogu li dobiti drugi termin?');
  assert.equal(r.correct, true);
  assert.equal(r.done, 3);
  assert.deepEqual(r.diacritics, [{ written: 'doci', correct: 'doći' }]);
});

test('checkWriting: бракує пункту — не зараховано, видно який', () => {
  const r = checkWriting(doctor, 'Dobar dan, ovdje Olena. Sutra ne mogu doći.');
  assert.equal(r.correct, false);
  assert.deepEqual(r.points.map((p) => p.done), [true, true, false]);
});

test('checkWriting: одне слово — «замало», нічого не зараховано', () => {
  const r = checkWriting(doctor, 'termin');
  assert.equal(r.tooShort, true);
  assert.equal(r.correct, false);
  assert.equal(r.done, 0);
});

const sign = parseWritingTask('mediation', {
  situation_ua: 'Друг не знає хорватської. Перекажіть йому головне з вивіски.',
  source_hr: 'RADNO VRIJEME\npon – pet 8 – 20\nsub 8 – 14\nned ZATVORENO',
  friend_ua: 'Слухай, вони в неділю працюють? А в суботу до котрої?',
  direction: 'hr_ua',
  points: [
    { ua: 'неділя — зачинено', keys: [['зачин'], ['не працю'], ['вихідн']] },
    { ua: 'субота — до 14:00', keys: [['14'], ['другої']] },
  ],
  hints: [],
  models: ['У неділю зачинено, а в суботу — до 14:00.'],
})!;

test('переказ hr → ua: перевірка українською, без підказок діакритик', () => {
  assert.equal(answerLang(sign), 'ua');
  const r = checkWriting(sign, 'Ні, в неділю зачинено. А в суботу до 14.');
  assert.equal(r.correct, true);
  assert.deepEqual(r.diacritics, []);
  assert.equal(checkWriting(sign, 'У суботу до другої.').correct, false);
});

test('переказ ua → hr: відповідь хорватською', () => {
  const t = parseWritingTask('mediation', {
    situation_ua: 'Ви в аптеці з подругою.', friend_ua: 'Скажи їй, що в мене болить горло і треба щось без рецепта.',
    direction: 'ua_hr', points: [{ ua: 'болить горло', keys: [['boli', 'grlo']] }, { ua: 'без рецепта', keys: [['bez recept']] }],
    hints: ['grlo', 'bez recepta'], models: ['Moju prijateljicu boli grlo. Treba joj nešto bez recepta.'],
  })!;
  assert.equal(answerLang(t), 'hr');
  assert.equal(checkWriting(t, 'Nju boli grlo, treba nesto bez recepta.').correct, true);
  assert.deepEqual(checkWriting(t, 'Nju boli grlo, treba nesto bez recepta.').diacritics, [{ written: 'nesto', correct: 'nešto' }]);
});

test('diacriticHints: без повторів, не більше 5, правильне слово не чіпаємо', () => {
  assert.deepEqual(diacriticHints('kuca kuca kuća', ['Kuća je velika.']), [{ written: 'kuca', correct: 'kuća' }]);
  assert.deepEqual(diacriticHints('doći', ['doći']), []);
});
