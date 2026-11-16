import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  MODULE_TEXTS,
  NEXT_LESSONS,
  PLAN_COOLDOWN_HOURS,
  isPlanDue,
  isPrefetchRequest,
  nextLessonIds,
  parsePlanRecord,
  planKey,
  planUrls,
  rememberPlan,
  shouldPrefetch,
  sortModuleLessons,
  type OrderedLesson,
} from './offline-prefetch.ts';

const id = (n: number) => `c0000000-0000-0000-0000-${String(n).padStart(12, '0')}`;

// модуль із двох юнітів; у базі рядки приходять не по порядку
const MODULE: OrderedLesson[] = [
  { id: id(4), unitOrder: 2, order: 1 },
  { id: id(1), unitOrder: 1, order: 1 },
  { id: id(3), unitOrder: 1, order: 3 },
  { id: id(2), unitOrder: 1, order: 2 },
  { id: id(5), unitOrder: 2, order: 2 },
  { id: id(6), unitOrder: 2, order: 3 },
  { id: id(7), unitOrder: 2, order: 4 },
  { id: id(8), unitOrder: 2, order: 5 },
];

test('рішення власника: 5 наступних уроків модуля, до 4 текстів модуля', () => {
  assert.equal(NEXT_LESSONS, 5);
  assert.equal(MODULE_TEXTS, 4);
  assert.equal(PLAN_COOLDOWN_HOURS, 12);
});

test('уроки модуля — за порядком юніту, потім уроку', () => {
  assert.deepEqual(sortModuleLessons(MODULE).map((l) => l.id), [1, 2, 3, 4, 5, 6, 7, 8].map(id));
});

test('наступні уроки: після поточного, не більше 5; кінець модуля — менше; чужий урок — нічого', () => {
  assert.deepEqual(nextLessonIds(MODULE, id(1)), [2, 3, 4, 5, 6].map(id));
  assert.deepEqual(nextLessonIds(MODULE, id(6)), [7, 8].map(id), 'модуль закінчується — далі не йдемо');
  assert.deepEqual(nextLessonIds(MODULE, id(8)), [], 'останній урок модуля');
  assert.deepEqual(nextLessonIds(MODULE, id(99)), [], 'уроку немає в модулі — не вгадуємо');
  assert.deepEqual(nextLessonIds(MODULE, id(3), { limit: 3 }), [4, 5, 6].map(id));
  assert.deepEqual(nextLessonIds(MODULE, id(3), { limit: 0 }), []);
});

test('«Продовжити» на «Сьогодні»: урок, який ще не відкривали, — теж', () => {
  assert.deepEqual(nextLessonIds(MODULE, id(2), { includeCurrent: true }), [2, 3, 4, 5, 6].map(id));
  assert.deepEqual(nextLessonIds(MODULE, id(8), { includeCurrent: true }), [id(8)]);
});

test('адреси: уроки, тексти (≤ 4), список ситуацій і ситуації; без повторів і сміття', () => {
  assert.deepEqual(
    planUrls({ lessonIds: [id(2), id(3), id(2)], textIds: [id(11), id(12)] }),
    [`/lesson/${id(2)}`, `/lesson/${id(3)}`, `/reading/${id(11)}`, `/reading/${id(12)}`],
  );
  assert.equal(planUrls({ textIds: [1, 2, 3, 4, 5, 6].map((n) => id(10 + n)) }).length, 4, 'тексти — не більше 4');
  assert.deepEqual(planUrls({ lessonIds: ['../admin', 'abc', ''], textIds: ['x'] }), [], 'лише справжні id');
  assert.deepEqual(planUrls({ situationCodes: ['pharmacy', 'bank', 'pharmacy', 'Bad Code', '../x'] }), [
    '/situations',
    '/situations/bank',
    '/situations/pharmacy',
  ]);
  assert.deepEqual(planUrls({ situationCodes: [] }), ['/situations']);
  assert.deepEqual(planUrls({}), [], 'ситуації не просили — без них');
});

test('коли зберігати: є мережа, працює service worker, без економії трафіку', () => {
  assert.equal(shouldPrefetch({ online: true, saveData: false, hasController: true }), true);
  assert.equal(shouldPrefetch({ online: false, saveData: false, hasController: true }), false);
  assert.equal(shouldPrefetch({ online: true, saveData: true, hasController: true }), false, 'економія трафіку');
  assert.equal(shouldPrefetch({ online: true, saveData: false, hasController: false }), false, 'перше відкриття — SW ще не керує');
});

test('заголовок запиту: лише точне значення', () => {
  assert.equal(isPrefetchRequest('page'), true);
  assert.equal(isPrefetchRequest('Page'), false);
  assert.equal(isPrefetchRequest(null), false);
  assert.equal(isPrefetchRequest(undefined), false);
});

test('план не повторюється частіше ніж раз на 12 годин; запис обмежений і стійкий до сміття', () => {
  const now = Date.UTC(2026, 10, 16, 12);
  const key = planKey('lesson', id(1), false);
  assert.notEqual(key, planKey('today', id(1), true));
  assert.equal(isPlanDue({}, key, now), true);
  const rec = rememberPlan({}, key, now);
  assert.equal(isPlanDue(rec, key, now + 11 * 3600_000), false);
  assert.equal(isPlanDue(rec, key, now + 12 * 3600_000), true);
  assert.equal(isPlanDue(rec, key, now - 1000), true, 'годинник назад — пора');
  assert.deepEqual(parsePlanRecord(JSON.stringify(rec)), rec);
  for (const bad of [null, '', 'не json', '[1,2]', '"x"', 'null']) assert.deepEqual(parsePlanRecord(bad), {}, String(bad));
  assert.deepEqual(parsePlanRecord('{"a":1,"b":"x","c":null}'), { a: 1 });
  let many = {};
  for (let i = 0; i < 80; i++) many = rememberPlan(many, `k${i}`, now + i);
  assert.equal(Object.keys(many).length, 50, 'лишаємо 50 найновіших');
  assert.ok('k79' in many && !('k0' in many));
});
