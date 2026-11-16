/**
 * Прийом черги з телефону на сервері (офлайн без втрат, рішення власника 2026-11-16) — логіка без бази.
 *
 * Server action syncOfflineOps (app/actions/offline-sync.ts) лише авторизує і передає сюди функції роботи
 * з базою (SyncDeps). Тут — перевірка кожної дії, час дії, повтор номера і порядок:
 *   - дія чужого акаунта → `foreign` (телефон лишає її в черзі до входу «свого» акаунта);
 *   - номер уже був → `duplicate` (нічого не робимо);
 *   - час у майбутньому → беремо час сервера; старше 14 днів або нечитабельний → `rejected`;
 *   - зміст не пройшов перевірку → `rejected`; збій бази → `retry` (телефон спробує пізніше).
 * Дії застосовуються по черзі, у тому порядку, як людина вчилася (за часом дії).
 */
import { isOfflineOpKind, isUuidValue, QUEUE_MAX_AGE_MS, SYNC_BATCH_SIZE, type OfflineOpKind } from './offline-queue.ts';
import { isEventName, type EventName, type EventProps } from './analytics.ts';

export type SyncStatus = 'ok' | 'duplicate' | 'rejected' | 'retry' | 'foreign';

export interface SyncResult {
  op_id: string;
  status: SyncStatus;
  /** Причина відмови (для журналу; людині не показуємо) */
  reason?: string;
}

/** Що телефон прибирає з черги: прийняте, уже наявне й відхилене назавжди. `retry` і `foreign` лишаються. */
export function isSettled(status: SyncStatus): boolean {
  return status === 'ok' || status === 'duplicate' || status === 'rejected';
}

/** Події, які пише лише сервер (з черги не приймаємо). */
const SERVER_ONLY_EVENTS: readonly EventName[] = ['offline_synced'];

/**
 * Час дії для запису: у майбутньому (годинник телефона спішить) — час сервера;
 * старше 14 днів або не дата — відмова.
 */
export function resolveOpTime(
  at: unknown,
  serverNow: Date,
): { ok: true; at: Date } | { ok: false; reason: 'bad_time' | 'too_old' } {
  const ms = typeof at === 'string' ? Date.parse(at) : NaN;
  if (!Number.isFinite(ms)) return { ok: false, reason: 'bad_time' };
  const now = serverNow.getTime();
  if (ms > now) return { ok: true, at: new Date(now) };
  if (now - ms > QUEUE_MAX_AGE_MS) return { ok: false, reason: 'too_old' };
  return { ok: true, at: new Date(ms) };
}

export type ValidOp =
  | { kind: 'lesson_completed'; lessonId: string; durationMs?: number; level?: string; sessionId?: string }
  | { kind: 'reading_completed'; textId: string; correct: number; total: number; durationMs?: number; level?: string }
  | { kind: 'word_saved'; source: 'reading'; textId: string; lemma: string }
  | { kind: 'word_saved'; source: 'dictionary'; lexemeId: string; category?: string }
  | { kind: 'event'; name: EventName; props: EventProps }
  /** Оцінка картки тренажера («Знаю» / «Не знаю», «Написати») — етап 2 */
  | { kind: 'srs_rating'; target: 'lexeme'; lexemeId: string; rating: 0 | 1; responseTimeMs?: number }
  /** Відповідь у «Помилках» («Виправте помилку») — етап 2 */
  | { kind: 'srs_rating'; target: 'mistake'; errorId: string; correct: boolean; durationMs?: number };

const optText = (v: unknown, max: number): string | undefined =>
  typeof v === 'string' && v.trim() ? v.trim().slice(0, max) : undefined;

const optDuration = (v: unknown): number | undefined =>
  typeof v === 'number' && Number.isFinite(v) && v >= 0 ? Math.min(Math.round(v), 86_400_000) : undefined;

/** Перевірити й нормалізувати зміст дії. null — дія некоректна (відмова). */
export function parseOpPayload(kind: OfflineOpKind, payload: unknown): ValidOp | null {
  if (!payload || typeof payload !== 'object' || Array.isArray(payload)) return null;
  const p = payload as Record<string, unknown>;
  switch (kind) {
    case 'lesson_completed':
      if (!isUuidValue(p.lesson_id)) return null;
      return {
        kind,
        lessonId: p.lesson_id,
        durationMs: optDuration(p.duration_ms),
        level: optText(p.level, 8),
        sessionId: isUuidValue(p.session_id) ? p.session_id : undefined,
      };
    case 'reading_completed': {
      if (!isUuidValue(p.text_id)) return null;
      const total = Number.isInteger(p.total) ? Math.max(0, Math.min(p.total as number, 20)) : 0;
      const correct = Number.isInteger(p.correct) ? Math.max(0, Math.min(p.correct as number, total)) : 0;
      return { kind, textId: p.text_id, correct, total, durationMs: optDuration(p.duration_ms), level: optText(p.level, 8) };
    }
    case 'word_saved': {
      if (p.source === 'reading') {
        const lemma = typeof p.lemma === 'string' ? p.lemma.trim() : '';
        if (!lemma || lemma.length > 80 || !isUuidValue(p.text_id)) return null;
        return { kind, source: 'reading', textId: p.text_id, lemma };
      }
      if (p.source === 'dictionary') {
        if (!isUuidValue(p.lexeme_id)) return null;
        return { kind, source: 'dictionary', lexemeId: p.lexeme_id, category: optText(p.category, 40) };
      }
      return null;
    }
    case 'event': {
      if (!isEventName(p.name) || SERVER_ONLY_EVENTS.includes(p.name)) return null;
      const props = p.props && typeof p.props === 'object' && !Array.isArray(p.props) ? (p.props as EventProps) : {};
      return { kind, name: p.name, props };
    }
    case 'srs_rating': {
      // target: lexeme — картка тренажера, mistake — «Помилки» (одна таблиця журналу, M28 без змін)
      if (p.target === 'lexeme') {
        if (!isUuidValue(p.lexeme_id) || (p.rating !== 0 && p.rating !== 1)) return null;
        return { kind, target: 'lexeme', lexemeId: p.lexeme_id, rating: p.rating, responseTimeMs: optDuration(p.response_time_ms) };
      }
      if (p.target === 'mistake') {
        if (!isUuidValue(p.error_id) || typeof p.correct !== 'boolean') return null;
        return { kind, target: 'mistake', errorId: p.error_id, correct: p.correct, durationMs: optDuration(p.duration_ms) };
      }
      return null;
    }
    default:
      return null;
  }
}

export type ApplyOutcome = { status: 'ok' } | { status: 'rejected'; reason: string } | { status: 'retry'; reason: string };

export interface SyncDeps {
  userId: string;
  now: Date;
  /** Які з цих номерів сервер уже приймав (журнал client_ops) */
  knownOpIds(opIds: string[]): Promise<Set<string>>;
  /** Застосувати дію з часом `at` (та сама логіка, що й онлайн) */
  apply(op: ValidOp, at: Date): Promise<ApplyOutcome>;
  /** Записати номер прийнятої дії (журнал client_ops); збій запису не скасовує дію */
  record(opId: string, kind: OfflineOpKind, at: Date): Promise<void>;
  log?: (message: string, error: unknown) => void;
}

interface Pending {
  opId: string;
  kind: OfflineOpKind;
  at: Date;
  op: ValidOp;
}

/**
 * Прийняти пакет дій з телефону (до SYNC_BATCH_SIZE; решта — наступним пакетом).
 * Повертає відповідь по кожній дії з коректним номером; записи без номера пропускаємо мовчки.
 */
export async function syncOps(input: unknown, deps: SyncDeps): Promise<SyncResult[]> {
  if (!Array.isArray(input)) return [];
  const log = deps.log ?? ((message, error) => console.error(message, error));
  const results: SyncResult[] = [];
  const pending: Pending[] = [];
  const seen = new Set<string>();

  for (const raw of input.slice(0, SYNC_BATCH_SIZE)) {
    if (!raw || typeof raw !== 'object' || Array.isArray(raw)) continue;
    const item = raw as Record<string, unknown>;
    if (!isUuidValue(item.op_id)) continue;
    const opId = item.op_id.toLowerCase();
    if (seen.has(opId)) {
      results.push({ op_id: item.op_id, status: 'duplicate' });
      continue;
    }
    seen.add(opId);
    if (typeof item.user_id !== 'string' || item.user_id.toLowerCase() !== deps.userId.toLowerCase()) {
      results.push({ op_id: item.op_id, status: 'foreign' });
      continue;
    }
    if (!isOfflineOpKind(item.kind)) {
      results.push({ op_id: item.op_id, status: 'rejected', reason: 'bad_kind' });
      continue;
    }
    const time = resolveOpTime(item.at, deps.now);
    if (!time.ok) {
      results.push({ op_id: item.op_id, status: 'rejected', reason: time.reason });
      continue;
    }
    const op = parseOpPayload(item.kind, item.payload);
    if (!op) {
      results.push({ op_id: item.op_id, status: 'rejected', reason: 'bad_payload' });
      continue;
    }
    pending.push({ opId: item.op_id, kind: item.kind, at: time.at, op });
  }

  if (pending.length === 0) return results;

  let known: Set<string>;
  try {
    known = new Set([...(await deps.knownOpIds(pending.map((p) => p.opId)))].map((id) => id.toLowerCase()));
  } catch (error) {
    // не знаємо, що вже було — нічого не застосовуємо, телефон спробує пізніше
    log('syncOps: не вдалося прочитати журнал client_ops:', error);
    return [...results, ...pending.map((p) => ({ op_id: p.opId, status: 'retry' as const, reason: 'journal' }))];
  }

  // У тому порядку, як людина вчилася
  pending.sort((a, b) => a.at.getTime() - b.at.getTime());
  for (const p of pending) {
    if (known.has(p.opId.toLowerCase())) {
      results.push({ op_id: p.opId, status: 'duplicate' });
      continue;
    }
    let outcome: ApplyOutcome;
    try {
      outcome = await deps.apply(p.op, p.at);
    } catch (error) {
      log(`syncOps: збій дії ${p.kind}:`, error);
      outcome = { status: 'retry', reason: 'apply' };
    }
    if (outcome.status === 'ok') {
      try {
        await deps.record(p.opId, p.kind, p.at);
      } catch (error) {
        log('syncOps: не вдалося записати номер дії в client_ops:', error);
      }
      results.push({ op_id: p.opId, status: 'ok' });
    } else {
      results.push({ op_id: p.opId, status: outcome.status, reason: outcome.reason });
    }
  }
  return results;
}

/** Підсумок для події offline_synced: скільки прийнято, скільки відхилено, найдовше очікування. */
export function syncSummary(
  results: readonly SyncResult[],
  input: unknown,
  now: Date,
): { count: number; failed: number; age_ms: number } {
  const accepted = new Set(results.filter((r) => r.status === 'ok').map((r) => r.op_id));
  let age = 0;
  if (Array.isArray(input)) {
    for (const raw of input) {
      const item = raw as { op_id?: unknown; at?: unknown } | null;
      if (!item || typeof item.op_id !== 'string' || !accepted.has(item.op_id)) continue;
      const ms = typeof item.at === 'string' ? Date.parse(item.at) : NaN;
      if (Number.isFinite(ms)) age = Math.max(age, now.getTime() - ms);
    }
  }
  return {
    count: accepted.size,
    failed: results.filter((r) => r.status === 'rejected').length,
    age_ms: Math.max(0, Math.round(age)),
  };
}
