/**
 * Чиста логіка сеансу розпізнавання мовлення (без браузера — тестується в speech-session.test.ts).
 *
 * Safari (iPhone і Mac) 2026-10-20: вправи «Скажіть уголос» не працювали, хоча в Chrome усе гаразд.
 * Причини, які закриваємо тут:
 *   * Safari часто не позначає результат як остаточний (isFinal) — розпізнаний текст приходить лише як проміжний,
 *     і після кінця слухання ми отримували порожній результат («Нічого не почули»). Тепер беремо й проміжний текст.
 *   * Safari повторно надсилає той самий результат — рахуємо фрагменти за індексом, а не додаємо щоразу.
 *   * Відмова в доступі в Safari — це і дозвіл сайту на мікрофон, і вимкнене диктування; підказка — під пристрій.
 */

/**
 * Варіанти тексту після кінця слухання.
 * finals — остаточні фрагменти (на кожен — варіанти, найімовірніший перший), interim — останній проміжний текст.
 */
export function pickTranscripts(finals: ReadonlyArray<ReadonlyArray<string>>, interim: string): string[] {
  const parts = finals.map((alts) => alts.map((a) => a.trim()).filter(Boolean)).filter((alts) => alts.length > 0);
  const tail = interim.replace(/\s+/g, ' ').trim();
  if (parts.length === 0) return tail ? [tail] : [];
  if (parts.length === 1 && !tail) return [...parts[0]];
  return [[...parts.map((alts) => alts[0]), tail].join(' ').replace(/\s+/g, ' ').trim()];
}

export type MicPlatform = 'ios_safari' | 'ios_chrome' | 'mac_safari' | 'other';

export function micPlatform(userAgent: string): MicPlatform {
  const ua = userAgent || '';
  if (/iPhone|iPad|iPod/.test(ua)) return /CriOS/.test(ua) ? 'ios_chrome' : 'ios_safari';
  if (/Macintosh/.test(ua) && /Safari\//.test(ua) && !/Chrome\/|Chromium|Edg\/|Firefox\/|OPR\//.test(ua)) return 'mac_safari';
  return 'other';
}

/** Що робити, якщо немає доступу до мікрофона (помилка not-allowed), — під пристрій і браузер. */
export function micAccessHelp(userAgent: string, tail = ''): string {
  const start = 'Немає доступу до мікрофона.';
  const end = tail ? ` ${tail}` : '';
  switch (micPlatform(userAgent)) {
    case 'ios_safari':
      return `${start} На iPhone: «Параметри» → Safari → «Мікрофон» → «Дозволити», а також увімкніть диктування: «Параметри» → «Загальні» → «Клавіатура» → «Диктування». Потім оновіть сторінку.${end}`;
    case 'ios_chrome':
      return `${start} На iPhone: «Параметри» → Chrome → «Мікрофон» — увімкнути, а також увімкніть диктування: «Параметри» → «Загальні» → «Клавіатура» → «Диктування». Потім оновіть сторінку.${end}`;
    case 'mac_safari':
      return `${start} У Safari: «Safari» → «Налаштування» → «Вебсайти» → «Мікрофон» → «Дозволити»; також увімкніть диктування («Системні параметри» → «Клавіатура»).${end}`;
    default:
      return `${start} Дозвольте його в налаштуваннях браузера (значок біля адреси сторінки).${end}`;
  }
}
