/**
 * Оновлення збережених сторінок після оновлення застосунку (§76, рішення власника 2026-11-16: варіант «а»).
 *
 * Чому: збережена сторінка (HTML) посилається на файли (JS) своєї збірки. Нова версія застосунку прибирає з
 * телефона файли старої — і сторінка, збережена до оновлення, без мережі показує текст, але кнопки не працюють.
 * Тому, щойно телефон відкрив нову версію з мережею, він тихо оновлює до REFRESH_LIMIT найсвіжіших збережених
 * сторінок (кеш `pages`). Сторінку ситуації «лише фрази» оновлюємо так само — лише фразами.
 *
 * Логіка без браузера; тести — lib/offline-refresh.test.ts; браузер — lib/offline-refresh-client.ts.
 */
import { PREFETCH_HEADER_VALUE, REFRESH_HEADER_VALUE } from './offline-prefetch.ts';

/** Скільки найсвіжіших збережених сторінок оновлюємо (решта оновиться, коли людина їх відкриє з мережею). */
export const REFRESH_LIMIT = 30;
/** Яку збірку вже обслужено (localStorage). */
export const BUILD_KEY = 'cs_offline_build_v1';
/** Позначка копії «лише фрази» на сторінці ситуації (SituationView). */
export const OFFLINE_COPY_PHRASES = 'phrases';
export const PHRASES_MARKER = `data-offline-copy="${OFFLINE_COPY_PHRASES}"`;

export type BuildAction = 'none' | 'record' | 'refresh';

/**
 * Що робити з цією збіркою: перший запуск — лише запам'ятати (усе збережене вже з неї);
 * інша збірка, ніж запам'ятована, — оновити сторінки; та сама — нічого. Невідома збірка — нічого.
 */
export function buildAction(stored: string | null | undefined, current: string | null | undefined): BuildAction {
  if (!current) return 'none';
  if (!stored) return 'record';
  return stored === current ? 'none' : 'refresh';
}

/** Сторінки, які не оновлюємо: API, вхід, адмінка. */
function skipPath(path: string): boolean {
  return path.startsWith('/api/') || path.startsWith('/login') || path.startsWith('/auth') || path.startsWith('/admin');
}

/**
 * Які сторінки оновити: адреси з кешу (у порядку, як їх клали — останні найсвіжіші), свого сайту,
 * без повторів, найсвіжіші першими, не більше `limit`. Повертає шлях із параметрами (`/lessons?level=A1`).
 */
export function pickRefreshPaths(urls: readonly string[], origin: string, limit = REFRESH_LIMIT): string[] {
  const seen = new Set<string>();
  const out: string[] = [];
  for (let i = urls.length - 1; i >= 0 && out.length < limit; i--) {
    let u: URL;
    try {
      u = new URL(urls[i]);
    } catch {
      continue;
    }
    if (u.origin !== origin) continue;
    const path = u.pathname + u.search;
    if (skipPath(u.pathname) || seen.has(path)) continue;
    seen.add(path);
    out.push(path);
  }
  return out;
}

/** Як оновити сторінку: ситуацію «лише фрази» — так само лише фразами, решту — повністю. */
export function refreshHeaderValue(path: string, cachedHtml: string | null | undefined): string {
  if (path.startsWith('/situations/') && cachedHtml?.includes(PHRASES_MARKER)) return PREFETCH_HEADER_VALUE;
  return REFRESH_HEADER_VALUE;
}

export type RefreshOutcome = 'updated' | 'gone' | 'signed_out' | 'failed';

/** Відповідь сервера → що сталося: 200 — оновлено; 404 / 410 — сторінки вже немає; переадресація — вхід скінчився. */
export function refreshOutcome(status: number, type?: string): RefreshOutcome {
  if (status === 200) return 'updated';
  if (status === 404 || status === 410) return 'gone';
  if (type === 'opaqueredirect' || (status >= 300 && status < 400)) return 'signed_out';
  return 'failed';
}
