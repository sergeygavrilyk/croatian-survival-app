/**
 * Офлайн-копія сторінки в браузері (§76) — для уроку й тексту для читання.
 *
 * Дані сторінки тепер бере сервер (Server Component, §75), тож онлайн користувач завжди бачить свіже.
 * Копія в localStorage — лише запасний варіант, коли сервер не відповів. Тому немає ручних версій кешу
 * (колишні LESSON_CACHE_VERSION / READING_CACHE_VERSION / CURRICULUM_CACHE_VERSION): копію просто
 * перезаписує кожне успішне відкриття, а застарілий формат відсіює перевірка `isValid`.
 *
 * Сховище передаємо параметром (у тестах — підробка), будь-яка помилка сховища = «копії немає».
 */

export type KeyValueStorage = Pick<Storage, 'getItem' | 'setItem' | 'removeItem'> & {
  readonly length: number;
  key(index: number): string | null;
};

/** Формат запису. Змінювати лише тоді, коли змінюється сама обгортка нижче (не дані уроку). */
const ENTRY_FORMAT = 1;
export const OFFLINE_PREFIX = 'cs_offline_';

/** Ключі старого кешу з ручними версіями — прибираємо, щоб не займали місце. */
export const LEGACY_PREFIXES = ['cs_lesson_data_', 'cs_reading_', 'cs_modules_', 'cs_units_', 'cs_lessons_'] as const;

export type OfflineKind = 'lesson' | 'reading';

export function offlineKey(kind: OfflineKind, id: string): string {
  return `${OFFLINE_PREFIX}${kind}_${id}`;
}

interface Entry<T> {
  f: number;
  savedAt: number;
  data: T;
}

/** Зберегти копію. false — сховище недоступне чи переповнене (сторінка працює й без копії). */
export function saveOfflineCopy<T>(storage: KeyValueStorage | null | undefined, key: string, data: T, now = Date.now()): boolean {
  if (!storage) return false;
  try {
    const entry: Entry<T> = { f: ENTRY_FORMAT, savedAt: now, data };
    storage.setItem(key, JSON.stringify(entry));
    return true;
  } catch {
    return false;
  }
}

/** Сирий запис копії (рядок) або null. Рядок стабільний між викликами — годиться для useSyncExternalStore. */
export function readOfflineRaw(storage: KeyValueStorage | null | undefined, key: string): string | null {
  if (!storage) return null;
  try {
    return storage.getItem(key);
  } catch {
    return null;
  }
}

/** Розібрати запис; null — немає, пошкоджений, інший формат запису або дані не пройшли перевірку. */
export function parseOfflineCopy<T>(raw: string | null | undefined, isValid: (data: unknown) => data is T): { data: T; savedAt: number } | null {
  if (!raw) return null;
  try {
    const entry = JSON.parse(raw) as Partial<Entry<unknown>> | null;
    if (!entry || entry.f !== ENTRY_FORMAT || typeof entry.savedAt !== 'number' || !isValid(entry.data)) return null;
    return { data: entry.data, savedAt: entry.savedAt };
  } catch {
    return null;
  }
}

/** Прочитати копію (readOfflineRaw + parseOfflineCopy). */
export function readOfflineCopy<T>(
  storage: KeyValueStorage | null | undefined,
  key: string,
  isValid: (data: unknown) => data is T,
): { data: T; savedAt: number } | null {
  return parseOfflineCopy(readOfflineRaw(storage, key), isValid);
}

/** Прибрати ключі старого кешу. Повертає, скільки ключів видалено. */
export function purgeLegacyCache(storage: KeyValueStorage | null | undefined, prefixes: readonly string[] = LEGACY_PREFIXES): number {
  if (!storage) return 0;
  try {
    const doomed: string[] = [];
    for (let i = 0; i < storage.length; i++) {
      const k = storage.key(i);
      if (k && prefixes.some((p) => k.startsWith(p))) doomed.push(k);
    }
    for (const k of doomed) storage.removeItem(k);
    return doomed.length;
  } catch {
    return 0;
  }
}

/** localStorage браузера або null (сервер, приватний режим, заборонене сховище). */
export function browserStorage(): KeyValueStorage | null {
  try {
    return typeof window === 'undefined' ? null : window.localStorage;
  } catch {
    return null;
  }
}
