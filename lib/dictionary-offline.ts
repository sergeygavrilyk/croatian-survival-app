/**
 * Словник без мережі (§76, рішення власника 2026-11-16: «Простий варіант робимо»).
 *
 * Повного словника на телефоні немає — шукаємо серед слів, які вже є на телефоні:
 * - колода тренажера (до DECK_SIZE слів, які людина вчить; `lib/trainer-deck.ts`) — ці слова позначаються «Вчу»;
 * - слова уроків, відкритих раніше (офлайн-копії `cs_offline_lesson_*`, `lib/lesson-content.ts`).
 * Пошук — як у базі: лема, лема без діакритики або переклад; фільтри рівня й категорії; `vulgar` — лише з 18+.
 */
import { offlineKey, parseOfflineCopy, type KeyValueStorage } from './offline-copy.ts';
import { isTrainerDeck } from './trainer-deck.ts';
import { isLessonContent } from './lesson-content.ts';
import { DEFAULT_LABELS, isVisibleWord, matchesCategory, type LexemeLabels, type WordCategory } from './lexeme-labels.ts';
import { normalizeSearch } from './grammar.ts';
import { LEVEL_CODES } from './levels.ts';

export interface OfflineWord {
  id: string;
  lemma: string;
  translation: string;
  level: string | null;
  example: string | null;
  labels: LexemeLabels;
  /** слово з колоди тренажера — людина його вчить */
  learning: boolean;
}

/** Скільки результатів показуємо за раз (без мережі — без «Ще»). */
export const OFFLINE_RESULTS_LIMIT = 200;

/** Зібрати слова з копій на телефоні; одне слово — один запис (дані з колоди тренажера мають перевагу). */
export function collectOfflineWords(storage: KeyValueStorage | null | undefined, userId: string | null): OfflineWord[] {
  if (!storage) return [];
  const byId = new Map<string, OfflineWord>();
  try {
    // уроки: ключі cs_offline_lesson_<id>
    const lessonPrefix = offlineKey('lesson', '');
    const lessonKeys: string[] = [];
    for (let i = 0; i < storage.length; i++) {
      const k = storage.key(i);
      if (k && k.startsWith(lessonPrefix)) lessonKeys.push(k);
    }
    for (const key of lessonKeys) {
      const copy = parseOfflineCopy(storage.getItem(key), isLessonContent);
      if (!copy) continue;
      const level = copy.data.lesson.level_code ?? null;
      for (const w of copy.data.words) {
        if (!w.id || !w.hr_text.trim() || byId.has(w.id)) continue;
        byId.set(w.id, {
          id: w.id,
          lemma: w.hr_text,
          translation: w.ua_translation,
          level,
          example: null,
          labels: w.labels ?? DEFAULT_LABELS,
          learning: false,
        });
      }
    }
    // колода тренажера — лише свого акаунта
    if (userId) {
      const deck = parseOfflineCopy(storage.getItem(offlineKey('trainer', userId)), isTrainerDeck);
      for (const e of deck?.data.entries ?? []) {
        const c = e.card;
        if (!c.id || !c.hr_text.trim()) continue;
        const known = byId.get(c.id);
        byId.set(c.id, {
          id: c.id,
          lemma: c.hr_text,
          translation: c.ua_translation,
          level: e.cefr ?? c.level ?? known?.level ?? null,
          example: c.example?.trim() ? c.example : null,
          labels: known?.labels ?? DEFAULT_LABELS,
          learning: true,
        });
      }
    }
  } catch {
    // сховище недоступне — словник просто скаже, що без інтернету слів немає
  }
  return [...byId.values()];
}

const levelRank = (level: string | null) => {
  const i = level ? (LEVEL_CODES as readonly string[]).indexOf(level) : -1;
  return i < 0 ? LEVEL_CODES.length : i;
};

export interface OfflineSearch {
  /** термін після `dictionarySearchTerm` (апостроф там — «_») або null — усі слова */
  term: string | null;
  /** 'ALL' або код рівня */
  level: string;
  category: WordCategory;
  adultContent: boolean;
}

/** Пошук серед слів на телефоні: спершу A0, потім A1…, далі за абеткою. */
export function searchOfflineWords(words: readonly OfflineWord[], q: OfflineSearch): OfflineWord[] {
  const needle = q.term ? normalizeSearch(q.term.replace(/_/g, '')) : '';
  return words
    .filter((w) => isVisibleWord(w.labels, q.adultContent))
    .filter((w) => q.level === 'ALL' || w.level === q.level)
    .filter((w) => matchesCategory(w.labels, q.category))
    .filter((w) => !needle || normalizeSearch(w.lemma).includes(needle) || normalizeSearch(w.translation).includes(needle))
    .sort((a, b) => levelRank(a.level) - levelRank(b.level) || a.lemma.localeCompare(b.lemma, 'hr'))
    .slice(0, OFFLINE_RESULTS_LIMIT);
}
