import { test } from 'node:test';
import assert from 'node:assert/strict';
import { activeTab, showsBottomNav, TABS } from './navigation.ts';
import { SITUATIONS, situationInfo } from './situations.ts';

test('нижня панель: 5 вкладок у погодженому порядку', () => {
  assert.deepEqual(TABS.map((t) => t.label), ['Сьогодні', 'Уроки', 'Практика', 'Ситуації', 'Профіль']);
});

test('нижня панель показується на екранах вкладок', () => {
  for (const p of ['/', '/lessons', '/trainer', '/dictionary', '/profile', '/situations', '/situations/health', '/lessons/']) {
    assert.equal(showsBottomNav(p), true, p);
  }
});

test('нижня панель схована в уроці, на вході й в адмінці', () => {
  for (const p of ['/lesson/c0000000-0000-0000-0000-000000000001', '/login', '/admin', '/lessonsx', '/trainerx', '/situations/cafe_restaurant/roleplay', '/onboarding']) {
    assert.equal(showsBottomNav(p), false, p);
  }
});

test('активна вкладка: словник належить до «Практики»', () => {
  assert.equal(activeTab('/'), 'today');
  assert.equal(activeTab('/dictionary'), 'practice');
  assert.equal(activeTab('/trainer'), 'practice');
  assert.equal(activeTab('/situations/bank'), 'situations');
  assert.equal(activeTab('/lesson/abc'), null);
  assert.equal(activeTab('/lessonsx'), null);
});

test('ситуації: усі коди з БД мають назву, коди унікальні', () => {
  const dbCodes = ['basics', 'shopping', 'cafe_restaurant', 'transport', 'car_service', 'housing', 'health', 'vet',
    'administration', 'bank', 'border', 'work', 'it_work', 'travel', 'small_talk'];
  for (const code of dbCodes) assert.notEqual(situationInfo(code).label, code, code);
  assert.equal(new Set(SITUATIONS.map((s) => s.code)).size, SITUATIONS.length);
  assert.equal(situationInfo('unknown_x').label, 'unknown_x');
});
