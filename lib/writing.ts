/**
 * Письмо й переказ в уроці (§57, §58): «Напишіть повідомлення» (write_message) і «Перекажіть другу» (mediation).
 * Перевірка БЕЗ AI (рішення власника 2026-11-05): чи є в тексті кожен пункт завдання — за ключами-основами слів,
 * без урахування регістру, розділових знаків і (для хорватської) діакритик; плюс підказки «doci → doći».
 * Чиста логіка без БД і браузера; тести — writing.test.ts.
 *
 * Ключ пункту — список основ слів, які мають бути в тексті (у будь-якому порядку); пункт виконано, якщо збігся хоч один ключ.
 * Основа збігається з початком слова («termin» → termin, termina, terminom); «=» в кінці — лише ціле слово («ne=»).
 */
import { normalizeCroatian } from './srs.ts';

export const WRITING_TYPES = ['write_message', 'mediation'] as const;
export type WritingType = (typeof WRITING_TYPES)[number];
export type MediationDirection = 'hr_ua' | 'ua_hr';
export type WritingLang = 'hr' | 'ua';

export interface WritingPoint {
  /** Що має бути в тексті — українською («що не прийдете завтра») */
  ua: string;
  /** Варіанти: кожен — основи слів, які всі мають бути в тексті */
  keys: string[][];
}

export interface WritingTask {
  type: WritingType;
  /** Ситуація українською (write_message) або коротка інструкція */
  situation_ua: string;
  /** Хорватський текст, який треба переказати (mediation hr_ua): вивіска, SMS, оголошення */
  source_hr?: string;
  /** Що питає / просить друг українською (mediation) */
  friend_ua?: string;
  direction?: MediationDirection;
  points: WritingPoint[];
  /** Слова уроку плитками (хорватською) */
  hints: string[];
  /** Зразкові відповіді: хорватською, а для переказу hr_ua — українською */
  models: string[];
}

export function isWritingType(t: string): t is WritingType {
  return (WRITING_TYPES as readonly string[]).includes(t);
}

/** Мова відповіді: переказ хорватського українською — 'ua', решта — хорватською. */
export function answerLang(task: Pick<WritingTask, 'type' | 'direction'>): WritingLang {
  return task.type === 'mediation' && task.direction === 'hr_ua' ? 'ua' : 'hr';
}

const strings = (v: unknown): string[] =>
  Array.isArray(v) ? v.filter((s): s is string => typeof s === 'string' && s.trim() !== '').map((s) => s.trim()) : [];

/** Завдання з колонки exercises.task; некоректне — null (вправу тоді пропускаємо, урок не ламається). */
export function parseWritingTask(type: string, raw: unknown): WritingTask | null {
  if (!isWritingType(type) || !raw || typeof raw !== 'object' || Array.isArray(raw)) return null;
  const r = raw as Record<string, unknown>;
  const points: WritingPoint[] = Array.isArray(r.points)
    ? r.points.flatMap((p) => {
        if (!p || typeof p !== 'object') return [];
        const o = p as Record<string, unknown>;
        const keys = Array.isArray(o.keys) ? o.keys.map(strings).filter((k) => k.length > 0) : [];
        return typeof o.ua === 'string' && o.ua.trim() && keys.length ? [{ ua: o.ua.trim(), keys }] : [];
      })
    : [];
  const models = strings(r.models);
  const situation = typeof r.situation_ua === 'string' ? r.situation_ua.trim() : '';
  const direction = r.direction === 'hr_ua' || r.direction === 'ua_hr' ? r.direction : undefined;
  if (!points.length || !models.length || !situation) return null;
  if (type === 'mediation' && !direction) return null;
  if (type === 'mediation' && direction === 'hr_ua' && typeof r.source_hr !== 'string') return null;
  return {
    type,
    situation_ua: situation,
    ...(typeof r.source_hr === 'string' && r.source_hr.trim() ? { source_hr: r.source_hr.trim() } : {}),
    ...(typeof r.friend_ua === 'string' && r.friend_ua.trim() ? { friend_ua: r.friend_ua.trim() } : {}),
    ...(direction ? { direction } : {}),
    points,
    hints: strings(r.hints),
    models,
  };
}

/** Слова тексту для порівняння: малі літери; хорватська — без діакритик; український апостроф — один. */
export function wordsOf(text: string, lang: WritingLang): string[] {
  let t = text.toLowerCase().replace(/[’ʼ`]/g, "'");
  if (lang === 'hr') t = normalizeCroatian(t);
  return t.split(/[^\p{L}\p{N}']+/u).map((w) => w.replace(/^'+|'+$/g, '')).filter(Boolean);
}

function stemMatches(words: readonly string[], stem: string, lang: WritingLang): boolean {
  const exact = stem.endsWith('=');
  const s = wordsOf(exact ? stem.slice(0, -1) : stem, lang).join(' ');
  if (!s) return false;
  // основа з кількох слів («ne mog») — послідовність слів
  const parts = s.split(' ');
  for (let i = 0; i + parts.length <= words.length; i++) {
    // усі слова, крім останнього, — цілі; останнє — початок слова (або ціле, якщо «=»)
    const ok = parts.every((p, j) => (j === parts.length - 1 && !exact ? words[i + j].startsWith(p) : words[i + j] === p));
    if (ok) return true;
  }
  return false;
}

/** Чи є в тексті пункт: збігся хоч один ключ (усі його основи). */
export function pointDone(words: readonly string[], point: WritingPoint, lang: WritingLang): boolean {
  return point.keys.some((key) => key.every((stem) => stemMatches(words, stem, lang)));
}

export interface DiacriticHint {
  written: string;
  correct: string;
}

/**
 * «doci → doći»: слова відповіді без діакритик, які є в підказках чи зразках з діакритиками.
 * Лише для хорватської відповіді; до 5 підказок, без повторів.
 */
export function diacriticHints(text: string, vocabulary: readonly string[]): DiacriticHint[] {
  const known = new Map<string, string>();
  for (const phrase of vocabulary) {
    for (const w of phrase.toLowerCase().split(/[^\p{L}]+/u)) {
      if (w && /[čćđšž]/.test(w)) known.set(normalizeCroatian(w), w);
    }
  }
  const out: DiacriticHint[] = [];
  const seen = new Set<string>();
  for (const raw of text.split(/[^\p{L}]+/u)) {
    const w = raw.toLowerCase();
    if (!w || seen.has(w)) continue;
    seen.add(w);
    const correct = known.get(normalizeCroatian(w));
    if (correct && correct !== w) out.push({ written: raw, correct });
    if (out.length >= 5) break;
  }
  return out;
}

export interface WritingCheck {
  points: Array<{ ua: string; done: boolean }>;
  done: number;
  total: number;
  /** Усі пункти є — вправу зараховано */
  correct: boolean;
  diacritics: DiacriticHint[];
  /** Майже порожньо — просимо дописати, не оцінюємо */
  tooShort: boolean;
}

/** Перевірка відповіді без AI. */
export function checkWriting(task: WritingTask, text: string): WritingCheck {
  const lang = answerLang(task);
  const words = wordsOf(text, lang);
  const tooShort = words.length < 2;
  const points = task.points.map((p) => ({ ua: p.ua, done: !tooShort && pointDone(words, p, lang) }));
  const done = points.filter((p) => p.done).length;
  return {
    points,
    done,
    total: points.length,
    correct: !tooShort && done === points.length,
    diacritics: lang === 'hr' ? diacriticHints(text, [...task.hints, ...task.models]) : [],
    tooShort,
  };
}

/** Межа довжини відповіді (та сама, що в базі: writing_attempts.text ≤ 1000). */
export const MAX_ANSWER = 1000;
