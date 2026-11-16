/**
 * Уроки й фрази наперед для офлайну (§76, рішення власника 2026-11-16):
 * - відкрили урок → телефон тихо зберігає до 5 наступних уроків цього модуля і тексти модуля;
 * - «Сьогодні» → урок «Продовжити» з наступними і всі ситуації з фразами (діалоги — лише з інтернетом).
 *
 * Сторінки кладемо в той самий кеш сторінок PWA (`pages`, lib/pwa-cache.ts): запит позначено заголовком
 * PREFETCH_HEADER, правило кешу ловить і його. Без мережі урок відкривається з кешу, як щойно відвіданий.
 * Усе береться з опублікованого контенту бази (модулі, тексти, ситуації) — нові рівні (B1, B2) працюють без змін коду.
 *
 * Тут — логіка без браузера й бази (тести: lib/offline-prefetch.test.ts).
 */

/** Заголовок запиту «зберегти сторінку наперед». Сервер ситуації за ним віддає сторінку лише з фразами. */
export const PREFETCH_HEADER = 'X-Offline-Prefetch';
export const PREFETCH_HEADER_VALUE = 'page';
/** Те саме, але повна сторінка (оновлення збереженої після оновлення застосунку, lib/offline-refresh.ts). */
export const REFRESH_HEADER_VALUE = 'full';

/** Скільки наступних уроків модуля зберігати (рішення власника: 3–5). */
export const NEXT_LESSONS = 5;
/** Скільки текстів модуля зберігати (у модулях зараз 2–4). */
export const MODULE_TEXTS = 4;
/** Не повторювати той самий план частіше (години). Сторінки в кеші й так оновлюються, коли людина їх відкриває. */
export const PLAN_COOLDOWN_HOURS = 12;
const PLAN_RECORD_LIMIT = 50;
export const PLAN_RECORD_KEY = 'cs_offline_prefetch_v1';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

export function isPrefetchRequest(value: string | null | undefined): boolean {
  return value === PREFETCH_HEADER_VALUE;
}

export interface OrderedLesson {
  id: string;
  /** Порядок юніту в модулі */
  unitOrder: number;
  /** Порядок уроку в юніті */
  order: number;
}

/** Уроки модуля в порядку програми: спершу юніт, потім урок; однаковий порядок — за id (стабільно). */
export function sortModuleLessons(lessons: readonly OrderedLesson[]): OrderedLesson[] {
  return [...lessons].sort((a, b) => a.unitOrder - b.unitOrder || a.order - b.order || a.id.localeCompare(b.id));
}

/**
 * Які уроки зберегти: наступні після поточного (або з поточного включно — для «Продовжити»), не більше `limit`.
 * Поточного уроку немає в модулі → нічого (не вгадуємо).
 */
export function nextLessonIds(
  lessons: readonly OrderedLesson[],
  currentId: string,
  { includeCurrent = false, limit = NEXT_LESSONS }: { includeCurrent?: boolean; limit?: number } = {},
): string[] {
  const sorted = sortModuleLessons(lessons);
  const at = sorted.findIndex((l) => l.id === currentId);
  if (at < 0 || limit <= 0) return [];
  const from = includeCurrent ? at : at + 1;
  return sorted.slice(from, from + limit).map((l) => l.id);
}

export interface OfflinePlanInput {
  lessonIds?: readonly string[];
  textIds?: readonly string[];
  /** Коди ситуацій з фразами; null — ситуації не потрібні */
  situationCodes?: readonly string[] | null;
}

/** Адреси сторінок для збереження: уроки, тексти, потім список ситуацій і кожна ситуація. Без повторів і сміття. */
export function planUrls({ lessonIds = [], textIds = [], situationCodes = null }: OfflinePlanInput): string[] {
  const urls: string[] = [];
  for (const id of lessonIds) if (UUID_RE.test(id)) urls.push(`/lesson/${id}`);
  for (const id of textIds.slice(0, MODULE_TEXTS)) if (UUID_RE.test(id)) urls.push(`/reading/${id}`);
  if (situationCodes) {
    urls.push('/situations');
    for (const code of [...new Set(situationCodes)].sort()) if (/^[a-z][a-z_]{1,39}$/.test(code)) urls.push(`/situations/${code}`);
  }
  return [...new Set(urls)];
}

/** Чи варто зберігати наперед: є мережа, працює service worker, людина не ввімкнула економію трафіку. */
export function shouldPrefetch({ online, saveData, hasController }: { online: boolean; saveData: boolean; hasController: boolean }): boolean {
  return online && hasController && !saveData;
}

/** Ключ плану: звідки і для якого уроку (план «Сьогодні» з ситуаціями — окремий). */
export function planKey(source: string, lessonId: string | null | undefined, situations: boolean): string {
  return `${source}:${lessonId ?? '-'}:${situations ? 's' : ''}`;
}

export type PlanRecord = Record<string, number>;

export function parsePlanRecord(raw: string | null | undefined): PlanRecord {
  if (!raw) return {};
  try {
    const value = JSON.parse(raw) as unknown;
    if (!value || typeof value !== 'object' || Array.isArray(value)) return {};
    const out: PlanRecord = {};
    for (const [k, v] of Object.entries(value)) if (typeof v === 'number' && Number.isFinite(v)) out[k] = v;
    return out;
  } catch {
    return {};
  }
}

/** Чи пора знову: план ще не виконували або минуло PLAN_COOLDOWN_HOURS (годинник назад — теж пора). */
export function isPlanDue(record: PlanRecord, key: string, now: number): boolean {
  const at = record[key];
  if (at === undefined) return true;
  return now < at || now - at >= PLAN_COOLDOWN_HOURS * 3600_000;
}

/** Запам'ятати виконаний план; лишаємо найновіші PLAN_RECORD_LIMIT записів. */
export function rememberPlan(record: PlanRecord, key: string, now: number): PlanRecord {
  const entries = Object.entries({ ...record, [key]: now })
    .sort((a, b) => b[1] - a[1])
    .slice(0, PLAN_RECORD_LIMIT);
  return Object.fromEntries(entries);
}
