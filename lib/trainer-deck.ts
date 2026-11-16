/**
 * Тренажер без мережі (офлайн без втрат, етап 2; рішення власника 2026-11-16, ARCHITECTURE §76).
 *
 * Колода — слова, які людина вже вчить (user_progress), зі станом повторення (SRS): спершу ті, що чекають
 * найдовше. Онлайн тренажер щоразу зберігає копію колоди на телефоні (localStorage, lib/offline-copy.ts);
 * без мережі сесію складає з копії. Кожна оцінка (онлайн чи ні) одразу змінює копію тим самим розкладом
 * (lib/srs.ts), тож щойно повторене слово без мережі не повертається «на сьогодні» знову.
 * Оцінки без мережі — у черзі (srs_rating), сервер застосовує їх з часом відповіді.
 *
 * Логіка без браузера й бази; тести — trainer-deck.test.ts.
 */
import { scheduleReview, DEFAULT_EASE, type SrsState } from './srs.ts';
import { isUuidValue } from './offline-queue.ts';
import { offlineKey } from './offline-copy.ts';
import type { WordTheme } from './word-theme.ts';

/** Скільки слів тримаємо в копії (≈ 0,5 КБ на слово; так само — частина запиту тем по 150). */
export const DECK_SIZE = 150;
/** Скільки карток у сесії. */
export const SESSION_SIZE = 10;

export const DECK_LEVEL_ALL = 'ALL';

export type SessionKind = 'review' | 'practice' | 'write';

/** Картка тренажера — те, що показують «Картки» (FlashcardTrainer) і «Написати» (WriteTrainer). */
export interface TrainerCard {
  id: string;
  hr_text: string;
  ua_translation: string;
  phonetic_note?: string;
  audio_url?: string;
  example?: string;
  level?: string;
  theme?: WordTheme | null;
}

export interface DeckEntry {
  card: TrainerCard;
  /** Рівень слова (lexemes.cefr) — для фільтра рівня */
  cefr: string | null;
  /** Коли повторити (мс); 0 — одразу */
  dueAt: number;
  srs: SrsState;
}

export interface TrainerDeck {
  userId: string;
  entries: DeckEntry[];
  /** Скільки всього слів людина вчить (у копії — лише перші DECK_SIZE) */
  learningCount: number;
  /** Скільки слів поза копією чекали повторення в момент збереження */
  dueOutside: number;
}

export interface ProgressRow {
  lexeme_id: string;
  next_review_date: string | null;
  ease_factor?: number | null;
  interval_days?: number | null;
  repetition_count?: number | null;
  lapses?: number | null;
}

export function srsFromRow(row: ProgressRow): SrsState {
  const num = (v: unknown, fallback: number) => (typeof v === 'number' && Number.isFinite(v) ? v : fallback);
  return {
    easeFactor: num(row.ease_factor, DEFAULT_EASE),
    intervalDays: num(row.interval_days, 0),
    repetitionCount: num(row.repetition_count, 0),
    lapses: num(row.lapses, 0),
  };
}

export function dueAtFromRow(row: Pick<ProgressRow, 'next_review_date'>): number {
  const ms = row.next_review_date ? Date.parse(row.next_review_date) : 0;
  return Number.isFinite(ms) ? ms : 0;
}

/** Спершу ті, що чекають найдовше (як онлайн); однаковий час — за id, щоб порядок не стрибав. */
export function sortEntries(entries: readonly DeckEntry[]): DeckEntry[] {
  return [...entries].sort((a, b) => a.dueAt - b.dueAt || (a.card.id < b.card.id ? -1 : a.card.id > b.card.id ? 1 : 0));
}

export function isDue(entry: Pick<DeckEntry, 'dueAt'>, now: number): boolean {
  return entry.dueAt <= now;
}

/** Копія колоди для телефона: перші DECK_SIZE слів, решта — лише лічильники. */
export function buildDeck(userId: string, all: readonly DeckEntry[], learningCount: number, now: number): TrainerDeck {
  const sorted = sortEntries(all);
  const kept = sorted.slice(0, DECK_SIZE);
  const dueOutside = sorted.slice(DECK_SIZE).filter((e) => isDue(e, now)).length;
  return { userId, entries: kept, learningCount: Math.max(learningCount, kept.length), dueOutside };
}

/**
 * Сесія: спершу слова «на сьогодні», потім — решта вивчених (повторити наперед), як онлайн.
 * `level` — рівень слів або «ALL».
 */
export function pickSession(
  entries: readonly DeckEntry[],
  level: string,
  mode: 'recognize' | 'write',
  now: number,
  size: number = SESSION_SIZE,
): { cards: TrainerCard[]; kind: SessionKind } {
  const chosen = sortEntries(entries)
    .filter((e) => level === DECK_LEVEL_ALL || e.cefr === level)
    .slice(0, size);
  const kind: SessionKind = mode === 'write' ? 'write' : chosen.some((e) => isDue(e, now)) ? 'review' : 'practice';
  return { cards: chosen.map((e) => e.card), kind };
}

/** Скільки слів у колоді чекає повторення зараз (+ ті, що поза копією). */
export function deckDueCount(deck: Pick<TrainerDeck, 'entries' | 'dueOutside'>, now: number): number {
  return deck.entries.filter((e) => isDue(e, now)).length + deck.dueOutside;
}

/**
 * Оцінка на телефоні: той самий розклад, що й на сервері (lib/srs.ts). Слова немає в колоді — колода
 * без змін (його стан змінить сервер).
 */
export function rateInDeck(deck: TrainerDeck, lexemeId: string, correct: boolean, now: Date): TrainerDeck {
  const i = deck.entries.findIndex((e) => e.card.id === lexemeId);
  if (i < 0) return deck;
  const prev = deck.entries[i];
  const next = scheduleReview(prev.srs, correct, now);
  const entry: DeckEntry = {
    ...prev,
    dueAt: next.nextReviewDate.getTime(),
    srs: { easeFactor: next.easeFactor, intervalDays: next.intervalDays, repetitionCount: next.repetitionCount, lapses: next.lapses },
  };
  const entries = [...deck.entries];
  entries[i] = entry;
  return { ...deck, entries: sortEntries(entries) };
}

// ---------------------------------------------------------------------------
// Перевірка копії з телефона (пошкоджене / старий формат = копії немає)
// ---------------------------------------------------------------------------

const isStr = (v: unknown): v is string => typeof v === 'string';
const optStr = (v: unknown) => v === undefined || typeof v === 'string';
const isNum = (v: unknown): v is number => typeof v === 'number' && Number.isFinite(v);

function isTheme(v: unknown): boolean {
  if (v === undefined || v === null) return true;
  if (typeof v !== 'object') return false;
  const t = v as Record<string, unknown>;
  return isStr(t.level) && isNum(t.moduleOrder) && isStr(t.icon) && isStr(t.title);
}

function isCard(v: unknown): v is TrainerCard {
  if (!v || typeof v !== 'object') return false;
  const c = v as Record<string, unknown>;
  return (
    isUuidValue(c.id) && isStr(c.hr_text) && !!c.hr_text.trim() && isStr(c.ua_translation) &&
    optStr(c.phonetic_note) && optStr(c.audio_url) && optStr(c.example) && optStr(c.level) && isTheme(c.theme)
  );
}

function isEntry(v: unknown): v is DeckEntry {
  if (!v || typeof v !== 'object') return false;
  const e = v as Record<string, unknown>;
  const s = e.srs as Record<string, unknown> | null | undefined;
  return (
    isCard(e.card) && (e.cefr === null || isStr(e.cefr)) && isNum(e.dueAt) &&
    !!s && typeof s === 'object' && isNum(s.easeFactor) && isNum(s.intervalDays) && isNum(s.repetitionCount) && isNum(s.lapses)
  );
}

export function isTrainerDeck(value: unknown): value is TrainerDeck {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return false;
  const d = value as Record<string, unknown>;
  return (
    isUuidValue(d.userId) && Array.isArray(d.entries) && d.entries.length <= DECK_SIZE && d.entries.every(isEntry) &&
    isNum(d.learningCount) && isNum(d.dueOutside)
  );
}

/** Ключ копії колоди (у кожного акаунта своя). */
export function deckKey(userId: string): string {
  return offlineKey('trainer', userId);
}
