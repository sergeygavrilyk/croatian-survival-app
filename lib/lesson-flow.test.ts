import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  answerCurrent, choicesFrom, estimateMinutes, isRetry, isUkrainian, lessonStages, orderExercises, practiceDone,
  startPractice, tilesFrom,
} from './lesson-flow.ts';

test('урок: етапи без порожніх частин', () => {
  assert.deepEqual(lessonStages({ words: 10, dialogues: 2, grammar: 1, exercises: 12 }),
    ['intro', 'words', 'dialogue', 'grammar', 'practice', 'summary']);
  assert.deepEqual(lessonStages({ words: 3, dialogues: 1, grammar: 0, exercises: 0 }),
    ['intro', 'words', 'dialogue', 'summary']);
});

test('урок: вправи від упізнавання до мовлення, невідомі типи пропускаємо', () => {
  const ex = [
    { id: 'a', exercise_type: 'speaking' },
    { id: 'b', exercise_type: 'multiple_choice' },
    { id: 'c', exercise_type: 'sentence_builder' },
    { id: 'd', exercise_type: 'essay' },
    { id: 'e', exercise_type: 'multiple_choice' },
    { id: 'f', exercise_type: 'type_answer' },
    { id: 'g', exercise_type: 'fill_in_the_blank' },
    { id: 'h', exercise_type: 'listening' },
  ];
  assert.deepEqual(orderExercises(ex).map((e) => e.id), ['b', 'e', 'g', 'f', 'c', 'h', 'a']);
});

test('урок: неправильна вправа повторюється один раз у кінці', () => {
  let s = startPractice(['a', 'b', 'c']);
  s = answerCurrent(s, 'wrong');
  assert.deepEqual(s.queue, ['b', 'c', 'a']);
  assert.equal(practiceDone(s), 0);
  s = answerCurrent(s, 'correct');
  s = answerCurrent(s, 'skipped');
  assert.equal(isRetry(s), true);
  assert.equal(practiceDone(s), 2);
  s = answerCurrent(s, 'wrong'); // вдруге неправильно — не повторюємо
  assert.deepEqual(s.queue, []);
  assert.deepEqual(s.firstTry, ['b']);
  assert.deepEqual(s.solved, ['b']);
  assert.deepEqual(s.skipped, ['c']);
  assert.equal(practiceDone(s), 3);
  assert.equal(answerCurrent(s, 'correct'), s, 'порожня черга не змінюється');
});

test('урок: правильно з другої спроби — розв’язано, але не з першої', () => {
  let s = startPractice(['a', 'a']);
  assert.equal(s.total, 1, 'повтори id не дублюють вправу');
  s = answerCurrent(s, 'wrong');
  s = answerCurrent(s, 'correct');
  assert.deepEqual(s.solved, ['a']);
  assert.deepEqual(s.firstTry, []);
});

test('урок: варіанти, плитки й мова варіанта', () => {
  assert.deepEqual(choicesFrom(['kava', 'kava', '', 3, 'čaj']), ['kava', 'čaj']);
  assert.deepEqual(choicesFrom(null), []);
  assert.deepEqual(tilesFrom(['Da,', 'da']).map((t) => t.key), ['0:Da,', '1:da']);
  assert.equal(isUkrainian('кава'), true);
  assert.equal(isUkrainian('Dobar dan'), false);
  assert.equal(estimateMinutes({ words: 0, turns: 0, exercises: 1 }), 5);
  assert.equal(estimateMinutes({ words: 12, turns: 10, exercises: 12 }), 11);
});
