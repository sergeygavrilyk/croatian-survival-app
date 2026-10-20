/**
 * Талісман-далматинець (рішення власника 2026-10-20): користувач обирає одного з трьох мультяшних далматинців —
 * Pjegica, Šime або Točka (ескізи з полотна «Талісман-далматинець»).
 * Вибір — у профілі (`profiles.mascot`, міграція M18); копія в браузері — для екранів, які працюють офлайн
 * (святковий екран після уроку). Логіка без БД — тести в lib/mascot.test.ts.
 */

export const MASCOT_KINDS = ['pjegica', 'sime', 'tocka'] as const;
export type MascotKind = (typeof MASCOT_KINDS)[number];

/** Коли користувач ще не обрав — показуємо Pjegica. */
export const DEFAULT_MASCOT: MascotKind = 'pjegica';

export interface MascotInfo {
  kind: MascotKind;
  /** Ім'я хорватською (у вибір — з lang="hr") */
  name: string;
  /** Що означає ім'я / хто це */
  gloss: string;
  /** Коротко, чим особливий */
  details: string;
  /** Малюнок SVG 200×200 (public/mascot) */
  src: string;
}

export const MASCOTS: Record<MascotKind, MascotInfo> = {
  pjegica: {
    kind: 'pjegica',
    name: 'Pjegica',
    gloss: '«Плямочка»',
    details: 'червона краватка, махає лапою',
    src: '/mascot/pjegica.svg',
  },
  sime: {
    kind: 'sime',
    name: 'Šime',
    gloss: 'далматинське ім’я',
    details: 'моряк у тільняшці',
    src: '/mascot/sime.svg',
  },
  tocka: {
    kind: 'tocka',
    name: 'Točka',
    gloss: '«Крапка»',
    details: 'простий значок із жетоном',
    src: '/mascot/tocka.svg',
  },
};

/** Перші макети (2026-10-20) зберігали female / male — у браузері таке значення ще могло лишитися. */
const LEGACY: Record<string, MascotKind> = { female: 'pjegica', male: 'sime' };

/** Значення з бази чи браузера → відомий талісман або null (не обрано / невідоме). */
export function parseMascot(value: unknown): MascotKind | null {
  if (typeof value !== 'string') return null;
  if ((MASCOT_KINDS as readonly string[]).includes(value)) return value as MascotKind;
  return LEGACY[value] ?? null;
}

/** Талісман для показу: обраний або типовий. */
export function mascotInfo(value: unknown): MascotInfo {
  return MASCOTS[parseMascot(value) ?? DEFAULT_MASCOT];
}

/** Ключ копії вибору в браузері (localStorage). */
export const MASCOT_STORAGE_KEY = 'croatia.mascot';

/** Прочитати вибір у браузері; недоступне сховище (приватне вікно тощо) — null. */
export function readStoredMascot(storage: Pick<Storage, 'getItem'> | null | undefined): MascotKind | null {
  try {
    return parseMascot(storage?.getItem(MASCOT_STORAGE_KEY));
  } catch {
    return null;
  }
}

/** Зберегти вибір у браузері; помилки сховища не ламають екран. */
export function storeMascot(storage: Pick<Storage, 'setItem'> | null | undefined, kind: MascotKind | null): void {
  if (!kind) return;
  try {
    storage?.setItem(MASCOT_STORAGE_KEY, kind);
  } catch {
    /* сховище недоступне — не страшно, покажемо типовий варіант */
  }
}
