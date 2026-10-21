/**
 * Поточний час у мілісекундах — для тривалості в аналітиці (обробники натисків, ефекти).
 * Не для рендеру: значення щоразу інше. Окрема функція, бо React Compiler (eslint react-hooks/purity)
 * помилково вважає деякі асинхронні обробники кодом рендеру й не дозволяє в них Date.now().
 */
export function nowMs(): number {
  return Date.now();
}

const DAY_MS = 24 * 60 * 60 * 1000;

/** Момент `days` діб тому в ISO (для фільтрів «за останній тиждень» на сервері). */
export function daysAgoIso(days: number, now: number = nowMs()): string {
  return new Date(now - days * DAY_MS).toISOString();
}
