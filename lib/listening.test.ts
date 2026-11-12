import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  allAnswered, answerTurns, checkShortAnswer, DEFAULT_MAX_PLAYS, LISTENING_MAX_LINE, normalizeShortAnswer, parseListeningTask, playsLeft,
  scoreListening,
} from './listening.ts';

const FERRY = {
  kind: 'announcement',
  situation_ua: 'Ви в порту в Спліті. Слухайте оголошення.',
  script: [
    { hr: 'Poštovani putnici, trajekt za Supetar kasni trideset minuta zbog jakog vjetra.', ua: 'Шановні пасажири, пором до Супетара запізнюється на тридцять хвилин через сильний вітер.' },
    { hr: 'Novo vrijeme polaska je jedanaest i trideset.', ua: 'Новий час відправлення — одинадцята тридцять.' },
  ],
  questions: [
    { q_ua: 'Чому пором запізнюється?', options: ['через сильний вітер', 'через ремонт', 'через страйк'], correct: 0, answer_turn: 0 },
    { q_ua: 'Коли новий час відправлення?', answer_text: '11.30', accept: ['11:30', 'пів на дванадцяту'], answer_turn: 1 },
  ],
};

test('завдання: коректне розбирається, max_plays за замовчуванням 3', () => {
  const t = parseListeningTask(FERRY);
  assert.ok(t);
  assert.equal(t.kind, 'announcement');
  assert.equal(t.script.length, 2);
  assert.equal(t.script[0].speaker, undefined);
  assert.equal(t.max_plays, DEFAULT_MAX_PLAYS);
  assert.equal(t.questions[0].kind, 'choice');
  assert.equal(t.questions[1].kind, 'short');
  assert.deepEqual([...answerTurns(t)], [0, 1]);
});

test('завдання: некоректне — null (урок не ламається)', () => {
  assert.equal(parseListeningTask(null), null);
  assert.equal(parseListeningTask([]), null);
  assert.equal(parseListeningTask({ ...FERRY, kind: 'song' }), null);
  assert.equal(parseListeningTask({ ...FERRY, situation_ua: ' ' }), null);
  assert.equal(parseListeningTask({ ...FERRY, script: [] }), null);
  assert.equal(parseListeningTask({ ...FERRY, script: [{ hr: 'x'.repeat(LISTENING_MAX_LINE + 1), ua: 'щось' }] }), null);
  assert.equal(parseListeningTask({ ...FERRY, script: [{ hr: 'Добрий день.', ua: 'Добрий день.' }] }), null, 'кирилиця в хорватському');
  assert.equal(parseListeningTask({ ...FERRY, script: [{ hr: 'Dobar dan.', ua: '' }] }), null);
  assert.equal(parseListeningTask({ ...FERRY, questions: [] }), null);
  assert.equal(parseListeningTask({ ...FERRY, questions: [{ q_ua: 'Що?', options: ['a', 'a'], correct: 0 }] }), null, 'повтор варіанта');
  assert.equal(parseListeningTask({ ...FERRY, questions: [{ q_ua: 'Що?', options: ['a', 'b'], correct: 2 }] }), null);
  assert.equal(parseListeningTask({ ...FERRY, questions: [{ q_ua: 'Що?', options: ['a'], correct: 0 }] }), null);
  assert.equal(parseListeningTask({ ...FERRY, questions: [{ q_ua: 'Що?' }] }), null, 'ні варіантів, ні відповіді');
});

test('завдання: max_plays у межах 1–5, хибний answer_turn відкидається', () => {
  assert.equal(parseListeningTask({ ...FERRY, max_plays: 9 })!.max_plays, 5);
  assert.equal(parseListeningTask({ ...FERRY, max_plays: 0 })!.max_plays, 1);
  const t = parseListeningTask({ ...FERRY, questions: [{ q_ua: 'Що?', options: ['a', 'b'], correct: 1, answer_turn: 7 }] })!;
  assert.equal(t.questions[0].answer_turn, undefined);
});

test('коротка відповідь: час, діакритика, регістр', () => {
  assert.equal(normalizeShortAnswer(' 11.30 '), '11:30');
  assert.equal(normalizeShortAnswer('11 i 30'), '11:30');
  assert.equal(normalizeShortAnswer('11h30'), '11:30');
  assert.equal(normalizeShortAnswer('Šibenik.'), 'sibenik');
  const q = { answer_text: '11.30', accept: ['пів на дванадцяту'] };
  assert.equal(checkShortAnswer('11:30', q), true);
  assert.equal(checkShortAnswer('11,30', q), true);
  assert.equal(checkShortAnswer('Пів на дванадцяту', q), true);
  assert.equal(checkShortAnswer('11.00', q), false);
  assert.equal(checkShortAnswer('  ', q), false);
  assert.equal(checkShortAnswer('supetar', { answer_text: 'Supetar', accept: [] }), true);
});

test('оцінка: усі правильні — correct, інакше wrong', () => {
  const t = parseListeningTask(FERRY)!;
  assert.deepEqual(scoreListening(t, [0, '11:30']), { results: [true, true], correct: 2, total: 2, outcome: 'correct' });
  assert.deepEqual(scoreListening(t, [1, '11:30']), { results: [false, true], correct: 1, total: 2, outcome: 'wrong' });
  assert.deepEqual(scoreListening(t, [null, null]), { results: [false, false], correct: 0, total: 2, outcome: 'wrong' });
  assert.equal(allAnswered(t, [0, '11:30']), true);
  assert.equal(allAnswered(t, [0, ' ']), false);
  assert.equal(allAnswered(t, [null, '11:30']), false);
});

test('прослуховування: лишилось не менше нуля', () => {
  assert.equal(playsLeft(0, 3), 3);
  assert.equal(playsLeft(3, 3), 0);
  assert.equal(playsLeft(5, 3), 0);
});
