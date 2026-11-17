/**
 * Кольори й тематичні іконки рівнів і модулів (рішення власника 2026-10-20, docs/DESIGN_SYSTEM.md §3.4).
 * Кожен рівень A0–B2 має свій колір; кожен модуль — емодзі за темою.
 * Класи записані повністю (не склеюються з частин), щоб Tailwind їх знайшов.
 */

/**
 * ЄДИНИЙ список рівнів застосунку, у порядку (ARCH-03, 2026-11-14). Інших списків рівнів у коді немає:
 * які рівні показувати («Сьогодні», «Перевірки», «Читання», кнопки модулів) — вирішує опублікований контент у базі
 * (`levelsPresent()`), а не перелік у файлі. Тест `lib/levels-source.test.ts` падає, якщо десь з'явиться новий перелік.
 */
export const LEVEL_CODES = ['A0', 'A1', 'A2', 'B1', 'B2'] as const;
export type LevelCode = (typeof LEVEL_CODES)[number];

/** Чи це відомий рівень (A0–B2, точний запис). */
export function isLevelCode(v: unknown): v is LevelCode {
  return typeof v === 'string' && (LEVEL_CODES as readonly string[]).includes(v);
}

/** Місце рівня в порядку (A0 = 0); невідомий — -1. */
export function levelRank(level: string | null | undefined): number {
  return (LEVEL_CODES as readonly string[]).indexOf(level ?? '');
}

/** Наступний рівень (A1 → A2); для останнього чи невідомого — null. */
export function nextLevelCode(level: string | null | undefined): LevelCode | null {
  const i = levelRank(level);
  return i >= 0 && i < LEVEL_CODES.length - 1 ? LEVEL_CODES[i + 1] : null;
}

/** Попередній рівень (A2 → A1); для першого чи невідомого — null. */
export function previousLevelCode(level: string | null | undefined): LevelCode | null {
  const i = levelRank(level);
  return i > 0 ? LEVEL_CODES[i - 1] : null;
}

/** Чи рівень відомий і не вищий за `max` (A0 і A1 при max = 'A1'); невідомий — false. */
export function isLevelAtMost(level: string | null | undefined, max: LevelCode): boolean {
  const i = levelRank(level);
  return i >= 0 && i <= levelRank(max);
}

/**
 * Рівні, що трапляються в рядках з бази (напр. `level_code` опублікованих модулів чи `cefr` перевірок), —
 * без повторів, у порядку LEVEL_CODES; невідомі значення й null пропускаються.
 */
export function levelsPresent(values: Iterable<string | null | undefined>): LevelCode[] {
  const seen = new Set<string>();
  for (const v of values) if (v) seen.add(v);
  return LEVEL_CODES.filter((l) => seen.has(l));
}

/** Найближчий наявний рівень, нижчий за `level` (B1 при наявних A0–A2 → A2); немає — null. */
export function nearestLowerLevel(level: string | null | undefined, available: ReadonlyArray<string>): LevelCode | null {
  const max = levelRank(level);
  if (max < 0) return null;
  for (let i = max - 1; i >= 0; i--) if (available.includes(LEVEL_CODES[i])) return LEVEL_CODES[i];
  return null;
}

export interface LevelStyle {
  /** Коротка назва рівня українською */
  name: string;
  /** Що вміє людина на цьому рівні — підпис під заголовком «Уроки» */
  goal: string;
  /** Суцільний фон з білим текстом (вибрана вкладка, номер уроку) */
  solid: string;
  /** Світлий фон (плитка іконки, бейдж) */
  soft: string;
  /** Текст кольору рівня на світлому фоні */
  ink: string;
  /** Рамка / акцентна смуга */
  line: string;
  /** Колір заповнення смуги прогресу */
  bar: string;
}

export const LEVEL_STYLES: Record<LevelCode, LevelStyle> = {
  A0: {
    name: 'Перші кроки',
    goal: 'Привітатися, порахувати, купити, попросити допомоги',
    solid: 'bg-level-a0 text-white',
    soft: 'bg-level-a0-soft',
    ink: 'text-level-a0-ink',
    line: 'border-level-a0-line',
    bar: 'bg-level-a0',
  },
  A1: {
    name: 'Щоденне життя',
    goal: 'Розповісти про свій день, замовити, домовитися, звернутися до лікаря',
    solid: 'bg-level-a1 text-white',
    soft: 'bg-level-a1-soft',
    ink: 'text-level-a1-ink',
    line: 'border-level-a1-line',
    bar: 'bg-level-a1',
  },
  A2: {
    name: 'Впевнено в побуті',
    goal: 'Подорожі, установи й документи, робота, плани',
    solid: 'bg-level-a2 text-white',
    soft: 'bg-level-a2-soft',
    ink: 'text-level-a2-ink',
    line: 'border-level-a2-line',
    bar: 'bg-level-a2',
  },
  B1: {
    name: 'Самостійно',
    goal: 'Кар’єра, медіа, культура, дискусії',
    solid: 'bg-level-b1 text-white',
    soft: 'bg-level-b1-soft',
    ink: 'text-level-b1-ink',
    line: 'border-level-b1-line',
    bar: 'bg-level-b1',
  },
  B2: {
    name: 'Вільно',
    goal: 'Складні розмови, професійна мова, аргументи, переговори',
    solid: 'bg-level-b2 text-white',
    soft: 'bg-level-b2-soft',
    ink: 'text-level-b2-ink',
    line: 'border-level-b2-line',
    bar: 'bg-level-b2',
  },
};

/** Стиль рівня; невідомий рівень — як A0. */
export function levelStyle(level: string | null | undefined): LevelStyle {
  const code = (level ?? '').trim().toUpperCase();
  return (LEVEL_STYLES as Record<string, LevelStyle>)[code] ?? LEVEL_STYLES.A0;
}

/** Емодзі модулів за темою: рівень → номер модуля (A0 — 11 модулів з A0.6 «Kućni ljubimci», 2026-11-17; A1 — програма v3 з 13 модулів, 2026-10-26). Без прапорів — у Windows вони показуються літерами. */
const MODULE_ICONS: Record<LevelCode, Record<number, string>> = {
  A0: { 1: '👋', 2: '🙋', 3: '🔢', 4: '🕒', 5: '👨‍👩‍👧', 6: '🐾', 7: '🏠', 8: '🍽️', 9: '🛒', 10: '🏙️', 11: '🆘' },
  A1: { 1: '☀️', 2: '🍝', 3: '🛍️', 4: '🚌', 5: '🔑', 6: '💼', 7: '💻', 8: '🩺', 9: '🥂', 10: '🏝️', 11: '🏛️', 12: '🎒', 13: '🏆' },
  A2: { 1: '📸', 2: '✈️', 3: '🧑‍💻', 4: '📄', 5: '💊', 6: '🤝', 7: '🛠️', 8: '🗓️', 9: '💭', 10: '🏆' },
  B1: { 1: '🌱', 2: '📈', 3: '🏛️', 4: '📰', 5: '🎭', 6: '🏃', 7: '🌿', 8: '💞', 9: '🗣️', 10: '🏆' },
  B2: { 1: '💬', 2: '📊', 3: '🏛️', 4: '🗳️', 5: '💶', 6: '📺', 7: '🎨', 8: '🔬', 9: '🌌', 10: '⚖️', 11: '🤝', 12: '🏆' },
};

/** Запасний варіант за словами в назві — для нових модулів, яких ще немає в таблиці вище. */
const KEYWORD_ICONS: ReadonlyArray<[RegExp, string]> = [
  [/підсумок|ponavljanje|provjera/i, '🏆'],
  [/кафе|ресторан|їж|hrana|restoran|kafić/i, '🍽️'],
  [/сім|родин|obitelj/i, '👨‍👩‍👧'],
  [/тварин|ljubim|životinj/i, '🐾'],
  [/транспорт|prijevoz|promet|auto/i, '🚌'],
  [/робот|кар.?єр|posao|ured|karijer/i, '💼'],
  [/подорож|putovanj|hotel/i, '✈️'],
  [/здоров|лікар|zdravlj|bolnic/i, '🩺'],
  [/покупк|гроші|kupovin|novac/i, '🛒'],
  [/житл|дім|stanovanj|dom\b/i, '🏠'],
  [/місто|grad/i, '🏙️'],
  [/далмаці|dalmacij|задар|zadar|море|more\b/i, '⛵'],
  [/культур|kultur/i, '🎭'],
  [/медіа|medij/i, '📰'],
];

/** Емодзі модуля: за рівнем і номером, інакше за назвою, інакше 📚. */
export function moduleIcon(level: string | null | undefined, order: number | null | undefined, title?: string | null): string {
  const code = (level ?? '').trim().toUpperCase() as LevelCode;
  const byOrder = MODULE_ICONS[code]?.[order ?? -1];
  if (byOrder) return byOrder;
  const text = title ?? '';
  for (const [re, icon] of KEYWORD_ICONS) if (re.test(text)) return icon;
  return '📚';
}

/** Знак перевірки рівня (§60): перевірка модуля — емодзі модуля, середина рівня — 🚩, фінал — 🏆. */
export function assessmentIcon(kind: string, level: string | null | undefined, moduleOrder?: number | null): string {
  if (kind === 'final') return '🏆';
  if (kind === 'mid') return '🚩';
  return moduleIcon(level, moduleOrder);
}
