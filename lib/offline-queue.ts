/**
 * Черга прогресу на телефоні (офлайн без втрат, рішення власника 2026-11-16, ARCHITECTURE §76).
 *
 * Без мережі завершення уроку й тексту, слово в повторення і події навчання не губляться: застосунок
 * кладе їх сюди (localStorage), а components/OfflineSync.tsx тихо відправляє, щойно є мережа
 * (server action syncOfflineOps → lib/offline-sync.ts). Кожна дія має свій номер (op_id), тож сервер
 * зараховує її рівно один раз, навіть якщо телефон надіслав її двічі.
 *
 * Логіка без браузера: сховище передаємо параметром (у тестах — підробка); будь-яка помилка сховища
 * або пошкоджений запис = «цього запису немає», застосунок не падає.
 * План — docs/proposals/2026-11-16_offline_sync.md.
 */
import type { KeyValueStorage } from './offline-copy.ts';

/** Види дій. Мають збігатися з CHECK у міграції M28 (public.client_ops). `srs_rating` — етап 2. */
export const OFFLINE_OP_KINDS = ['lesson_completed', 'reading_completed', 'word_saved', 'event', 'srs_rating'] as const;
export type OfflineOpKind = (typeof OFFLINE_OP_KINDS)[number];

/** Скільки дій тримаємо (рішення 2026-11-16: ≤ 200). Коли більше — першими відкидаємо найстаріші події. */
export const QUEUE_MAX_OPS = 200;
/** Скільки днів дія чекає на мережу (рішення власника 2026-11-16: 14 днів). */
export const QUEUE_MAX_AGE_DAYS = 14;
export const QUEUE_MAX_AGE_MS = QUEUE_MAX_AGE_DAYS * 24 * 60 * 60 * 1000;
/** Скільки дій відправляємо за раз. */
export const SYNC_BATCH_SIZE = 20;
/** Паузи між спробами відправити, коли сервер не відповів: 5 с → 30 с → 2 хв (далі — 2 хв). */
export const SYNC_RETRY_DELAYS_MS = [5_000, 30_000, 120_000] as const;

export const QUEUE_PREFIX = 'cs_queue_';
export const EXPIRED_PREFIX = 'cs_queue_expired_';
/** Cookie з id користувача, яке ставить proxy.ts: так телефон знає, чия черга, навіть без мережі. */
export const UID_COOKIE = 'cs_uid';
/** Подія вікна: черга змінилась (значок «⏳ … чекають на інтернет» оновлюється). */
export const QUEUE_CHANGED_EVENT = 'cs-offline-queue-changed';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
const QUEUE_FORMAT = 1;

export interface OfflineOp {
  /** Номер дії (uuid): за ним сервер пропускає повтор */
  op_id: string;
  kind: OfflineOpKind;
  /** Чия дія: черга одного акаунта ніколи не піде від імені іншого */
  user_id: string;
  /** Коли людина це зробила (ISO, годинник телефона) — серія 🔥 і «повторити завтра» рахуються за цим днем */
  at: string;
  payload: Record<string, unknown>;
}

export function isUuidValue(value: unknown): value is string {
  return typeof value === 'string' && UUID_RE.test(value);
}

export function isOfflineOpKind(value: unknown): value is OfflineOpKind {
  return typeof value === 'string' && (OFFLINE_OP_KINDS as readonly string[]).includes(value);
}

/** Чи схоже значення на коректний запис черги (формат, а не зміст — зміст перевіряє сервер). */
export function isOfflineOp(value: unknown): value is OfflineOp {
  if (!value || typeof value !== 'object' || Array.isArray(value)) return false;
  const op = value as Record<string, unknown>;
  return (
    isUuidValue(op.op_id) &&
    isOfflineOpKind(op.kind) &&
    isUuidValue(op.user_id) &&
    typeof op.at === 'string' &&
    Number.isFinite(Date.parse(op.at)) &&
    !!op.payload &&
    typeof op.payload === 'object' &&
    !Array.isArray(op.payload)
  );
}

export function newOpId(): string {
  if (typeof crypto !== 'undefined' && 'randomUUID' in crypto) return crypto.randomUUID();
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
    const r = (Math.random() * 16) | 0;
    return (c === 'x' ? r : (r & 0x3) | 0x8).toString(16);
  });
}

/** Нова дія для черги. */
export function newOp(
  kind: OfflineOpKind,
  userId: string,
  payload: Record<string, unknown>,
  now: Date = new Date(),
  opId: string = newOpId(),
): OfflineOp {
  return { op_id: opId, kind, user_id: userId, at: now.toISOString(), payload };
}

export function queueKey(userId: string): string {
  return `${QUEUE_PREFIX}${userId}`;
}

function byTime(a: OfflineOp, b: OfflineOp): number {
  return Date.parse(a.at) - Date.parse(b.at);
}

/** Розібрати збережене: лише коректні записи цього користувача, без повторів номера, за часом. */
function parseStored(raw: string | null, userId: string): { ops: OfflineOp[]; dropped: number } {
  if (!raw) return { ops: [], dropped: 0 };
  try {
    const parsed = JSON.parse(raw) as { f?: unknown; ops?: unknown } | null;
    if (!parsed || parsed.f !== QUEUE_FORMAT || !Array.isArray(parsed.ops)) return { ops: [], dropped: 1 };
    const seen = new Set<string>();
    const ops: OfflineOp[] = [];
    let dropped = 0;
    for (const item of parsed.ops) {
      if (!isOfflineOp(item) || item.user_id !== userId || seen.has(item.op_id)) {
        dropped++;
        continue;
      }
      seen.add(item.op_id);
      ops.push(item);
    }
    return { ops: ops.sort(byTime), dropped };
  } catch {
    return { ops: [], dropped: 1 };
  }
}

function writeOps(storage: KeyValueStorage, userId: string, ops: OfflineOp[]): boolean {
  try {
    if (ops.length === 0) storage.removeItem(queueKey(userId));
    else storage.setItem(queueKey(userId), JSON.stringify({ f: QUEUE_FORMAT, ops }));
    return true;
  } catch {
    return false;
  }
}

/** Чи дія задавня (старша за 14 днів) на момент `now`. */
export function isExpired(op: Pick<OfflineOp, 'at'>, now: number = Date.now()): boolean {
  return now - Date.parse(op.at) > QUEUE_MAX_AGE_MS;
}

/**
 * Черга користувача: коректні записи за часом дії. Задавнені (> 14 днів) прибирає зі сховища
 * й повертає їхню кількість у `expired` (повідомлення людині — один раз, бо вдруге їх уже немає).
 */
export function readQueue(
  storage: KeyValueStorage | null | undefined,
  userId: string | null | undefined,
  now: number = Date.now(),
): { ops: OfflineOp[]; expired: number } {
  if (!storage || !isUuidValue(userId)) return { ops: [], expired: 0 };
  let raw: string | null;
  try {
    raw = storage.getItem(queueKey(userId));
  } catch {
    return { ops: [], expired: 0 };
  }
  const { ops, dropped } = parseStored(raw, userId);
  const fresh = ops.filter((op) => !isExpired(op, now));
  const expired = ops.length - fresh.length;
  if (expired > 0 || dropped > 0) {
    writeOps(storage, userId, fresh);
    if (expired > 0) noteExpired(storage, userId, expired);
  }
  return { ops: fresh, expired };
}

/** Скільки дій чекає на мережу. Лише читає (сховище не змінює) — годиться для useSyncExternalStore. */
export function pendingCount(storage: KeyValueStorage | null | undefined, userId: string | null | undefined, now: number = Date.now()): number {
  if (!storage || !isUuidValue(userId)) return 0;
  try {
    return parseStored(storage.getItem(queueKey(userId)), userId).ops.filter((op) => !isExpired(op, now)).length;
  } catch {
    return 0;
  }
}

/**
 * Додати дію. Той самий номер двічі — один запис. Більше 200 — відкидаємо найстаріші події навчання,
 * а прогрес (урок, текст, слово) — лише якщо подій уже немає. false — сховище недоступне чи переповнене.
 */
export function enqueueOp(
  storage: KeyValueStorage | null | undefined,
  op: OfflineOp,
  now: number = Date.now(),
): { ok: boolean; size: number; evicted: number } {
  if (!storage || !isOfflineOp(op) || isExpired(op, now)) return { ok: false, size: 0, evicted: 0 };
  const { ops } = readQueue(storage, op.user_id, now);
  if (ops.some((o) => o.op_id === op.op_id)) return { ok: true, size: ops.length, evicted: 0 };
  const next = [...ops, op].sort(byTime);
  let evicted = 0;
  while (next.length > QUEUE_MAX_OPS) {
    const eventIndex = next.findIndex((o) => o.kind === 'event');
    next.splice(eventIndex >= 0 ? eventIndex : 0, 1);
    evicted++;
  }
  const ok = writeOps(storage, op.user_id, next);
  return { ok, size: ok ? next.length : ops.length, evicted };
}

/** Прибрати з черги дії, які сервер прийняв, уже мав або відхилив назавжди. */
export function removeOps(storage: KeyValueStorage | null | undefined, userId: string, opIds: readonly string[]): number {
  if (!storage || !isUuidValue(userId) || opIds.length === 0) return 0;
  const drop = new Set(opIds);
  let raw: string | null;
  try {
    raw = storage.getItem(queueKey(userId));
  } catch {
    return 0;
  }
  const { ops } = parseStored(raw, userId);
  const left = ops.filter((o) => !drop.has(o.op_id));
  const removed = ops.length - left.length;
  if (removed > 0) writeOps(storage, userId, left);
  return removed;
}

/** Розбити на пакети по SYNC_BATCH_SIZE. */
export function syncBatches<T>(ops: readonly T[], size: number = SYNC_BATCH_SIZE): T[][] {
  const out: T[][] = [];
  for (let i = 0; i < ops.length; i += size) out.push(ops.slice(i, i + size));
  return out;
}

/** Пауза перед наступною спробою після `failures` невдалих поспіль (1 → 5 с, 2 → 30 с, 3+ → 2 хв). */
export function syncRetryDelay(failures: number): number {
  const i = Math.max(0, Math.min(Math.floor(failures) - 1, SYNC_RETRY_DELAYS_MS.length - 1));
  return SYNC_RETRY_DELAYS_MS[i];
}

// ---------------------------------------------------------------------------
// Повідомлення «частину результатів не вдалося зберегти» — один раз
// ---------------------------------------------------------------------------

function noteExpired(storage: KeyValueStorage, userId: string, count: number): void {
  try {
    const prev = Number(storage.getItem(`${EXPIRED_PREFIX}${userId}`)) || 0;
    storage.setItem(`${EXPIRED_PREFIX}${userId}`, String(prev + count));
  } catch {
    // без повідомлення — не страшно
  }
}

/** Скільки задавнених дій відкинуто й ще не показано людині (лише читає). */
export function peekExpiredNotice(storage: KeyValueStorage | null | undefined, userId: string | null | undefined): number {
  if (!storage || !isUuidValue(userId)) return 0;
  try {
    const n = Number(storage.getItem(`${EXPIRED_PREFIX}${userId}`)) || 0;
    return n > 0 ? n : 0;
  } catch {
    return 0;
  }
}

/** Скільки задавнених дій відкинуто з минулого показу; читання прибирає позначку (показуємо один раз). */
export function takeExpiredNotice(storage: KeyValueStorage | null | undefined, userId: string | null | undefined): number {
  if (!storage || !isUuidValue(userId)) return 0;
  try {
    const key = `${EXPIRED_PREFIX}${userId}`;
    const n = Number(storage.getItem(key)) || 0;
    if (n > 0) storage.removeItem(key);
    return n > 0 ? n : 0;
  } catch {
    return 0;
  }
}

// ---------------------------------------------------------------------------
// Хто користувач і чи це збій мережі
// ---------------------------------------------------------------------------

/** id користувача з cookie `cs_uid` (ставить proxy.ts) або null. */
export function readUserIdCookie(cookie: string | null | undefined): string | null {
  if (!cookie) return null;
  for (const part of cookie.split(';')) {
    const [name, ...rest] = part.trim().split('=');
    if (name !== UID_COOKIE) continue;
    let value = rest.join('=');
    try {
      value = decodeURIComponent(value);
    } catch {
      return null;
    }
    return isUuidValue(value) ? value.toLowerCase() : null;
  }
  return null;
}

/**
 * Чи помилка виклику сервера — це відсутність мережі (тоді дію кладемо в чергу), а не відмова сервера
 * (тоді показуємо помилку, як і раніше). Браузер без мережі кидає TypeError («Failed to fetch»,
 * Safari — «Load failed»); помилки з сервера приходять звичайним Error.
 */
export function isNetworkError(error: unknown, online: boolean | undefined = true): boolean {
  if (online === false) return true;
  if (error instanceof TypeError) return true;
  const message = error instanceof Error ? error.message : typeof error === 'string' ? error : '';
  return /failed to fetch|load failed|network ?error|networkerror|fetch failed|internet connection appears to be offline/i.test(message);
}
