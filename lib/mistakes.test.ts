import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  answerTiles, checkSentence, distractorTiles, DONE_MARK_MAX_AGE_MS, doneMarksKey, hiddenMistakeIds, isDue, markMistakeDone,
  MASTERY_STREAK, parseDoneMarks, scheduleMistake, shuffleTiles,
} from './mistakes.ts';

test('помилки: порівняння без регістру й розділових знаків, діакритики окремо', () => {
  assert.equal(checkSentence('jednu kavu molim', 'Jednu kavu, molim.'), 'exact');
  assert.equal(checkSentence('Zelim cevapcice', 'Želim ćevapčiće.'), 'diacritics');
  assert.equal(checkSentence('jedna kava molim', 'Jednu kavu, molim.'), 'wrong');
  assert.equal(checkSentence('  ', 'Da.'), 'wrong');
});

test('помилки: плитки — слова відповіді й пастки зі сказаного користувачем', () => {
  assert.deepEqual(answerTiles('Jednu kavu, molim.'), ['Jednu', 'kavu,', 'molim.']);
  assert.deepEqual(distractorTiles('jedna kava molim', 'Jednu kavu, molim.'), ['jedna', 'kava']);
  assert.deepEqual(distractorTiles('tak dobro', 'Da, molim.'), ['tak', 'dobro']);
  assert.deepEqual(distractorTiles('Molim molim', 'Molim.'), []);
  assert.equal(distractorTiles('a b c d e f', 'x').length, 3);
});

test('помилки: перемішування не губить і не дублює плитки', () => {
  let seed = 1;
  const rnd = () => ((seed = (seed * 16807) % 2147483647) / 2147483647);
  const tiles = ['a', 'b', 'c', 'd'];
  assert.deepEqual(shuffleTiles(tiles, rnd).sort(), tiles);
});

test('помилки: засвоєно після двох правильних відповідей у різні дні', () => {
  const now = new Date('2026-10-13T10:00:00');
  const first = scheduleMistake({ correctStreak: 0, reviewCount: 0 }, true, now);
  assert.equal(first.correctStreak, 1);
  assert.equal(first.resolvedAt, null);
  assert.equal(first.nextReviewAt.getDate(), 14);
  assert.equal(first.nextReviewAt.getHours(), 0);
  const second = scheduleMistake(first, true, new Date('2026-10-14T09:00:00'));
  assert.equal(second.correctStreak, MASTERY_STREAK);
  assert.ok(second.resolvedAt);
  assert.equal(second.reviewCount, 2);
});

test('помилки: неправильна відповідь скидає серію і повертає помилку сьогодні', () => {
  const now = new Date('2026-10-13T10:00:00');
  const s = scheduleMistake({ correctStreak: 1, reviewCount: 3 }, false, now);
  assert.equal(s.correctStreak, 0);
  assert.equal(s.reviewCount, 4);
  assert.equal(s.nextReviewAt.getTime(), now.getTime());
  assert.equal(s.resolvedAt, null);
});

test('помилки: що чекає повторення', () => {
  const now = new Date('2026-10-13T10:00:00Z');
  assert.equal(isDue({ resolved_at: null, next_review_at: null }, now), true);
  assert.equal(isDue({ resolved_at: null, next_review_at: '2026-10-13T09:00:00Z' }, now), true);
  assert.equal(isDue({ resolved_at: null, next_review_at: '2026-10-14T00:00:00Z' }, now), false);
  assert.equal(isDue({ resolved_at: '2026-10-12T00:00:00Z', next_review_at: null }, now), false);
});

// ---------------------------------------------------------------- без мережі (2026-11-16)

function memoryStorage(initial: Record<string, string> = {}, broken = false) {
  const data = new Map(Object.entries(initial));
  return {
    data,
    getItem: (k: string) => { if (broken) throw new Error('недоступно'); return data.get(k) ?? null; },
    setItem: (k: string, v: string) => { if (broken) throw new Error('недоступно'); data.set(k, v); },
  };
}

const UID = 'a0000000-0000-4000-8000-0000000000a1';
const ERR1 = 'e0000000-0000-4000-8000-000000000001';
const ERR2 = 'e0000000-0000-4000-8000-000000000002';
const T = Date.parse('2026-11-16T12:00:00Z');

test('помилки без мережі: виправлену після збирання сторінки — ховаємо; свіжа сторінка — показує', () => {
  const st = memoryStorage();
  assert.equal(markMistakeDone(st, UID, ERR1, T), true);
  const raw = st.getItem(doneMarksKey(UID));
  assert.deepEqual([...hiddenMistakeIds(raw, T - 60_000)], [ERR1], 'сторінку з кешу зібрано раніше — сховати');
  assert.equal(hiddenMistakeIds(raw, T + 60_000).size, 0, 'сторінку зібрано пізніше — показуємо, як каже сервер');
  assert.equal(hiddenMistakeIds(raw, NaN).size, 0);
});

test('помилки без мережі: позначки — свої в кожного акаунта, старші за 14 днів прибираються, пошкоджені не ламають', () => {
  const st = memoryStorage({ [doneMarksKey(UID)]: JSON.stringify({ [ERR1]: T - DONE_MARK_MAX_AGE_MS - 1, x: 'не число' }) });
  markMistakeDone(st, UID, ERR2, T);
  assert.deepEqual(parseDoneMarks(st.getItem(doneMarksKey(UID))), { [ERR2]: T });
  assert.notEqual(doneMarksKey(UID), doneMarksKey(ERR1));
  assert.deepEqual(parseDoneMarks('{зламано'), {});
  assert.deepEqual(parseDoneMarks('[1,2]'), {});
  assert.equal(markMistakeDone(memoryStorage({}, true), UID, ERR1, T), false, 'сховище недоступне — без падіння');
  assert.equal(markMistakeDone(null, UID, ERR1, T), false);
  assert.equal(markMistakeDone(st, null, ERR1, T), false);
  // не більше 300
  const many = memoryStorage();
  for (let i = 0; i < 310; i++) markMistakeDone(many, UID, `id${i}`, T + i);
  const kept = parseDoneMarks(many.getItem(doneMarksKey(UID)));
  assert.equal(Object.keys(kept).length, 300);
  assert.ok(kept.id309 && !kept.id0, 'лишаються найновіші');
});
