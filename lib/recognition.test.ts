import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  PRODUCTION_EXERCISE_TYPES,
  RECOGNITION_SKILL,
  containsLemma,
  isProductionExercise,
  recognitionLexemeIds,
  recognitionOnlyIds,
  withoutProductionFor,
} from './recognition.ts';
import { buildLessonContent } from './lesson-content.ts';
import { pickSession, type DeckEntry } from './trainer-deck.ts';

const W1 = 'a0000000-0000-0000-0000-000000000001';
const W2 = 'a0000000-0000-0000-0000-000000000002';

test('«напишіть» і «скажіть» — вправи, де людина сама створює слово; вибір і плитки — ні', () => {
  assert.equal(RECOGNITION_SKILL, 'recognition');
  assert.deepEqual([...PRODUCTION_EXERCISE_TYPES], ['type_answer', 'speaking']);
  for (const t of ['type_answer', 'speaking']) assert.equal(isProductionExercise(t), true, t);
  for (const t of ['multiple_choice', 'fill_in_the_blank', 'sentence_builder', 'listening', 'listening_dialogue', 'write_message', 'mediation', '', null, undefined])
    assert.equal(isProductionExercise(t), false, String(t));
});

test('слова уроку «лише впізнавати» — за lesson_items.target_skill', () => {
  const ids = recognitionLexemeIds([
    { item_type: 'lexeme', item_id: W1, target_skill: 'recognition' },
    { item_type: 'lexeme', item_id: W2, target_skill: 'vocabulary' },
    { item_type: 'exercise', item_id: 'e1', target_skill: 'recognition' },
    { item_type: 'lexeme', item_id: 'x', target_skill: null },
  ]);
  assert.deepEqual([...ids], [W1]);
});

test('слово у відповіді — цілими словами, без діакритики й регістру; сталий вираз — цілком', () => {
  assert.equal(containsLemma('Nema frke, vidimo se!', 'nema frke'), true);
  assert.equal(containsLemma('Kužiš li?', 'kužiš'), true);
  assert.equal(containsLemma('KUZIS li', 'kužiš'), true, 'без діакритики й регістру');
  assert.equal(containsLemma('Đir po gradu', 'dir'), true, 'đ = d');
  assert.equal(containsLemma('Nema problema', 'nema frke'), false);
  assert.equal(containsLemma('frkeovi', 'frke'), false, 'частина іншого слова — ні');
  assert.equal(containsLemma('frke nema', 'nema frke'), false, 'порядок слів виразу');
  assert.equal(containsLemma('', 'x'), false);
  assert.equal(containsLemma('tekst', ''), false);
  assert.equal(containsLemma(null, 'x'), false);
});

test('урок: «Напишіть» і «Скажіть» зі словом «лише впізнавати» прибрано, решта — у тому самому порядку', () => {
  const exercises = [
    { id: 'e1', exercise_type: 'multiple_choice', correct_answer: 'frka', lexeme_id: W1 },
    { id: 'e2', exercise_type: 'type_answer', correct_answer: 'frka', lexeme_id: W1 },
    { id: 'e3', exercise_type: 'speaking', correct_answer: 'Nema frke, stari.', lexeme_id: null },
    { id: 'e4', exercise_type: 'type_answer', correct_answer: 'kava', lexeme_id: W2 },
    { id: 'e5', exercise_type: 'speaking', correct_answer: 'Jednu kavu, molim.' },
    { id: 'e6', exercise_type: 'sentence_builder', correct_answer: 'Nema frke.' },
  ];
  const kept = withoutProductionFor(exercises, [{ id: W1, lemma: 'frka' }, { id: 'x', lemma: 'nema frke' }]).map((e) => e.id);
  assert.deepEqual(kept, ['e1', 'e4', 'e5', 'e6']);
  assert.deepEqual(withoutProductionFor(exercises, []).map((e) => e.id), exercises.map((e) => e.id), 'немає таких слів — нічого не змінюється');
});

test('buildLessonContent: target_skill = recognition прибирає вправи «напишіть / скажіть» цього слова', () => {
  const content = buildLessonContent({
    lesson: { id: 'l1', title_ua: 'Урок', title_hr: null, level_code: 'B1', objectives: null, estimated_minutes: 15 },
    items: [
      { item_type: 'lexeme', item_id: W1, target_skill: 'recognition' },
      { item_type: 'lexeme', item_id: W2, target_skill: 'vocabulary' },
      { item_type: 'exercise', item_id: 'e1', target_skill: 'vocabulary' },
      { item_type: 'exercise', item_id: 'e2', target_skill: 'writing' },
      { item_type: 'exercise', item_id: 'e3', target_skill: 'writing' },
    ],
    lexemes: [
      { id: W1, lemma: 'frka', ukrainian_translation: 'метушня' },
      { id: W2, lemma: 'kava', ukrainian_translation: 'кава' },
    ],
    exercises: [
      { id: 'e1', exercise_type: 'multiple_choice', question_text: '?', correct_answer: 'frka', options: [], lexeme_id: W1 },
      { id: 'e2', exercise_type: 'type_answer', question_text: '?', correct_answer: 'frka', options: null, lexeme_id: W1 },
      { id: 'e3', exercise_type: 'type_answer', question_text: '?', correct_answer: 'kava', options: null, lexeme_id: W2 },
    ],
    conversations: [],
    turns: [],
    grammar: [],
    errors: [],
  });
  assert.deepEqual(content.exercises.map((e) => e.id), ['e1', 'e3']);
  assert.deepEqual(content.words.map((w) => w.hr_text), ['frka', 'kava'], 'слово лишається серед слів уроку');
});

test('тренажер: «лише впізнавати» — нецензурні й ті, що в уроках лише з recognition; хоч один урок «вживати» — можна писати', () => {
  const only = recognitionOnlyIds(
    [
      { item_id: W1, target_skill: 'recognition' },
      { item_id: W2, target_skill: 'recognition' },
      { item_id: W2, target_skill: 'vocabulary' },
    ],
    [{ id: 'v1', register: 'vulgar' }, { id: 's1', register: 'slang' }],
  );
  assert.deepEqual([...only].sort(), [W1, 'v1'].sort());
  assert.equal(recognitionOnlyIds([]).size, 0);
});

test('тренажер: «Написати» без слів «лише впізнавати», «Картки» — з ними', () => {
  const srs = { easeFactor: 2.5, intervalDays: 0, repetitionCount: 0, lapses: 0 };
  const entry = (id: string, recognitionOnly?: boolean): DeckEntry => ({
    card: { id, hr_text: id, ua_translation: id },
    cefr: 'B1',
    dueAt: 0,
    srs,
    ...(recognitionOnly ? { recognitionOnly } : {}),
  });
  const entries = [entry('a'), entry('b', true), entry('c')];
  assert.deepEqual(pickSession(entries, 'ALL', 'write', 1).cards.map((c) => c.id), ['a', 'c']);
  assert.deepEqual(pickSession(entries, 'ALL', 'recognize', 1).cards.map((c) => c.id), ['a', 'b', 'c']);
});
