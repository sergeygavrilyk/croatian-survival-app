/**
 * Чиста логіка сеансу розпізнавання мовлення (без браузера — тестується в speech-session.test.ts).
 *
 * Safari (iPhone і Mac) 2026-10-20: вправи «Скажіть уголос» не працювали, хоча в Chrome усе гаразд.
 * Причини, які закриваємо тут:
 *   * Safari часто не позначає результат як остаточний (isFinal) — розпізнаний текст приходить лише як проміжний,
 *     і після кінця слухання ми отримували порожній результат («Нічого не почули»). Тепер беремо й проміжний текст.
 *   * Safari повторно надсилає той самий результат — рахуємо фрагменти за індексом, а не додаємо щоразу.
 *   * Відмова в доступі в Safari — це і дозвіл сайту на мікрофон, і вимкнене диктування; підказка — під пристрій.
 *
 * 2026-10-21: мікрофон у Safari не працював і після всіх дозволів. Додано: перед слуханням зупиняємо озвучення
 * (utils/speech.ts), а якщо застосунок відкрито з іконки на екрані «Додому» (режим PWA), підказка радить відкрити
 * сайт у самому Safari — у такому режимі WebKit часто не дає розпізнавання мовлення.
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

/**
 * Що робити, якщо немає доступу до мікрофона (помилка not-allowed), — під пристрій і браузер.
 * standalone — сторінку відкрито як застосунок з іконки (PWA), а не у вкладці браузера.
 * rawCode — справжній код браузера: `not-allowed` (сайту не дали мікрофон) чи `service-not-allowed`
 * (у Safari: Safari не дозволено «Розпізнавання мовлення» — підтверджено на iPhone власника 2026-10-21, — вимкнене диктування, обмеження «Екранного часу»). Показуємо його в кінці — для діагностики.
 */
export function micAccessHelp(userAgent: string, tail = '', standalone = false, rawCode = ''): string {
  const platform = micPlatform(userAgent);
  const code = rawCode ? ` (код: ${rawCode})` : '';
  const end = `${tail ? ` ${tail}` : ''}${code}`;
  const ios = platform === 'ios_safari' || platform === 'ios_chrome';
  if (rawCode === 'service-not-allowed' && !standalone && (ios || platform === 'mac_safari')) {
    return ios
      ? `Safari не дає розпізнавання мовлення, хоча мікрофон дозволено. Дозвольте Safari розпізнавання мовлення: «Параметри» → «Конфіденційність і безпека» → «Розпізнавання мовлення» → Safari; якщо ввімкнено «Екранний час» — ще «Екранний час» → «Вміст і приватність» → «Розпізнавання мовлення» → Safari. Також має бути ввімкнене диктування («Параметри» → «Загальні» → «Клавіатура»). Потім закрийте вкладку й відкрийте сайт знову.${end}`
      : `Safari не дає розпізнавання мовлення, хоча мікрофон дозволено. Увімкніть диктування: «Системні параметри» → «Клавіатура» → «Диктування», і перезапустіть Safari.${end}`;
  }
  const start = 'Немає доступу до мікрофона.';
  if (standalone && platform !== 'other') {
    const where = platform === 'mac_safari' ? 'з Dock' : 'з іконки на екрані «Додому»';
    return `${start} Застосунок відкрито ${where} — у такому режимі Safari часто не дає мікрофон для розпізнавання мовлення. Відкрийте сайт у самому Safari (у вкладці) і спробуйте там.${end}`;
  }
  switch (platform) {
    case 'ios_safari':
      return `${start} Для цього сайту: натисніть «аА» в адресному рядку → «Параметри вебсайту» → «Мікрофон» → «Дозволити». Загалом: «Параметри» → Safari → «Мікрофон» → «Дозволити», і увімкніть диктування: «Параметри» → «Загальні» → «Клавіатура» → «Диктування». Потім оновіть сторінку.${end}`;
    case 'ios_chrome':
      return `${start} На iPhone: «Параметри» → Chrome → «Мікрофон» — увімкнути, а також увімкніть диктування: «Параметри» → «Загальні» → «Клавіатура» → «Диктування». Потім оновіть сторінку.${end}`;
    case 'mac_safari':
      return `${start} У Safari: «Safari» → «Налаштування» → «Вебсайти» → «Мікрофон» → «Дозволити»; також увімкніть диктування («Системні параметри» → «Клавіатура»).${end}`;
    default:
      return `${start} Дозвольте його в налаштуваннях браузера (значок біля адреси сторінки).${end}`;
  }
}
