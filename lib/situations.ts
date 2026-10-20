/**
 * Довідник ситуацій для розділу «Ситуації» (docs/DESIGN_SYSTEM.md §9.4).
 * Ключ — значення колонки `situation` у `phrases` і `conversations`.
 * Назви й знаки ситуацій живуть лише тут, а не в компонентах.
 */
import { countUk } from './format.ts';

export const CEFR_ORDER = ['A0', 'A1', 'A2', 'B1', 'B2'] as const;

export interface SituationInfo {
  code: string;
  /** Назва в інтерфейсі (українською) */
  label: string;
  /** Знак категорії (емодзі дозволені лише тут — DESIGN_SYSTEM §8) */
  emoji: string;
}

export const SITUATIONS: readonly SituationInfo[] = [
  { code: 'basics', label: 'Основи', emoji: '👋' },
  { code: 'shopping', label: 'Покупки', emoji: '🛒' },
  { code: 'cafe_restaurant', label: 'Кафе і ресторан', emoji: '☕' },
  { code: 'transport', label: 'Транспорт і авто', emoji: '🚌' },
  { code: 'car_service', label: 'СТО', emoji: '🔧' },
  { code: 'housing', label: 'Житло', emoji: '🏠' },
  { code: 'health', label: "Здоров'я і аптека", emoji: '🏥' },
  { code: 'vet', label: 'Ветеринар', emoji: '🐾' },
  { code: 'administration', label: 'Документи (MUP, обрт)', emoji: '📄' },
  { code: 'bank', label: 'Банк', emoji: '🏦' },
  { code: 'border', label: 'Кордон', emoji: '🛂' },
  { code: 'work', label: 'Робота', emoji: '💼' },
  { code: 'it_work', label: 'IT-робота', emoji: '💻' },
  { code: 'travel', label: 'Подорожі', emoji: '🧳' },
  { code: 'small_talk', label: 'Розмовні слівця', emoji: '💬' },
];

const BY_CODE = new Map(SITUATIONS.map((s) => [s.code, s]));

/** Дані ситуації за кодом; невідомий код показуємо як є, щоб нічого не загубити. */
export function situationInfo(code: string): SituationInfo {
  return BY_CODE.get(code) ?? { code, label: code, emoji: '💬' };
}

export interface SituationSummary extends SituationInfo {
  phrases: number;
  dialogues: number;
  /** Рівні контенту в ситуації, від нижчого до вищого */
  levels: string[];
}

/**
 * Зведення для списку ситуацій: скільки фраз і діалогів у кожній.
 * Порядок — як у SITUATIONS, невідомі коди в кінці; порожні ситуації не показуємо.
 */
export function summarizeSituations(
  phrases: ReadonlyArray<{ situation: string | null; cefr: string | null }>,
  dialogues: ReadonlyArray<{ situation: string | null; level: string | null }>,
): SituationSummary[] {
  const acc = new Map<string, { phrases: number; dialogues: number; levels: Set<string> }>();
  const bucket = (code: string) => {
    let b = acc.get(code);
    if (!b) acc.set(code, (b = { phrases: 0, dialogues: 0, levels: new Set() }));
    return b;
  };
  for (const p of phrases) {
    if (!p.situation) continue;
    const b = bucket(p.situation);
    b.phrases += 1;
    if (p.cefr) b.levels.add(p.cefr);
  }
  for (const d of dialogues) {
    if (!d.situation) continue;
    const b = bucket(d.situation);
    b.dialogues += 1;
    if (d.level) b.levels.add(d.level);
  }

  const known = SITUATIONS.map((s) => s.code);
  const codes = [...known.filter((c) => acc.has(c)), ...[...acc.keys()].filter((c) => !known.includes(c)).sort()];
  return codes.map((code) => {
    const b = acc.get(code)!;
    const levels = [...b.levels].sort(
      (x, y) => (CEFR_ORDER as readonly string[]).indexOf(x) - (CEFR_ORDER as readonly string[]).indexOf(y),
    );
    return { ...situationInfo(code), phrases: b.phrases, dialogues: b.dialogues, levels };
  });
}

/** Підпис картки ситуації: «A0–A1 · 9 фраз · 1 діалог». */
export function situationMeta(s: Pick<SituationSummary, 'phrases' | 'dialogues' | 'levels'>): string {
  const parts: string[] = [];
  if (s.levels.length === 1) parts.push(s.levels[0]);
  else if (s.levels.length > 1) parts.push(`${s.levels[0]}–${s.levels[s.levels.length - 1]}`);
  if (s.phrases > 0) parts.push(countUk(s.phrases, ['фраза', 'фрази', 'фраз']));
  if (s.dialogues > 0) parts.push(countUk(s.dialogues, ['діалог', 'діалоги', 'діалогів']));
  return parts.join(' · ');
}

/** Лише кількість фраз і діалогів: «9 фраз · 1 діалог» (рівні показуємо кольоровими бейджами). */
export function situationCounts(s: Pick<SituationSummary, 'phrases' | 'dialogues'>): string {
  const parts: string[] = [];
  if (s.phrases > 0) parts.push(countUk(s.phrases, ['фраза', 'фрази', 'фраз']));
  if (s.dialogues > 0) parts.push(countUk(s.dialogues, ['діалог', 'діалоги', 'діалогів']));
  return parts.join(' · ');
}

/** Рівні з рядків (фрази, діалоги) — без повторів, від нижчого до вищого; невідомі й порожні пропускаємо. */
export function sortedLevels(levels: ReadonlyArray<string | null | undefined>): string[] {
  const order = CEFR_ORDER as readonly string[];
  return [...new Set(levels.filter((l): l is string => Boolean(l) && order.includes(l as string)))].sort(
    (a, b) => order.indexOf(a) - order.indexOf(b),
  );
}

/** Групи ситуацій на екрані «Ситуації» (радісний стиль 2026-10-20): щодня → дім і здоров’я → дорога → документи й робота. */
export const SITUATION_GROUPS: ReadonlyArray<{ key: string; label: string; codes: readonly string[] }> = [
  { key: 'everyday', label: 'Щодня', codes: ['basics', 'shopping', 'cafe_restaurant', 'small_talk'] },
  { key: 'home', label: 'Дім і здоров’я', codes: ['housing', 'health', 'vet'] },
  { key: 'road', label: 'Дорога й подорожі', codes: ['transport', 'car_service', 'travel', 'border'] },
  { key: 'papers', label: 'Документи й робота', codes: ['administration', 'bank', 'work', 'it_work'] },
];

/** Розкласти ситуації за групами (порядок усередині — як у списку); невідомі коди — в «Інше»; порожні групи не показуємо. */
export function groupSituations<T extends { code: string }>(items: readonly T[]): Array<{ key: string; label: string; items: T[] }> {
  const known = new Set(SITUATION_GROUPS.flatMap((g) => g.codes));
  const groups = SITUATION_GROUPS.map((g) => ({ key: g.key, label: g.label, items: items.filter((s) => g.codes.includes(s.code)) }));
  groups.push({ key: 'other', label: 'Інше', items: items.filter((s) => !known.has(s.code)) });
  return groups.filter((g) => g.items.length > 0);
}

/** Чи схожий рядок на код ситуації (захист адреси /situations/[code]). */
export function isSituationCode(code: string): boolean {
  return /^[a-z][a-z_]{1,39}$/.test(code);
}

/** Чи є такий код серед відомих ситуацій. */
export function isKnownSituation(code: string): boolean {
  return BY_CODE.has(code);
}
