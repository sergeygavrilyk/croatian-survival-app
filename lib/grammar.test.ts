import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  answeredCount,
  exercisesWord,
  buildLevelGrammar,
  grammarLevelHref,
  grammarReviewHref,
  grammarTopicHref,
  lessonsLocative,
  matchesSearch,
  normalizeSearch,
  pickReviewExercises,
  pickTopicExercises,
  rulesWord,
  topicsAlphabetical,
  topicsWord,
  weakTopicIds,
  type GrammarTopicInput,
} from './grammar.ts';

const modules = [
  { id: 'm2', order_index: 2, title_ua: 'Модуль A1.2 — Їжа й кухня', title_hr: null },
  { id: 'm1', order_index: 1, title_ua: 'Модуль A1.1 — Мій день', title_hr: null },
  { id: 'm3', order_index: 3, title_ua: 'Модуль A1.3 — Покупки', title_hr: null },
];
const lessonsByModule = { m1: ['l1', 'l2'], m2: ['l3', 'l4'], m3: ['l5'] };
const topic = (id: string, title_ua: string, extra: Partial<GrammarTopicInput> = {}): GrammarTopicInput => ({
  id,
  title_ua,
  title_hr: null,
  description: null,
  ruleCount: 3,
  ...extra,
});
const topics = [
  topic('genitiv', 'Родовий відмінок', { title_hr: 'Genitiv: osnove' }),
  topic('akuzativ', 'Знахідний відмінок', { title_hr: 'Akuzativ', searchExtra: 'Želim kavu' }),
  topic('prezent', 'Теперішній час', { title_hr: 'Prezent' }),
  topic('futur', 'Майбутній час', { title_hr: 'Futur I: ići ću' }),
  topic('lonely', 'Тема без уроку'),
];
const links = [
  { lesson_id: 'l2', topic_id: 'akuzativ' },
  { lesson_id: 'l1', topic_id: 'prezent' },
  { lesson_id: 'l4', topic_id: 'akuzativ' },
  { lesson_id: 'l3', topic_id: 'genitiv' },
  { lesson_id: 'l5', topic_id: 'futur' },
  { lesson_id: 'other-level', topic_id: 'lonely' },
];

test('buildLevelGrammar: теми в модулі першої появи, у порядку програми', () => {
  const g = buildLevelGrammar({ modules, lessonsByModule, topics, links, completedLessonIds: [] });
  assert.deepEqual(
    g.groups.map((x) => [x.id, x.topics.map((t) => t.id)]),
    [
      ['m1', ['prezent', 'akuzativ']],
      ['m2', ['genitiv']],
      ['m3', ['futur']],
    ],
  );
  assert.deepEqual(g.unlinked.map((t) => t.id), ['lonely']);
  assert.equal(g.total, 5);
  assert.equal(g.groups[0].topics[1].lessonCount, 2);
});

test('buildLevelGrammar: пройдено / зараз / попереду', () => {
  const g = buildLevelGrammar({ modules, lessonsByModule, topics, links, completedLessonIds: ['l1', 'l2'] });
  const state = Object.fromEntries(g.groups.flatMap((x) => x.topics).map((t) => [t.id, t.state]));
  assert.deepEqual(state, { prezent: 'done', akuzativ: 'done', genitiv: 'now', futur: 'next' });
  assert.equal(g.currentModuleId, 'm2');
  assert.deepEqual(g.groups.map((x) => x.state), ['done', 'now', 'next']);
  assert.equal(g.done, 2);
});

test('buildLevelGrammar: тема пройдена, якщо пройдено будь-який її урок', () => {
  const g = buildLevelGrammar({ modules, lessonsByModule, topics, links, completedLessonIds: ['l4'] });
  const akuzativ = g.groups.flatMap((x) => x.topics).find((t) => t.id === 'akuzativ');
  assert.equal(akuzativ?.state, 'done');
  assert.equal(g.currentModuleId, 'm1');
});

test('buildLevelGrammar: усе пройдено — поточного модуля немає; порожні модулі не показуємо', () => {
  const g = buildLevelGrammar({
    modules: [...modules, { id: 'm4', order_index: 4, title_ua: 'Порожній', title_hr: null }],
    lessonsByModule,
    topics,
    links,
    completedLessonIds: ['l1', 'l2', 'l3', 'l4', 'l5'],
  });
  assert.equal(g.currentModuleId, null);
  assert.equal(g.groups.length, 3);
  assert.equal(g.done, 4);
});

test('normalizeSearch і matchesSearch: без діакритик, усі слова запиту', () => {
  assert.equal(normalizeSearch('  Čekam  ĐAKA, ići ću '), 'cekam daka, ici cu');
  const g = buildLevelGrammar({ modules, lessonsByModule, topics, links, completedLessonIds: [] });
  const all = topicsAlphabetical(g);
  assert.deepEqual(all.filter((t) => matchesSearch(t, 'cu')).map((t) => t.id), ['futur']);
  assert.deepEqual(all.filter((t) => matchesSearch(t, 'zelim')).map((t) => t.id), ['akuzativ']);
  assert.deepEqual(all.filter((t) => matchesSearch(t, 'відмінок родовий')).map((t) => t.id), ['genitiv']);
  assert.equal(all.filter((t) => matchesSearch(t, '')).length, 5);
});

test('topicsAlphabetical: за українською абеткою', () => {
  const g = buildLevelGrammar({ modules, lessonsByModule, topics, links, completedLessonIds: [] });
  assert.deepEqual(topicsAlphabetical(g).map((t) => t.title_ua), [
    'Знахідний відмінок',
    'Майбутній час',
    'Родовий відмінок',
    'Тема без уроку',
    'Теперішній час',
  ]);
});

const ex = (id: string, type: string) => ({ id, exercise_type: type, question_text: id, correct_answer: id, options: null });

test('pickTopicExercises: лише вправи на речення, без повторів, «вставити» перед «скласти», стабільно з seed', () => {
  const rows = [
    ex('a', 'sentence_builder'),
    ex('b', 'multiple_choice'),
    ex('c', 'fill_in_the_blank'),
    ex('a', 'sentence_builder'),
    ex('d', 'speaking'),
    ex('e', 'sentence_builder'),
  ];
  const picked = pickTopicExercises(rows, 's1', 10);
  assert.deepEqual(picked.map((x) => x.id).sort(), ['a', 'c', 'e']);
  assert.equal(picked[0].exercise_type, 'fill_in_the_blank');
  assert.deepEqual(pickTopicExercises(rows, 's1', 10), picked);
  assert.equal(pickTopicExercises(rows, 's1', 2).length, 2);
});

test('pickReviewExercises: по черзі з кожної теми, до ліміту, спільна вправа — один раз', () => {
  const byTopic = {
    t1: [ex('a1', 'sentence_builder'), ex('a2', 'sentence_builder'), ex('a3', 'sentence_builder'), ex('shared', 'fill_in_the_blank')],
    t2: [ex('b1', 'sentence_builder'), ex('shared', 'fill_in_the_blank')],
    t3: [ex('c1', 'multiple_choice')],
  };
  const picked = pickReviewExercises(byTopic, ['t1', 't2', 't3'], 'seed', 4);
  assert.equal(picked.length, 4);
  assert.equal(new Set(picked.map((x) => x.id)).size, 4);
  assert.ok(picked.some((x) => x.id === 'b1' || x.id === 'shared'), 'є вправа з другої теми');
  assert.equal(pickReviewExercises(byTopic, ['t3'], 'seed').length, 0);
  assert.equal(pickReviewExercises(byTopic, ['t1', 't2'], 'seed', 50).length, 5);
});

test('weakTopicIds і answeredCount', () => {
  const answers = { a: 'can', b: 'review', d: 'review' } as const;
  assert.deepEqual(weakTopicIds(['a', 'b', 'c', 'd'], answers), ['b', 'd']);
  assert.equal(answeredCount(['a', 'b', 'c'], answers), 2);
});

test('адреси й слова', () => {
  assert.equal(grammarLevelHref('A1'), '/lessons/grammar?level=A1');
  assert.equal(grammarTopicHref('x'), '/lessons/grammar/x');
  assert.equal(grammarReviewHref('B2'), '/lessons/grammar/review?level=B2');
  assert.deepEqual([1, 3, 5, 11, 21, 22, 25].map(topicsWord), ['1 тема', '3 теми', '5 тем', '11 тем', '21 тема', '22 теми', '25 тем']);
  assert.deepEqual([1, 4, 7, 12].map(rulesWord), ['1 правило', '4 правила', '7 правил', '12 правил']);
  assert.deepEqual([1, 2, 10, 15].map(exercisesWord), ['1 вправа', '2 вправи', '10 вправ', '15 вправ']);
  assert.deepEqual([1, 8, 11, 21].map(lessonsLocative), ['1 уроці', '8 уроках', '11 уроках', '21 уроці']);
});
