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

/** Чи схожий рядок на код ситуації (захист адреси /situations/[code]). */
export function isSituationCode(code: string): boolean {
  return /^[a-z][a-z_]{1,39}$/.test(code);
}

/** Чи є такий код серед відомих ситуацій. */
export function isKnownSituation(code: string): boolean {
  return BY_CODE.has(code);
}
