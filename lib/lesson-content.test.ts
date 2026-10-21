import { test } from 'node:test';
import assert from 'node:assert/strict';
import { buildLessonContent, inOrder, isLessonContent, lessonItemIds, pitfallsFilter, type LessonRows } from './lesson-content.ts';

const rows = (): LessonRows => ({
  lesson: { id: 'L1', title_ua: 'Кафе', title_hr: 'U kafiću', level_code: 'A0', objectives: ['Замовити каву', '', 7], estimated_minutes: 15 },
  items: [
    { item_type: 'lexeme', item_id: 'w2' },
    { item_type: 'grammar', item_id: 'g1' },
    { item_type: 'lexeme', item_id: 'w1' },
    { item_type: 'exercise', item_id: 'e2' },
    { item_type: 'exercise', item_id: 'e1' },
    { item_type: 'lexeme', item_id: 'w-missing' },
  ],
  lexemes: [
    { id: 'w1', lemma: 'kava', ukrainian_translation: 'кава' },
    { id: 'w2', lemma: 'čaj', ukrainian_translation: null },
  ],
  exercises: [
    { id: 'e1', exercise_type: 'multiple_choice', question_text: 'kava', correct_answer: 'кава', options: ['кава', 'чай'] },
    { id: 'e2', exercise_type: 'translate_to_hr', question_text: 'чай', correct_answer: 'čaj', options: null },
  ],
  conversations: [
    { id: 'c1', title_ua: 'У кафе', title_hr: 'U kafiću', situation: 'cafe' },
    { id: 'c2', title_ua: 'Порожній', title_hr: null, situation: null },
  ],
  turns: [
    { id: 't1', conversation_id: 'c1', speaker_name: 'Daša', hr_text: 'Jednu kavu, molim.', ua_translation: 'Одну каву, будь ласка.' },
    { id: 't2', conversation_id: 'c1', speaker_name: 'Konobar', hr_text: 'Izvolite.', ua_translation: 'Прошу.' },
  ],
  grammar: [
    {
      id: 'g1',
      title_ua: 'Знахідний відмінок',
      rules: [
        { id: 'r2', title_ua: 'Друге', explanation_ua: '…', pattern_hr: null, examples: null as unknown as [], order_index: 2 },
        { id: 'r1', title_ua: 'Перше', explanation_ua: '…', examples: [{ hr: 'Jednu kavu.', ua: 'Одну каву.' }, { hr: 1 } as never], order_index: 1 },
      ],
    },
  ],
  errors: [
    { id: 'x1', code: 'B', category: 'grammar', cefr: 'A0', title_ua: 'Тема', incorrect_text: 'a', correct_text: 'b', explanation_ua: '…', examples: 'bad', grammar_topic_id: 'g1', lexeme_id: null },
    { id: 'x2', code: 'A', category: 'false_friends', cefr: 'A0', title_ua: 'Слово', incorrect_text: 'a', correct_text: 'b', explanation_ua: '…', examples: [{ hr: 'Kava.', ua: 'Кава.' }], grammar_topic_id: null, lexeme_id: 'w1' },
    { id: 'x3', code: 'C', category: 'grammar', cefr: 'A0', title_ua: 'Ще', incorrect_text: 'a', correct_text: 'b', explanation_ua: '…', examples: [], grammar_topic_id: 'g1', lexeme_id: null },
  ],
});

test('lessonItemIds: id за типом у порядку lesson_items', () => {
  assert.deepEqual(lessonItemIds(rows().items), {
    lexemeIds: ['w2', 'w1', 'w-missing'],
    exerciseIds: ['e2', 'e1'],
    grammarIds: ['g1'],
  });
});

test('pitfallsFilter: граматика й слова; без них — null', () => {
  assert.equal(pitfallsFilter({ grammarIds: ['g1'], lexemeIds: ['w1', 'w2'] }), 'grammar_topic_id.in.(g1),lexeme_id.in.(w1,w2)');
  assert.equal(pitfallsFilter({ grammarIds: [], lexemeIds: ['w1'] }), 'lexeme_id.in.(w1)');
  assert.equal(pitfallsFilter({ grammarIds: [], lexemeIds: [] }), null);
});

test('inOrder: порядок уроку, відсутні рядки пропускаємо', () => {
  assert.deepEqual(inOrder(['b', 'x', 'a'], [{ id: 'a' }, { id: 'b' }]), [{ id: 'b' }, { id: 'a' }]);
  assert.deepEqual(inOrder(['a'], null), []);
});

test('buildLessonContent: урок, слова й вправи в порядку уроку', () => {
  const c = buildLessonContent(rows());
  assert.deepEqual(c.lesson, {
    id: 'L1', title_ua: 'Кафе', title_hr: 'U kafiću', level_code: 'A0', objectives: ['Замовити каву'], estimated_minutes: 15,
  });
  assert.deepEqual(c.words, [
    { id: 'w2', hr_text: 'čaj', ua_translation: '' },
    { id: 'w1', hr_text: 'kava', ua_translation: 'кава' },
  ]);
  assert.deepEqual(c.exercises.map((e) => e.id), ['e2', 'e1']);
});

test('buildLessonContent: діалоги без реплік не показуємо, репліки без conversation_id', () => {
  const c = buildLessonContent(rows());
  assert.equal(c.dialogues.length, 1);
  assert.deepEqual(c.dialogues[0].lines.map((l) => l.speaker_name), ['Daša', 'Konobar']);
  assert.equal('conversation_id' in c.dialogues[0].lines[0], false);
});

test('buildLessonContent: правила граматики за order_index, хибні приклади відкидаємо', () => {
  const [topic] = buildLessonContent(rows()).grammar;
  assert.deepEqual(topic.rules.map((r) => r.id), ['r1', 'r2']);
  assert.deepEqual(topic.rules[0].examples, [{ hr: 'Jednu kavu.', ua: 'Одну каву.' }]);
  assert.deepEqual(topic.rules[1].examples, []);
});

test('buildLessonContent: типові помилки — спершу слова, потім граматика, не більше двох', () => {
  const c = buildLessonContent(rows());
  assert.deepEqual(c.pitfalls?.map((p) => p.id), ['x2', 'x1']);
  assert.deepEqual(c.pitfalls?.[1].examples, []);
});

test('buildLessonContent: порожній урок — без падіння, назва за замовчуванням', () => {
  const c = buildLessonContent({
    ...rows(),
    lesson: { id: 'L2', title_ua: null, title_hr: null, level_code: null, objectives: null, estimated_minutes: '15' },
    items: [], lexemes: [], exercises: [], conversations: [], turns: [], grammar: [], errors: [],
  });
  assert.equal(c.lesson.title_ua, 'Урок');
  assert.equal(c.lesson.estimated_minutes, null);
  assert.deepEqual([c.words, c.dialogues, c.grammar, c.exercises, c.pitfalls], [[], [], [], [], []]);
});

test('isLessonContent: свіжий вміст — так; старий кеш і сміття — ні', () => {
  assert.equal(isLessonContent(buildLessonContent(rows())), true);
  assert.equal(isLessonContent({ ...buildLessonContent(rows()), pitfalls: undefined }), true);
  assert.equal(isLessonContent({ id: 'L1', title: 'Кафе', lines: [], topicWords: [] }), false);
  assert.equal(isLessonContent({ lesson: { id: 'L1', title_ua: 'Кафе' }, words: [], dialogues: [], grammar: [] }), false);
  assert.equal(isLessonContent(null), false);
  assert.equal(isLessonContent('урок'), false);
});
