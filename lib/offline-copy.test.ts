import { test } from 'node:test';
import assert from 'node:assert/strict';
import { offlineKey, purgeLegacyCache, readOfflineCopy, saveOfflineCopy, type KeyValueStorage } from './offline-copy.ts';

function memoryStorage(initial: Record<string, string> = {}): KeyValueStorage & { map: Map<string, string> } {
  const map = new Map(Object.entries(initial));
  return {
    map,
    get length() {
      return map.size;
    },
    key: (i) => [...map.keys()][i] ?? null,
    getItem: (k) => map.get(k) ?? null,
    setItem: (k, v) => void map.set(k, String(v)),
    removeItem: (k) => void map.delete(k),
  };
}

const isWords = (v: unknown): v is { words: string[] } =>
  !!v && typeof v === 'object' && Array.isArray((v as { words?: unknown }).words);

test('offlineKey: окремі ключі для уроку й тексту, без версії', () => {
  assert.equal(offlineKey('lesson', 'abc'), 'cs_offline_lesson_abc');
  assert.equal(offlineKey('reading', 'abc'), 'cs_offline_reading_abc');
});

test('saveOfflineCopy → readOfflineCopy: та сама копія й час збереження', () => {
  const s = memoryStorage();
  assert.equal(saveOfflineCopy(s, 'k', { words: ['kava'] }, 1000), true);
  assert.deepEqual(readOfflineCopy(s, 'k', isWords), { data: { words: ['kava'] }, savedAt: 1000 });
});

test('нове збереження перезаписує стару копію (свіжі дані без зміни версії)', () => {
  const s = memoryStorage();
  saveOfflineCopy(s, 'k', { words: ['kava'] }, 1);
  saveOfflineCopy(s, 'k', { words: ['kava', 'čaj'] }, 2);
  assert.deepEqual(readOfflineCopy(s, 'k', isWords)?.data.words, ['kava', 'čaj']);
});

test('readOfflineCopy: немає, пошкоджена, чужий формат або не пройшла перевірку → null', () => {
  const s = memoryStorage({
    broken: '{not json',
    oldFormat: JSON.stringify({ cachedAt: 1, lesson: {} }),
    wrongShape: JSON.stringify({ f: 1, savedAt: 1, data: { words: 'kava' } }),
  });
  assert.equal(readOfflineCopy(s, 'missing', isWords), null);
  assert.equal(readOfflineCopy(s, 'broken', isWords), null);
  assert.equal(readOfflineCopy(s, 'oldFormat', isWords), null);
  assert.equal(readOfflineCopy(s, 'wrongShape', isWords), null);
  assert.equal(readOfflineCopy(null, 'k', isWords), null);
});

test('збій сховища не ламає сторінку', () => {
  const s = memoryStorage();
  s.setItem = () => {
    throw new Error('QuotaExceededError');
  };
  s.getItem = () => {
    throw new Error('SecurityError');
  };
  assert.equal(saveOfflineCopy(s, 'k', { words: [] }), false);
  assert.equal(readOfflineCopy(s, 'k', isWords), null);
  assert.equal(saveOfflineCopy(undefined, 'k', 1), false);
});

test('purgeLegacyCache: прибирає лише старий кеш з ручними версіями', () => {
  const s = memoryStorage({
    cs_lesson_data_v13_abc: '1',
    cs_reading_v9_abc: '1',
    cs_modules_A0_v11: '1',
    cs_units_m1_v11: '1',
    cs_lessons_m1_v11: '1',
    cs_offline_lesson_abc: '1',
    cs_offline_reading_abc: '1',
    cs_trainer_prefs_v2: '1',
    'croatia.mascot': 'pjegica',
  });
  assert.equal(purgeLegacyCache(s), 5);
  assert.deepEqual([...s.map.keys()].sort(), ['croatia.mascot', 'cs_offline_lesson_abc', 'cs_offline_reading_abc', 'cs_trainer_prefs_v2']);
  assert.equal(purgeLegacyCache(s), 0);
  assert.equal(purgeLegacyCache(null), 0);
});
