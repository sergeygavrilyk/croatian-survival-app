import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  assessmentSlug, attemptMeta, displayOrder, gradeItem, isLevelAssessmentSlug, kindTitle, levelStatus, mistakesToSave, nextLevel, percent,
  pickAssessmentLevel, scoreAssessment, summarizeAttempts, type GradableItem, type ItemResponse,
} from './assessment.ts';

const mc = (id: string, area: string, correct = 1, lesson: string | null = null): GradableItem => ({
  id, item_type: 'multiple_choice', area, options: ['a', 'b', 'c'], correct_index: correct, answer_text: null, lesson_id: lesson,
});
const typed = (id: string, answer: string): GradableItem => ({
  id, item_type: 'type_answer', area: 'produce', options: [], correct_index: null, answer_text: answer,
});
const build = (id: string, answer: string, area = 'produce'): GradableItem => ({
  id, item_type: 'sentence_builder', area, options: answer.split(' '), correct_index: null, answer_text: answer,
});
const speak = (id: string, answer: string): GradableItem => ({
  id, item_type: 'speaking', area: 'produce', options: [], correct_index: null, answer_text: answer,
});

test('gradeItem: вибір — правильний індекс, поза межами чи без відповіді — неправильно', () => {
  assert.equal(gradeItem(mc('1', 'understand'), { item_id: '1', choice: 1 }).correct, true);
  assert.equal(gradeItem(mc('1', 'understand'), { item_id: '1', choice: 0 }).given, 'a');
  assert.equal(gradeItem(mc('1', 'understand'), { item_id: '1', choice: 7 }).verdict, 'no_answer');
  assert.equal(gradeItem(mc('1', 'understand'), { item_id: '1', choice: 1.5 }).correct, false);
  assert.equal(gradeItem(mc('1', 'understand'), undefined).correct, false);
});

test('gradeItem: «напишіть» — без діакритики й з одруківкою зараховано, порожнє — без відповіді', () => {
  assert.equal(gradeItem(typed('t', 'naručiti'), { item_id: 't', text: 'narucit' }).correct, true);
  assert.equal(gradeItem(typed('t', 'naručiti'), { item_id: 't', text: 'naruciti' }).verdict, 'diacritics');
  assert.equal(gradeItem(typed('t', 'naručiti'), { item_id: 't', text: 'platiti' }).correct, false);
  assert.equal(gradeItem(typed('t', 'naručiti'), { item_id: 't', text: '  ' }).verdict, 'no_answer');
});

test('gradeItem: «складіть» — регістр і розділові знаки не важать, порядок слів важить', () => {
  const item = build('b', 'Samo račun, molim.');
  assert.equal(gradeItem(item, { item_id: 'b', text: 'samo račun molim' }).correct, true);
  assert.equal(gradeItem(item, { item_id: 'b', text: 'molim račun samo' }).correct, false);
});

test('gradeItem: говоріння — пропуск і «нічого не почули» не рахуються, розпізнане — оцінюється сервером', () => {
  const item = speak('s', 'Želim ribu i salatu.');
  assert.equal(gradeItem(item, { item_id: 's', skipped: true }).skipped, true);
  assert.equal(gradeItem(item, undefined).skipped, true);
  assert.equal(gradeItem(item, { item_id: 's', transcripts: [''] }).skipped, true);
  const ok = gradeItem(item, { item_id: 's', transcripts: ['želim ribu i salatu'] });
  assert.equal(ok.correct, true);
  assert.equal(ok.skipped, false);
  assert.equal(gradeItem(item, { item_id: 's', transcripts: ['dobar dan kako ste'] }).correct, false);
});

test('gradeItem: пропуск не-говоріння — це неправильна відповідь', () => {
  const g = gradeItem(typed('t', 'kava'), { item_id: 't', skipped: true });
  assert.equal(g.skipped, false);
  assert.equal(g.correct, false);
});

test('scoreAssessment: ≥ 70 % і ≥ 50 % у кожній навичці — пройдено', () => {
  const items = [mc('u1', 'understand'), mc('u2', 'understand'), mc('i1', 'interact'), mc('i2', 'interact'), mc('m1', 'mediate'), mc('m2', 'mediate'), typed('p1', 'kava'), typed('p2', 'voda'), build('p3', 'Dobar dan.'), mc('u3', 'understand')];
  const responses: ItemResponse[] = [
    { item_id: 'u1', choice: 1 }, { item_id: 'u2', choice: 1 }, { item_id: 'u3', choice: 0 },
    { item_id: 'i1', choice: 1 }, { item_id: 'i2', choice: 0 },
    { item_id: 'm1', choice: 1 }, { item_id: 'm2', choice: 1 },
    { item_id: 'p1', text: 'kava' }, { item_id: 'p2', text: 'voda' }, { item_id: 'p3', text: 'Dobar dan' },
  ];
  const r = scoreAssessment(items, responses);
  assert.equal(r.correct, 8);
  assert.equal(r.total, 10);
  assert.equal(r.score, 0.8);
  assert.equal(r.passed, true);
  assert.deepEqual(r.weakAreas, []);
  assert.deepEqual(r.areaScores.interact, { correct: 1, total: 2, skipped: 0 });
});

test('scoreAssessment: високий бал, але навичка нижче 50 % — не пройдено', () => {
  const items = [mc('u1', 'understand'), mc('u2', 'understand'), mc('u3', 'understand'), mc('u4', 'understand'), mc('u5', 'understand'), mc('u6', 'understand'), mc('u7', 'understand'), mc('u8', 'understand'), mc('i1', 'interact'), mc('i2', 'interact'), mc('i3', 'interact')];
  const responses = items.map((i) => ({ item_id: i.id, choice: i.area === 'interact' && i.id !== 'i1' ? 0 : 1 }));
  const r = scoreAssessment(items, responses);
  assert.ok(r.score >= 0.7, `score ${r.score}`);
  assert.equal(r.passed, false);
  assert.deepEqual(r.weakAreas, ['interact']);
});

test('scoreAssessment: рівно 70 % — пройдено (без похибок округлення)', () => {
  const items = Array.from({ length: 10 }, (_, i) => mc(`x${i}`, 'understand'));
  const responses = items.map((it, i) => ({ item_id: it.id, choice: i < 7 ? 1 : 0 }));
  assert.equal(scoreAssessment(items, responses).passed, true);
  const six = items.map((it, i) => ({ item_id: it.id, choice: i < 6 ? 1 : 0 }));
  assert.equal(scoreAssessment(items, six).passed, false);
});

test('scoreAssessment: пропущене говоріння не знижує бал; власний поріг тесту', () => {
  const items = [typed('p1', 'kava'), speak('s1', 'Hvala lijepa.'), mc('u1', 'understand')];
  const r = scoreAssessment(items, [{ item_id: 'p1', text: 'kava' }, { item_id: 's1', skipped: true }, { item_id: 'u1', choice: 1 }], { passRatio: '0.9' });
  assert.equal(r.total, 2);
  assert.equal(r.score, 1);
  assert.equal(r.areaScores.produce.skipped, 1);
  assert.equal(r.passed, true);
});

test('scoreAssessment: усе пропущено — не пройдено; дублікати й чужі відповіді ігноруються', () => {
  assert.equal(scoreAssessment([speak('s1', 'Bok, kako si?')], [{ item_id: 's1', skipped: true }]).passed, false);
  const r = scoreAssessment([mc('a', 'understand')], [{ item_id: 'a', choice: 1 }, { item_id: 'a', choice: 0 }, { item_id: 'zzz', choice: 1 }]);
  assert.equal(r.correct, 1);
  assert.equal(r.total, 1);
});

test('scoreAssessment: уроки для повторення — від найбільшої кількості помилок', () => {
  const items = [mc('a', 'understand', 1, 'L1'), mc('b', 'understand', 1, 'L2'), mc('c', 'understand', 1, 'L2'), mc('d', 'understand', 1, 'L3')];
  const r = scoreAssessment(items, [{ item_id: 'a', choice: 0 }, { item_id: 'b', choice: 0 }, { item_id: 'c', choice: 0 }, { item_id: 'd', choice: 1 }]);
  assert.deepEqual(r.lessonsToReview, ['L2', 'L1']);
});

test('mistakesToSave: лише хорватські фрази з ≥ 2 слів; пропуск і правильні — ні', () => {
  const items: GradableItem[] = [
    build('b', 'Samo račun, molim.'),
    typed('t', 'kava'),
    { id: 'r', item_type: 'multiple_choice', area: 'interact', options: ['Hvala, i Vama!', 'Laku noć.'], correct_index: 0, answer_text: null },
    { id: 'u', item_type: 'multiple_choice', area: 'understand', options: ['Добрий день', 'Дякую'], correct_index: 0, answer_text: null },
    speak('s', 'Mogu li dobiti jelovnik?'),
  ];
  const r = scoreAssessment(items, [
    { item_id: 'b', text: 'molim Samo račun' },
    { item_id: 't', text: 'voda' },
    { item_id: 'r', choice: 1 },
    { item_id: 'u', choice: 1 },
    { item_id: 's', skipped: true },
  ]);
  const saved = mistakesToSave(items, r.graded);
  assert.deepEqual(saved.map((s) => s.item_id), ['b', 'r']);
  assert.equal(saved[0].error_type, 'word_order');
  assert.equal(saved[0].original, 'molim Samo račun');
  assert.equal(saved[1].original, 'Laku noć.');
  assert.equal(saved[1].corrected, 'Hvala, i Vama!');
});

test('mistakesToSave: без хорватської відповіді користувача — прочерк', () => {
  const items = [build('b', 'Dobar dan, gospodine!')];
  const r = scoreAssessment(items, []);
  assert.equal(mistakesToSave(items, r.graded)[0].original, '—');
});

test('attemptMeta / nextLevel: фінал пройдено — наступний рівень; оцінка застосунку', () => {
  assert.deepEqual(attemptMeta('final', 'A0', { passed: true, total: 30 }), { estimated_cefr: 'A0', confidence: 'high', recommended_start: 'A1' });
  assert.deepEqual(attemptMeta('module', 'A1', { passed: true, total: 10 }), { estimated_cefr: 'A1', confidence: 'medium', recommended_start: 'A1' });
  assert.equal(attemptMeta('final', 'A1', { passed: false, total: 5 }).recommended_start, 'A1');
  assert.equal(nextLevel('B2'), null);
  assert.equal(nextLevel('A1'), 'A2');
});

test('адреси й назви тестів', () => {
  assert.equal(assessmentSlug('A0', 'module', 3), 'a0-m03');
  assert.equal(assessmentSlug('A1', 'final'), 'a1-final');
  assert.ok(isLevelAssessmentSlug('a1-mid'));
  assert.ok(isLevelAssessmentSlug('a0-m10'));
  assert.ok(!isLevelAssessmentSlug('placement-v1'));
  assert.ok(!isLevelAssessmentSlug('a0-m1; drop'));
  assert.equal(kindTitle('module', 'A0', 3), 'Перевірка модуля A0.3');
  assert.equal(kindTitle('final', 'A1'), 'Фінальна перевірка рівня A1');
});

test('summarizeAttempts: найкращий бал, пройдено хоч раз, остання спроба', () => {
  const s = summarizeAttempts([
    { assessment_id: 'a', score: '0.6', passed: false, completed_at: '2026-10-14T10:00:00Z' },
    { assessment_id: 'a', score: 0.8, passed: true, completed_at: '2026-10-15T10:00:00Z' },
    { assessment_id: 'a', score: 0.5, passed: false, completed_at: '2026-10-16T10:00:00Z' },
  ]).get('a');
  assert.deepEqual(s, { attempts: 3, bestScore: 0.8, passed: true, lastAt: '2026-10-16T10:00:00Z' });
  assert.equal(percent(0.666), 67);
  assert.equal(percent(null), 0);
});

test('список перевірок: порядок модуль 1–5 → середина → 6–10 → фінал; вибір рівня', () => {
  const list = [
    { kind: 'final', order: 100 }, { kind: 'module', order: 6 }, { kind: 'mid', order: 50 }, { kind: 'module', order: 5 }, { kind: 'module', order: 1 },
  ].sort((a, b) => displayOrder(a.kind, a.order) - displayOrder(b.kind, b.order));
  assert.deepEqual(list.map((x) => `${x.kind}${x.order}`), ['module1', 'module5', 'mid50', 'module6', 'final100']);
  assert.equal(pickAssessmentLevel('A1', 'A0', ['A0', 'A1']), 'A1');
  assert.equal(pickAssessmentLevel('B2', 'A1', ['A0', 'A1']), 'A1');
  assert.equal(pickAssessmentLevel(undefined, 'A2', ['A0', 'A1']), 'A0');
  assert.equal(pickAssessmentLevel(undefined, null, []), null);
});

test('levelStatus: скільки пройдено, середина й фінал', () => {
  const tests = [{ id: 'm1', kind: 'module' }, { id: 'mid', kind: 'mid' }, { id: 'fin', kind: 'final' }];
  const sums = summarizeAttempts([
    { assessment_id: 'm1', score: 0.9, passed: true, completed_at: '2026-10-15T10:00:00Z' },
    { assessment_id: 'fin', score: 0.6, passed: false, completed_at: '2026-10-15T11:00:00Z' },
  ]);
  assert.deepEqual(levelStatus(tests, sums), { total: 3, passed: 1, midPassed: false, finalPassed: false });
  const sums2 = summarizeAttempts([{ assessment_id: 'fin', score: 0.8, passed: true, completed_at: '2026-10-15T12:00:00Z' }]);
  assert.equal(levelStatus(tests, sums2).finalPassed, true);
});
