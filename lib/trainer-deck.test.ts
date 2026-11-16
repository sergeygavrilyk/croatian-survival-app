// Тести колоди тренажера без мережі (офлайн, етап 2, 2026-11-16). Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  buildDeck, deckDueCount, deckKey, DECK_SIZE, dueAtFromRow, isTrainerDeck, pickSession, rateInDeck, srsFromRow,
  type DeckEntry, type TrainerDeck,
} from './trainer-deck.ts';
import { scheduleReview, NEW_CARD } from './srs.ts';
import { offlineKey } from './offline-copy.ts';

const USER = 'a0000000-0000-4000-8000-0000000000a1';
const NOW = new Date('2026-11-16T12:00:00Z');
const HOUR = 60 * 60 * 1000;

const id = (n: number) => `00000000-0000-4000-8000-${String(n).padStart(12, '0')}`;

function entry(n: number, dueOffsetMs: number, cefr: string | null = 'A0'): DeckEntry {
  return {
    card: { id: id(n), hr_text: `riječ${n}`, ua_translation: `слово${n}`, level: cefr ?? undefined, theme: null },
    cefr,
    dueAt: NOW.getTime() + dueOffsetMs,
    srs: { ...NEW_CARD },
  };
}

test('рядок user_progress → стан SRS і час повторення (порожнє — типові значення)', () => {
  assert.deepEqual(srsFromRow({ lexeme_id: id(1), next_review_date: null }), NEW_CARD);
  assert.deepEqual(
    srsFromRow({ lexeme_id: id(1), next_review_date: null, ease_factor: 2.7, interval_days: 3, repetition_count: 2, lapses: 1 }),
    { easeFactor: 2.7, intervalDays: 3, repetitionCount: 2, lapses: 1 },
  );
  assert.equal(dueAtFromRow({ next_review_date: null }), 0);
  assert.equal(dueAtFromRow({ next_review_date: 'не дата' }), 0);
  assert.equal(dueAtFromRow({ next_review_date: NOW.toISOString() }), NOW.getTime());
});

test('колода: спершу ті, що чекають найдовше; у копії — перші 150, решта — лічильники', () => {
  const all = Array.from({ length: DECK_SIZE + 20 }, (_, i) => entry(i + 1, (i - 100) * HOUR));
  const deck = buildDeck(USER, all.reverse(), 400, NOW.getTime());
  assert.equal(deck.entries.length, DECK_SIZE);
  assert.equal(deck.entries[0].card.id, id(1), 'найдавніше — першим');
  assert.equal(deck.learningCount, 400);
  assert.equal(deck.dueOutside, 0, 'поза копією — лише майбутні');
  // поза копією теж є «на сьогодні»
  const allDue = Array.from({ length: DECK_SIZE + 5 }, (_, i) => entry(i + 1, -HOUR - i));
  assert.equal(buildDeck(USER, allDue, DECK_SIZE + 5, NOW.getTime()).dueOutside, 5);
  assert.equal(buildDeck(USER, [entry(1, 0)], 0, NOW.getTime()).learningCount, 1, 'лічильник — не менше, ніж слів у копії');
});

test('сесія: до 10 карток, спершу «на сьогодні»; фільтр рівня; вид сесії', () => {
  const entries = [entry(1, HOUR, 'A1'), entry(2, -HOUR, 'A0'), entry(3, 2 * HOUR, 'A0'), entry(4, -2 * HOUR, 'A1')];
  const all = pickSession(entries, 'ALL', 'recognize', NOW.getTime());
  assert.deepEqual(all.cards.map((c) => c.id), [id(4), id(2), id(1), id(3)]);
  assert.equal(all.kind, 'review');
  const a0 = pickSession(entries, 'A0', 'recognize', NOW.getTime());
  assert.deepEqual(a0.cards.map((c) => c.id), [id(2), id(3)]);
  assert.equal(pickSession([entry(1, HOUR)], 'ALL', 'recognize', NOW.getTime()).kind, 'practice', 'нічого не чекає — повторити наперед');
  assert.equal(pickSession(entries, 'ALL', 'write', NOW.getTime()).kind, 'write');
  assert.equal(pickSession(entries, 'B2', 'recognize', NOW.getTime()).cards.length, 0);
  const many = Array.from({ length: 25 }, (_, i) => entry(i + 1, -i));
  assert.equal(pickSession(many, 'ALL', 'recognize', NOW.getTime()).cards.length, 10);
});

test('оцінка на телефоні: той самий розклад, що й на сервері; щойно повторене не повертається «на сьогодні»', () => {
  const deck = buildDeck(USER, [entry(1, -HOUR), entry(2, -2 * HOUR)], 2, NOW.getTime());
  assert.equal(deckDueCount(deck, NOW.getTime()), 2);
  const rated = rateInDeck(deck, id(2), true, NOW);
  const expected = scheduleReview(NEW_CARD, true, NOW);
  const e2 = rated.entries.find((e) => e.card.id === id(2))!;
  assert.equal(e2.dueAt, expected.nextReviewDate.getTime());
  assert.equal(e2.srs.repetitionCount, 1);
  assert.equal(deckDueCount(rated, NOW.getTime()), 1);
  assert.equal(rated.entries[0].card.id, id(1), 'порядок оновлено');
  assert.equal(deck.entries[0].card.id, id(2), 'стара колода не змінилась');
  // «Не знаю» — знову сьогодні
  const wrong = rateInDeck(deck, id(1), false, NOW);
  assert.equal(deckDueCount(wrong, NOW.getTime()), 2);
  // слова немає в колоді — без змін
  assert.equal(rateInDeck(deck, id(9), true, NOW), deck);
});

test('копія з телефона: правильна — приймається, пошкоджена — «копії немає»', () => {
  const deck: TrainerDeck = buildDeck(USER, [entry(1, 0)], 1, NOW.getTime());
  assert.equal(isTrainerDeck(JSON.parse(JSON.stringify(deck))), true);
  assert.equal(isTrainerDeck(null), false);
  assert.equal(isTrainerDeck({ ...deck, userId: 'хтось' }), false);
  assert.equal(isTrainerDeck({ ...deck, entries: [{ ...deck.entries[0], card: { ...deck.entries[0].card, hr_text: '' } }] }), false);
  assert.equal(isTrainerDeck({ ...deck, entries: [{ ...deck.entries[0], srs: { easeFactor: 2.5 } }] }), false);
  assert.equal(isTrainerDeck({ ...deck, entries: [{ ...deck.entries[0], card: { ...deck.entries[0].card, theme: { icon: '🍞' } } }] }), false);
  assert.equal(isTrainerDeck({ ...deck, entries: Array(DECK_SIZE + 1).fill(deck.entries[0]) }), false, 'більше за межу');
  assert.equal(
    isTrainerDeck({ ...deck, entries: [{ ...deck.entries[0], card: { ...deck.entries[0].card, theme: { level: 'A0', moduleOrder: 7, icon: '🍞', title: 'Hrana' } } }] }),
    true,
  );
});

test('ключ колоди — свій у кожного акаунта, з префіксом офлайн-копій', () => {
  assert.equal(deckKey(USER), offlineKey('trainer', USER));
  assert.notEqual(deckKey(USER), deckKey(id(5)));
});
