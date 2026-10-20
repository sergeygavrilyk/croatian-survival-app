/**
 * Тема слова для «Тренажера» і «Словника» (радісний дизайн, рішення власника 2026-10-20, DESIGN_SYSTEM §3.4).
 * Емодзі слова — це емодзі модуля, де слово вперше трапляється в уроках (A0.1 раніше за A0.7, A0 раніше за A1).
 * Слово поза уроками — плитка з першою літерою (хорватські lj, nj, dž — одна літера).
 * Без БД: на вхід — рядки lesson_items з вкладеними lessons → units → modules (PostgREST).
 */

import { LEVEL_CODES, moduleIcon } from './levels.ts';

export interface WordTheme {
  /** Рівень модуля, напр. «A0» */
  level: string;
  /** Номер модуля в рівні */
  moduleOrder: number;
  /** Емодзі теми модуля */
  icon: string;
  /** Коротка назва модуля без «Модуль A0.7 — », напр. «Hrana (їжа)» */
  title: string;
}

type Rec = Record<string, unknown>;

/** Вкладений обʼєкт PostgREST: буває обʼєктом або масивом з одного елемента. */
function one(value: unknown): Rec | null {
  const v = Array.isArray(value) ? value[0] : value;
  return v && typeof v === 'object' ? (v as Rec) : null;
}

const num = (v: unknown): number => (typeof v === 'number' && Number.isFinite(v) ? v : Number.MAX_SAFE_INTEGER);
/** Неопублікований модуль / урок теми не дає (статус може бути не вибраний — тоді не перевіряємо). */
const published = (r: Rec): boolean => r.status === undefined || r.status === null || r.status === 'PUBLISHED';

/** «Модуль A0.7 — Hrana (їжа)» → «Hrana (їжа)». */
export function moduleShortTitle(title: string | null | undefined): string {
  return (title ?? '').replace(/^\s*модуль\s+[A-C]\d\.\d+\s*[—–-]\s*/i, '').trim();
}

/**
 * Тема кожного слова: lexeme_id → модуль, де слово трапляється найраніше
 * (рівень → модуль → блок → урок). Рядки з неопублікованим уроком чи модулем пропускаємо.
 */
export function wordThemes(rows: readonly unknown[] | null | undefined): Map<string, WordTheme> {
  const best = new Map<string, { rank: number[]; theme: WordTheme }>();
  for (const raw of rows ?? []) {
    const row = one(raw);
    const lexemeId = row?.item_id;
    if (typeof lexemeId !== 'string') continue;
    const lesson = one(row!.lessons);
    const unit = one(lesson?.units);
    const mod = one(unit?.modules);
    if (!lesson || !unit || !mod || !published(lesson) || !published(unit) || !published(mod)) continue;

    const level = typeof mod.level_code === 'string' ? mod.level_code.trim().toUpperCase() : '';
    const levelIdx = (LEVEL_CODES as readonly string[]).indexOf(level);
    if (levelIdx < 0) continue;
    const moduleOrder = num(mod.order_index);
    const rank = [levelIdx, moduleOrder, num(unit.order_index), num(lesson.order_index)];

    const prev = best.get(lexemeId);
    if (prev && !isEarlier(rank, prev.rank)) continue;
    const titleUa = typeof mod.title_ua === 'string' ? mod.title_ua : '';
    const titleHr = typeof mod.title_hr === 'string' ? mod.title_hr : '';
    best.set(lexemeId, {
      rank,
      theme: {
        level,
        moduleOrder,
        icon: moduleIcon(level, moduleOrder, titleHr || titleUa),
        title: moduleShortTitle(titleUa || titleHr),
      },
    });
  }
  return new Map([...best].map(([id, { theme }]) => [id, theme]));
}

function isEarlier(a: number[], b: number[]): boolean {
  for (let i = 0; i < a.length; i++) if (a[i] !== b[i]) return a[i] < b[i];
  return false;
}

/** Перша літера слова для плитки: «ljubav» → «Lj», «džep» → «Dž», «čaj» → «Č», «dobar dan» → «D». */
export function wordInitial(lemma: string | null | undefined): string {
  const text = (lemma ?? '').trim();
  const digraph = /^(dž|lj|nj)/i.exec(text);
  if (digraph) return digraph[1][0].toUpperCase() + digraph[1].slice(1).toLowerCase();
  const first = [...text].find((ch) => /\p{L}|\p{N}/u.test(ch));
  return first ? first.toUpperCase() : '?';
}

/** Поля для запиту теми: lesson_items → lessons → units → modules. */
export const WORD_THEME_SELECT =
  'item_id, lessons!inner(order_index, status, units!inner(order_index, status, modules!inner(level_code, order_index, title_ua, title_hr, status)))';
