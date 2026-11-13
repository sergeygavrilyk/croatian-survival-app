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
