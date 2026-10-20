/**
 * Кольори й тематичні іконки рівнів і модулів (рішення власника 2026-10-20, docs/DESIGN_SYSTEM.md §3.4).
 * Кожен рівень A0–B2 має свій колір; кожен модуль — емодзі за темою.
 * Класи записані повністю (не склеюються з частин), щоб Tailwind їх знайшов.
 */

export const LEVEL_CODES = ['A0', 'A1', 'A2', 'B1', 'B2'] as const;
export type LevelCode = (typeof LEVEL_CODES)[number];

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

/** Емодзі модулів за темою: рівень → номер модуля (програма в базі на 2026-10-20). Без прапорів — у Windows вони показуються літерами. */
const MODULE_ICONS: Record<LevelCode, Record<number, string>> = {
  A0: { 1: '👋', 2: '🙋', 3: '🔢', 4: '🕒', 5: '👨‍👩‍👧', 6: '🏠', 7: '🍽️', 8: '🛒', 9: '🏙️', 10: '🆘' },
  A1: { 1: '☀️', 2: '🍝', 3: '🛍️', 4: '🚌', 5: '🔑', 6: '💼', 7: '🩺', 8: '🥂', 9: '🏝️', 10: '🏆' },
  A2: { 1: '📸', 2: '✈️', 3: '🧑‍💻', 4: '📄', 5: '💊', 6: '🤝', 7: '🛠️', 8: '🗓️', 9: '💭', 10: '🏆' },
  B1: { 1: '🌱', 2: '📈', 3: '🏛️', 4: '📰', 5: '🎭', 6: '🏃', 7: '🌿', 8: '💞', 9: '🗣️', 10: '🏆' },
  B2: { 1: '💬', 2: '📊', 3: '🏛️', 4: '🗳️', 5: '💶', 6: '📺', 7: '🎨', 8: '🔬', 9: '🌌', 10: '⚖️', 11: '🤝', 12: '🏆' },
};

/** Запасний варіант за словами в назві — для нових модулів, яких ще немає в таблиці вище. */
const KEYWORD_ICONS: ReadonlyArray<[RegExp, string]> = [
  [/підсумок|ponavljanje|provjera/i, '🏆'],
  [/кафе|ресторан|їж|hrana|restoran|kafić/i, '🍽️'],
  [/сім|родин|obitelj/i, '👨‍👩‍👧'],
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
