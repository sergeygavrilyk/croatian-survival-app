import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  canPractiseAsSentence, categoryLabel, countByCategory, errorTypeFor, examplesFrom, INTERFERENCE_CATEGORIES,
  isSpoken, lessonPitfalls, pickQuiz, quizOptions, quizQuestion, shortExplanation, upToLevel,
} from './interference.ts';

const seq = (...xs: number[]) => {
  let i = 0;
  return () => xs[i++ % xs.length];
};

test('12 категорій ТЗ з українськими назвами', () => {
  assert.equal(INTERFERENCE_CATEGORIES.length, 12);
  assert.equal(categoryLabel('false_friends'), 'Оманливі слова');
  assert.equal(categoryLabel('щось'), 'Інше');
});

test('вимова й наголос — окреме питання і без плиток', () => {
  assert.equal(isSpoken('stress'), true);
  assert.equal(quizQuestion('stress'), 'Як правильно вимовляти?');
  assert.equal(quizQuestion('cases'), 'Яке речення правильне?');
  assert.equal(canPractiseAsSentence({ category: 'pronunciation', correct_text: 'Hrvatska — «Хрватська»' }), false);
  assert.equal(canPractiseAsSentence({ category: 'cases', correct_text: 'Idem u školu.' }), true);
  assert.equal(canPractiseAsSentence({ category: 'cases', correct_text: 'Bobice.' }), false);
});

test('тип особистої помилки за категорією', () => {
  assert.equal(errorTypeFor('word_order'), 'word_order');
  assert.equal(errorTypeFor('false_friends'), 'vocabulary');
  assert.equal(errorTypeFor('collocations'), 'vocabulary');
  assert.equal(errorTypeFor('stress'), 'pronunciation');
  assert.equal(errorTypeFor('gender'), 'grammar');
});

test('пояснення для «Моїх помилок» — не довше 300 символів', () => {
  const s = shortExplanation({ title_ua: 'Назва', explanation_ua: 'x'.repeat(400) });
  assert.equal(s.length, 300);
  assert.ok(s.endsWith('…'));
  assert.equal(shortExplanation({ title_ua: 'Рід', explanation_ua: 'Коротко.' }), 'Рід. Коротко.');
});

test('два варіанти: правильний і неправильний', () => {
  const opts = quizOptions({ incorrect_text: 'Idem u školi.', correct_text: 'Idem u školu.' }, seq(0.9));
  assert.equal(opts.length, 2);
  assert.equal(opts.filter((o) => o.correct).length, 1);
  assert.equal(opts.find((o) => o.correct)?.text, 'Idem u školu.');
});

test('рівень: A0 бачить лише A0, A1 — A0 і A1, невідомий — до A1', () => {
  const items = [{ cefr: 'A0' }, { cefr: 'A1' }, { cefr: 'A2' }];
  assert.equal(upToLevel(items, 'A0').length, 1);
  assert.equal(upToLevel(items, 'A1').length, 2);
  assert.equal(upToLevel(items, null).length, 2);
  assert.equal(upToLevel(items, 'B2').length, 3);
});

test('вправа: спершу нові помилки, потім уже знайомі; фільтр категорії', () => {
  const items = [
    { id: 'a', category: 'cases' }, { id: 'b', category: 'cases' }, { id: 'c', category: 'gender' }, { id: 'd', category: 'cases' },
  ];
  const quiz = pickQuiz(items, { exclude: new Set(['a']), size: 3, random: seq(0.1) });
  assert.equal(quiz.length, 3);
  assert.ok(!quiz.some((e) => e.id === 'a'));
  const onlyCases = pickQuiz(items, { category: 'cases', exclude: new Set(['a', 'b', 'd']), size: 5 });
  assert.deepEqual(onlyCases.map((e) => e.id).sort(), ['a', 'b', 'd']);
});

test('лічильник категорій — лише непорожні, у порядку ТЗ', () => {
  assert.deepEqual(countByCategory([{ category: 'gender' }, { category: 'cases' }, { category: 'gender' }]), [
    { category: 'cases', count: 1 },
    { category: 'gender', count: 2 },
  ]);
});

test('картки уроку: спершу слова, потім граматика, без повторів, не більше трьох', () => {
  const items = [
    { id: '1', code: 'UKR-HR-0001', grammar_topic_id: 'g1', lexeme_id: null },
    { id: '2', code: 'UKR-HR-0002', grammar_topic_id: 'g1', lexeme_id: 'w1' },
    { id: '3', code: 'UKR-HR-0003', grammar_topic_id: 'g2', lexeme_id: null },
    { id: '4', code: 'UKR-HR-0004', grammar_topic_id: 'g1', lexeme_id: null },
    { id: '5', code: 'UKR-HR-0005', grammar_topic_id: 'g1', lexeme_id: null },
  ];
  assert.deepEqual(lessonPitfalls(items, ['g1'], ['w1']).map((e) => e.id), ['2', '1', '4']);
  assert.deepEqual(lessonPitfalls(items, ['g9'], []).map((e) => e.id), []);
});

test('приклади з БД: лише пари hr / ua', () => {
  assert.deepEqual(examplesFrom([{ hr: 'Da.', ua: 'Так.' }, { hr: 1 }, null, 'x']), [{ hr: 'Da.', ua: 'Так.' }]);
  assert.deepEqual(examplesFrom(null), []);
});
