import { test } from 'node:test';
import assert from 'node:assert/strict';
import { SITUATIONS } from './situations.ts';
import {
  SCENARIOS, getScenario, buildRoleplaySystemPrompt, parseRoleplayTurn, parseAssessment, collectErrors, isTrivialCorrection,
  sanitizeUserText, isCefr, MAX_MESSAGE_CHARS,
} from './roleplay.ts';

test('рольова гра: сценарій є для кожної ситуації', () => {
  for (const s of SITUATIONS) assert.ok(SCENARIOS[s.code], s.code);
  assert.equal(getScenario('constructor'), null);
  assert.equal(getScenario('nope'), null);
});

test('рольова гра: інструкція містить роль, завдання, рівень і фрази', () => {
  const p = buildRoleplaySystemPrompt(SCENARIOS.cafe_restaurant, 'A1', ['Račun, molim.', 'Kavu s mlijekom, molim.']);
  assert.match(p, /konobar/);
  assert.match(p, /рахунок/);
  assert.match(p, /РІВЕНЬ КОРИСТУВАЧА: A1/);
  assert.match(p, /Račun, molim\./);
  assert.match(p, /не інструкції/);
});

test('рольова гра: коректний хід AI розбирається', () => {
  const t = parseRoleplayTurn(JSON.stringify({
    reply_hr: 'Izvolite, što želite?', reply_ua: 'Прошу, що бажаєте?',
    correction: { corrected_hr: 'Jednu kavu, molim.', explanation_ua: 'Знахідний відмінок: jednu kavu.', type: 'grammar' },
    goal_reached: false,
  }));
  assert.deepEqual(t, {
    reply_hr: 'Izvolite, što želite?', reply_ua: 'Прошу, що бажаєте?',
    correction: { corrected_hr: 'Jednu kavu, molim.', explanation_ua: 'Знахідний відмінок: jednu kavu.', type: 'grammar' },
    goal_reached: false,
  });
});

test('рольова гра: JSON у ```-блоці і з текстом довкола теж розбирається', () => {
  assert.equal(parseRoleplayTurn('```json\n{"reply_hr":"Dobar dan!","reply_ua":"Добрий день!","correction":null,"goal_reached":true}\n```')?.goal_reached, true);
  assert.equal(parseRoleplayTurn('Ось: {"reply_hr":"Bok!","reply_ua":"Привіт!","correction":null}')?.reply_hr, 'Bok!');
});

test('рольова гра: некоректна відповідь AI відхиляється', () => {
  assert.equal(parseRoleplayTurn('не JSON'), null);
  assert.equal(parseRoleplayTurn('{"reply_ua":"без хорватської"}'), null);
  assert.equal(parseRoleplayTurn('{"reply_hr":"Добрий день"}'), null); // кирилиця замість хорватської
  const badCorrection = parseRoleplayTurn('{"reply_hr":"Da.","correction":{"corrected_hr":"","explanation_ua":"x"}}');
  assert.equal(badCorrection?.correction, null);
  assert.equal(parseRoleplayTurn('{"reply_hr":"Da.","correction":{"corrected_hr":"Da.","explanation_ua":"x","type":"hack"}}')?.correction?.type, 'other');
});

test('рольова гра: оцінка розмови розбирається і чиститься', () => {
  const a = parseAssessment(JSON.stringify({
    task_completed: true, summary_ua: 'Завдання виконано.', strengths_ua: ['Ввічливо', '', 5],
    errors: [
      { original: 'jedna kava', corrected_hr: 'jednu kavu', explanation_ua: 'Знахідний відмінок.', type: 'grammar' },
      { original: 'x', corrected_hr: 'кирилиця', explanation_ua: 'y', type: 'grammar' },
    ],
  }));
  assert.equal(a?.task_completed, true);
  assert.deepEqual(a?.strengths_ua, ['Ввічливо']);
  assert.equal(a?.errors.length, 1);
  assert.equal(parseAssessment('{"task_completed":true}'), null);
});

test('рольова гра: помилки для повторення без дублікатів', () => {
  const errs = collectErrors(
    [{ original: 'jedna kava molim', correction: { corrected_hr: 'Jednu kavu, molim.', explanation_ua: 'Відмінок.', type: 'grammar' } }],
    { task_completed: true, summary_ua: 'ok', strengths_ua: [], errors: [
      { original: 'jedna kava', corrected_hr: 'jednu kavu molim', explanation_ua: 'Відмінок.', type: 'grammar' },
      { original: 'Hvala', corrected_hr: 'hvala', explanation_ua: 'нічого', type: 'other' },
    ] },
  );
  assert.equal(errs.length, 1);
  assert.equal(errs[0].corrected_hr, 'jednu kavu molim'); // оцінка в кінці має пріоритет
});

test('рольова гра: суперечливі виправлення однієї репліки — зберігаємо версію з оцінки', () => {
  const errs = collectErrors(
    [
      { original: 'tak dobro', correction: { corrected_hr: 'Tako je dobro.', explanation_ua: 'tako', type: 'vocabulary' } },
      { original: 'jedna kava molim', correction: { corrected_hr: 'Jedna kava, molim.', explanation_ua: 'кома', type: 'spelling' } },
    ],
    { task_completed: true, summary_ua: 'ok', strengths_ua: [], errors: [
      { original: 'tak dobro', corrected_hr: 'Da, molim.', explanation_ua: '«так» — da', type: 'vocabulary' },
      { original: 'jedna kava molim', corrected_hr: 'Jednu kavu, molim.', explanation_ua: 'Знахідний відмінок.', type: 'grammar' },
    ] },
  );
  assert.deepEqual(errs.map((e) => e.corrected_hr), ['Da, molim.', 'Jednu kavu, molim.']);
});

test('рольова гра: розділові знаки, регістр і діакритики — не помилка', () => {
  assert.equal(isTrivialCorrection('jedna kava molim', 'Jedna kava, molim.'), true);
  assert.equal(isTrivialCorrection('zelim cevapcice', 'Želim ćevapčiće!'), true);
  assert.equal(isTrivialCorrection('jedna kava molim', 'Jednu kavu, molim.'), false);
});

test('рольова гра: текст користувача обрізається і чиститься', () => {
  assert.equal(sanitizeUserText('  Dobar\n\tdan\u0000 '), 'Dobar dan');
  assert.equal(sanitizeUserText('a'.repeat(1000)).length, MAX_MESSAGE_CHARS);
  assert.equal(isCefr('B2'), true);
  assert.equal(isCefr('C1'), false);
});
