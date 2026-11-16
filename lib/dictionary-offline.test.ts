import assert from 'node:assert/strict';
import { test } from 'node:test';
import { OFFLINE_RESULTS_LIMIT, collectOfflineWords, searchOfflineWords, type OfflineSearch } from './dictionary-offline.ts';
import { offlineKey, saveOfflineCopy, type KeyValueStorage } from './offline-copy.ts';

const USER = '11111111-1111-4111-8111-111111111111';
const OTHER = '22222222-2222-4222-8222-222222222222';
const id = (n: number) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;

function memoryStorage(initial: Record<string, string> = {}): KeyValueStorage {
  const m = new Map(Object.entries(initial));
  return {
    get length() { return m.size; },
    key: (i) => [...m.keys()][i] ?? null,
    getItem: (k) => m.get(k) ?? null,
    setItem: (k, v) => void m.set(k, v),
    removeItem: (k) => void m.delete(k),
  };
}

function lesson(lessonId: string, level: string, words: { id: string; hr_text: string; ua_translation: string; labels?: unknown }[]) {
  return { lesson: { id: lessonId, title_ua: 'Урок', title_hr: null, level_code: level, objectives: null, estimated_minutes: 15 }, words, dialogues: [], grammar: [], exercises: [] };
}

const srs = { easeFactor: 2.5, intervalDays: 1, repetitionCount: 1, lapses: 0 };
function deck(userId: string, cards: { id: string; hr_text: string; ua_translation: string; example?: string }[], cefr = 'A1') {
  return { userId, entries: cards.map((card) => ({ card, cefr, dueAt: 0, srs })), learningCount: cards.length, dueOutside: 0 };
}

function phone() {
  const st = memoryStorage();
  saveOfflineCopy(st, offlineKey('lesson', id(900)), lesson(id(900), 'A0', [
    { id: id(1), hr_text: 'mačka', ua_translation: 'кішка' },
    { id: id(2), hr_text: 'pas', ua_translation: 'собака; пес' },
    { id: id(3), hr_text: 'ćao', ua_translation: 'привіт; бувай', labels: { register: 'informal', regionality: 'general', usage_tags: ['italianism'] } },
  ]));
  saveOfflineCopy(st, offlineKey('lesson', id(901)), lesson(id(901), 'A1', [
    { id: id(2), hr_text: 'pas', ua_translation: 'собака; пес' }, // те саме слово в іншому уроці — один запис
    { id: id(4), hr_text: 'kolodvor', ua_translation: 'вокзал' },
    { id: id(5), hr_text: 'jebiga', ua_translation: 'нічого не вдієш (грубо)', labels: { register: 'vulgar', regionality: 'general', usage_tags: [] } },
  ]));
  saveOfflineCopy(st, offlineKey('trainer', USER), deck(USER, [
    { id: id(4), hr_text: 'kolodvor', ua_translation: 'вокзал', example: 'Gdje je kolodvor?' },
    { id: id(6), hr_text: 'đak', ua_translation: 'учень' },
  ]));
  saveOfflineCopy(st, offlineKey('trainer', OTHER), deck(OTHER, [{ id: id(7), hr_text: 'tajna', ua_translation: 'таємниця' }]));
  st.setItem(offlineKey('lesson', 'зламаний'), 'не json');
  st.setItem('cs_trainer_prefs_v2', '{}');
  return st;
}

const all: OfflineSearch = { term: null, level: 'ALL', category: 'all', adultContent: false };

test('слова з відкритих уроків і колоди тренажера свого акаунта, без повторів', () => {
  const words = collectOfflineWords(phone(), USER);
  assert.deepEqual(words.map((w) => w.lemma).sort(), ['jebiga', 'kolodvor', 'mačka', 'pas', 'ćao', 'đak'].sort());
  const kolodvor = words.find((w) => w.lemma === 'kolodvor');
  assert.equal(kolodvor?.learning, true, 'з тренажера — «Вчу»');
  assert.equal(kolodvor?.example, 'Gdje je kolodvor?');
  assert.equal(words.find((w) => w.lemma === 'pas')?.learning, false);
  assert.equal(words.find((w) => w.lemma === 'ćao')?.labels.register, 'informal', 'мітки з уроку');
  assert.ok(!words.some((w) => w.lemma === 'tajna'), 'колода іншого акаунта не потрапляє');
});

test('без акаунта — лише уроки; немає сховища — порожньо', () => {
  assert.ok(!collectOfflineWords(phone(), null).some((w) => w.lemma === 'đak'));
  assert.deepEqual(collectOfflineWords(null, USER), []);
});

test('пошук: лема, без діакритики, переклад; порядок A0 → A1, далі за абеткою', () => {
  const words = collectOfflineWords(phone(), USER);
  const lemmas = (q: Partial<OfflineSearch>) => searchOfflineWords(words, { ...all, ...q }).map((w) => w.lemma);
  assert.deepEqual(lemmas({ term: 'mačk' }), ['mačka']);
  assert.deepEqual(lemmas({ term: 'macka' }), ['mačka'], 'без діакритики');
  assert.deepEqual(lemmas({ term: 'dak' }), ['đak']);
  assert.deepEqual(lemmas({ term: 'Вокзал' }), ['kolodvor'], 'переклад, без регістру');
  assert.deepEqual(lemmas({ term: 'пес' }), ['pas'], 'друге значення перекладу');
  assert.deepEqual(lemmas({ term: 'ca_o' }), ['ćao'], 'апостроф із пошуку (_) не заважає');
  assert.deepEqual(lemmas({}), ['ćao', 'mačka', 'pas', 'đak', 'kolodvor'], 'vulgar — приховано; A0 спершу; за хорватською абеткою (đ перед k)');
});

test('фільтри рівня, категорії й 18+', () => {
  const words = collectOfflineWords(phone(), USER);
  const lemmas = (q: Partial<OfflineSearch>) => searchOfflineWords(words, { ...all, ...q }).map((w) => w.lemma);
  assert.deepEqual(lemmas({ level: 'A1' }), ['đak', 'kolodvor']);
  assert.deepEqual(lemmas({ category: 'informal' }), ['ćao']);
  assert.deepEqual(lemmas({ category: 'loanword' }), ['ćao']);
  assert.ok(lemmas({ adultContent: true }).includes('jebiga'), 'з перемикачем 18+');
  assert.deepEqual(lemmas({ term: 'xyz' }), []);
});

test(`не більше ${OFFLINE_RESULTS_LIMIT} результатів`, () => {
  const many = Array.from({ length: OFFLINE_RESULTS_LIMIT + 50 }, (_, i) => ({
    id: id(i + 1000), lemma: `riječ${i}`, translation: 'слово', level: 'A1', example: null,
    labels: { register: 'standard' as const, regionality: 'general' as const, usage_tags: [] }, learning: false,
  }));
  assert.equal(searchOfflineWords(many, all).length, OFFLINE_RESULTS_LIMIT);
});
