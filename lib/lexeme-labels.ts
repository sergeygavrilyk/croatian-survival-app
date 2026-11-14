// Мітки живої лексики: register / regionality / usage_tags (docs/LEARNING_SPEC.md §18).
// Переліки — ті самі, що в CHECK міграції M24 і в scripts/lexeme_checks.py; з M25 усі три мітки обов'язкові (NOT NULL).
// Підписи — як у DESIGN_SYSTEM.md («Позначка категорії слова»).

export const REGISTERS = ['standard', 'formal', 'informal', 'colloquial', 'slang', 'vulgar'] as const;
export const REGIONS = ['general', 'Zagreb', 'Zagorje', 'Dalmatia', 'Istria', 'Kvarner', 'Slavonia', 'Lika', 'Dubrovnik'] as const;
export const USAGE_TAGS = [
  'youth_slang', 'internet_slang', 'professional_jargon', 'anglicism', 'italianism', 'germanism', 'turkism',
  'idiom', 'kajkavian', 'chakavian', 'offensive',
] as const;

export type Register = (typeof REGISTERS)[number];
export type Region = (typeof REGIONS)[number];
export type UsageTag = (typeof USAGE_TAGS)[number];

export interface LexemeLabels {
  register: Register;
  regionality: Region;
  usage_tags: UsageTag[];
}

/** Звичайне слово: стандартне, загальне, без ознак. Значення явне — порожніх міток у базі немає. */
export const DEFAULT_LABELS: LexemeLabels = { register: 'standard', regionality: 'general', usage_tags: [] };

export const REGISTER_LABELS: Record<Register, string> = {
  standard: 'стандартне',
  formal: 'офіційне',
  informal: 'неофіційне',
  colloquial: 'розмовне',
  slang: 'сленг',
  vulgar: 'грубо (18+)',
};

export const REGION_LABELS: Record<Region, string> = {
  general: 'загальне',
  Zagreb: 'Загреб',
  Zagorje: 'Загір’я',
  Dalmatia: 'Далмація',
  Istria: 'Істрія',
  Kvarner: 'Кварнер',
  Slavonia: 'Славонія',
  Lika: 'Ліка',
  Dubrovnik: 'Дубровник',
};

export const USAGE_TAG_LABELS: Record<UsageTag, string> = {
  youth_slang: 'молодіжне',
  internet_slang: 'інтернет-сленг',
  professional_jargon: 'професійне',
  anglicism: 'англіцизм',
  italianism: 'італізм',
  germanism: 'германізм',
  turkism: 'туркізм',
  idiom: 'ідіома',
  kajkavian: 'кайкавське',
  chakavian: 'чакавське',
  offensive: 'образа',
};

const includes = <T extends string>(list: readonly T[], v: unknown): v is T => typeof v === 'string' && (list as readonly string[]).includes(v);

/** Помилки міток (порожньо — усе гаразд). Ті самі правила, що check_labels() у scripts/lexeme_checks.py. */
export function validateLabels(input: { register?: unknown; regionality?: unknown; usage_tags?: unknown }): string[] {
  const errors: string[] = [];
  if (input.register == null || input.register === '') errors.push('Оберіть регістр (звичайне слово — «стандартне»).');
  else if (!includes(REGISTERS, input.register)) errors.push(`Невідомий регістр «${String(input.register)}».`);

  if (input.regionality == null || input.regionality === '') errors.push('Оберіть регіон (звичайне слово — «загальне»).');
  else if (!includes(REGIONS, input.regionality)) errors.push(`Невідомий регіон «${String(input.regionality)}».`);

  const tags = input.usage_tags;
  if (!Array.isArray(tags)) errors.push('Ознаки — список (якщо ознак немає — порожній).');
  else {
    const unknown = tags.filter((t) => !includes(USAGE_TAGS, t));
    if (unknown.length) errors.push(`Невідомі ознаки: ${unknown.map(String).join(', ')}.`);
    if (new Set(tags).size !== tags.length) errors.push('Ознака повторюється.');
  }
  return errors;
}

/** Увімкнути / вимкнути ознаку; результат — без повторів, у порядку переліку USAGE_TAGS. */
export function toggleTag(tags: readonly UsageTag[], tag: UsageTag): UsageTag[] {
  const set = new Set(tags);
  if (set.has(tag)) set.delete(tag);
  else set.add(tag);
  return USAGE_TAGS.filter((t) => set.has(t));
}

// ---------------------------------------------------------------- позначка категорії (DESIGN_SYSTEM.md §3.4)

/** Чип позначки слова: текст і тон (`warning` — «образа», «грубо»: увага, не помилка). */
export interface LabelChip {
  key: string;
  text: string;
  tone: 'neutral' | 'warning';
}

/**
 * Мітки з рядка бази. Невідомі значення (старі пакети, помилка даних) відкидаємо, а не показуємо сирими:
 * регістр → `standard`, регіон → `general`, невідомі ознаки — без них.
 */
export function readLabels(row: { register?: unknown; regionality?: unknown; usage_tags?: unknown }): LexemeLabels {
  const tags = Array.isArray(row.usage_tags) ? row.usage_tags : [];
  return {
    register: includes(REGISTERS, row.register) ? row.register : 'standard',
    regionality: includes(REGIONS, row.regionality) ? row.regionality : 'general',
    usage_tags: USAGE_TAGS.filter((t) => tags.includes(t)),
  };
}

/**
 * Чипи категорії слова: регістр (крім «стандартне»), «регіонально · Далмація» (крім «загальне»), ознаки в порядку переліку.
 * Звичайне слово — порожній список (нічого не показуємо).
 */
export function labelChips(labels: LexemeLabels): LabelChip[] {
  const chips: LabelChip[] = [];
  if (labels.register !== 'standard') {
    chips.push({ key: `register:${labels.register}`, text: REGISTER_LABELS[labels.register], tone: labels.register === 'vulgar' ? 'warning' : 'neutral' });
  }
  if (labels.regionality !== 'general') {
    chips.push({ key: `region:${labels.regionality}`, text: `регіонально · ${REGION_LABELS[labels.regionality]}`, tone: 'neutral' });
  }
  for (const tag of labels.usage_tags) {
    chips.push({ key: `tag:${tag}`, text: USAGE_TAG_LABELS[tag], tone: tag === 'offensive' ? 'warning' : 'neutral' });
  }
  return chips;
}

/** Текст для читача з екрана: «Категорія: розмовне, італізм» (порожньо — звичайне слово). */
export function labelsAriaText(chips: readonly LabelChip[]): string {
  return chips.length ? `Категорія: ${chips.map((c) => c.text).join(', ')}` : '';
}

/** Фільтр «Категорія» у «Словнику» (рішення власника 2026-11-13). Порядок — як на екрані. */
export const WORD_CATEGORIES = [
  { id: 'all', label: 'Усі' },
  { id: 'informal', label: 'Неофіційне' },
  { id: 'colloquial', label: 'Розмовне' },
  { id: 'slang', label: 'Сленг' },
  { id: 'regional', label: 'Регіональне' },
  { id: 'dialect', label: 'Наріччя' },
  { id: 'loanword', label: 'Запозичення' },
  { id: 'idiom', label: 'Ідіоми' },
  { id: 'offensive', label: 'Образа' },
] as const;

export type WordCategory = (typeof WORD_CATEGORIES)[number]['id'];

export function isWordCategory(v: unknown): v is WordCategory {
  return typeof v === 'string' && WORD_CATEGORIES.some((c) => c.id === v);
}

/** Запозичення — ознаки походження (LEARNING_SPEC.md §18). */
export const LOANWORD_TAGS: readonly UsageTag[] = ['anglicism', 'italianism', 'germanism', 'turkism'];

/**
 * Умова запиту до `lexemes` для категорії — у вигляді методів supabase-js (`eq`, `neq`, `overlaps`, `contains`, `or`).
 * `null` — без умови («Усі»). Сленг — регістр `slang` або ознака молодіжного / інтернет-сленгу.
 */
export type CategoryFilter =
  | { method: 'eq' | 'neq'; column: 'register' | 'regionality'; value: string }
  | { method: 'overlaps' | 'contains'; column: 'usage_tags'; value: UsageTag[] }
  | { method: 'or'; value: string };

export function categoryFilter(category: WordCategory): CategoryFilter | null {
  switch (category) {
    case 'all':
      return null;
    case 'informal':
      return { method: 'eq', column: 'register', value: 'informal' };
    case 'colloquial':
      return { method: 'eq', column: 'register', value: 'colloquial' };
    case 'slang':
      return { method: 'or', value: 'register.eq.slang,usage_tags.ov.{youth_slang,internet_slang}' };
    case 'regional':
      return { method: 'neq', column: 'regionality', value: 'general' };
    case 'dialect':
      return { method: 'overlaps', column: 'usage_tags', value: ['kajkavian', 'chakavian'] };
    case 'loanword':
      return { method: 'overlaps', column: 'usage_tags', value: [...LOANWORD_TAGS] };
    case 'idiom':
      return { method: 'contains', column: 'usage_tags', value: ['idiom'] };
    case 'offensive':
      return { method: 'contains', column: 'usage_tags', value: ['offensive'] };
  }
}

/** Чи підходить слово під категорію — та сама умова, що й `categoryFilter` (для тесту й перевірки на клієнті). */
export function matchesCategory(labels: LexemeLabels, category: WordCategory): boolean {
  const has = (tags: readonly UsageTag[]) => tags.some((t) => labels.usage_tags.includes(t));
  switch (category) {
    case 'all':
      return true;
    case 'informal':
    case 'colloquial':
      return labels.register === category;
    case 'slang':
      return labels.register === 'slang' || has(['youth_slang', 'internet_slang']);
    case 'regional':
      return labels.regionality !== 'general';
    case 'dialect':
      return has(['kajkavian', 'chakavian']);
    case 'loanword':
      return has(LOANWORD_TAGS);
    case 'idiom':
      return has(['idiom']);
    case 'offensive':
      return has(['offensive']);
  }
}

/**
 * Слова `vulgar` бачить лише той, хто ввімкнув «Показувати контент 18+» у профілі (`profiles.adult_content`, M26;
 * DESIGN_SYSTEM.md §3.4). `offensive` — видно всім, з позначкою.
 */
export function isVisibleWord(labels: LexemeLabels, adultContent = false): boolean {
  return adultContent || labels.register !== 'vulgar';
}

/**
 * Перемикач «Показувати контент 18+» з рядка `profiles` (M26). Лише явне `true` вмикає 18+:
 * немає рядка, немає колонки (M26 ще не запущено), помилка — вимкнено.
 */
export function adultContentFrom(row: unknown): boolean {
  return !!row && typeof row === 'object' && (row as { adult_content?: unknown }).adult_content === true;
}

/** Порожній список у категорії: що сказати людині. */
export function emptyCategoryText(category: WordCategory): string {
  const name = WORD_CATEGORIES.find((c) => c.id === category)?.label ?? '';
  return `У категорії «${name}» таких слів поки немає. Спробуйте «Усі» категорії або інший рівень.`;
}
