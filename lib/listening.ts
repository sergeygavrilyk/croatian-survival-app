/**
 * Вправа «Прослухайте діалог чи оголошення» (`listening_dialogue`, рішення власника 2026-11-12,
 * docs/proposals/2026-11-12_listening_dialogue.md). Чиста логіка без БД і браузера; тести — listening.test.ts.
 *
 * Людина слухає запис (репліка за реплікою, тексту не видно), до 3 разів, можна «Повільніше»,
 * і відповідає на 2–3 запитання українською: вибір із варіантів або коротка відповідь (цифра / слово, з A2.8).
 * Після відповіді відкривається текст запису з перекладом. Перевірка — без AI.
 */
import { normalizeCroatian } from './srs.ts';

export const LISTENING_TYPE = 'listening_dialogue';
export const LISTENING_KINDS = ['dialogue', 'announcement', 'voicemail', 'forecast', 'news'] as const;
export type ListeningKind = (typeof LISTENING_KINDS)[number];

/** Найдовша репліка: один запит озвучення (як шматки текстів для читання, lib/reading.ts). */
export const LISTENING_MAX_LINE = 180;
export const DEFAULT_MAX_PLAYS = 3;
/** Пауза між репліками: звичайно / «Повільніше». */
export const PAUSE_MS = { normal: 450, slow: 1400 } as const;

export interface ListeningLine {
  /** Хто говорить (діалог); в оголошенні — немає */
  speaker?: string;
  hr: string;
  ua: string;
}

export interface ChoiceQuestion {
  kind: 'choice';
  q_ua: string;
  options: string[];
  correct: number;
  /** Репліка, де є відповідь (підсвічуємо в тексті після відповіді) */
  answer_turn?: number;
}

export interface ShortQuestion {
  kind: 'short';
  q_ua: string;
  /** Правильна відповідь, як її показати («11.30», «Supetar») */
  answer_text: string;
  /** Інші правильні написання («11:30», «пів на дванадцяту») */
  accept: string[];
  answer_turn?: number;
}

export type ListeningQuestion = ChoiceQuestion | ShortQuestion;

export interface ListeningTask {
  kind: ListeningKind;
  situation_ua: string;
  script: ListeningLine[];
  questions: ListeningQuestion[];
  max_plays: number;
}

const text = (v: unknown): string => (typeof v === 'string' ? v.replace(/\s+/g, ' ').trim() : '');
const CYRILLIC = /[Ѐ-ӿ]/;

function parseQuestion(raw: unknown, turns: number): ListeningQuestion | null {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return null;
  const r = raw as Record<string, unknown>;
  const q = text(r.q_ua);
  if (!q) return null;
  const turn = Number.isInteger(r.answer_turn) && (r.answer_turn as number) >= 0 && (r.answer_turn as number) < turns
    ? (r.answer_turn as number)
    : undefined;
  if (Array.isArray(r.options)) {
    const options = r.options.map(text);
    if (options.length < 2 || options.length > 4 || options.some((o) => !o) || new Set(options).size !== options.length) return null;
    const correct = r.correct;
    if (!Number.isInteger(correct) || (correct as number) < 0 || (correct as number) >= options.length) return null;
    return { kind: 'choice', q_ua: q, options, correct: correct as number, ...(turn !== undefined ? { answer_turn: turn } : {}) };
  }
  const answer = text(r.answer_text);
  if (!answer) return null;
  const accept = Array.isArray(r.accept) ? r.accept.map(text).filter(Boolean) : [];
  return { kind: 'short', q_ua: q, answer_text: answer, accept, ...(turn !== undefined ? { answer_turn: turn } : {}) };
}

/** Завдання з колонки exercises.task; некоректне — null (вправу тоді пропускаємо, урок не ламається). */
export function parseListeningTask(raw: unknown): ListeningTask | null {
  if (!raw || typeof raw !== 'object' || Array.isArray(raw)) return null;
  const r = raw as Record<string, unknown>;
  const kind = (LISTENING_KINDS as readonly string[]).includes(r.kind as string) ? (r.kind as ListeningKind) : null;
  const situation = text(r.situation_ua);
  if (!kind || !situation || !Array.isArray(r.script)) return null;
  const script: ListeningLine[] = [];
  for (const line of r.script) {
    if (!line || typeof line !== 'object' || Array.isArray(line)) return null;
    const l = line as Record<string, unknown>;
    const hr = text(l.hr);
    const ua = text(l.ua);
    if (!hr || !ua || hr.length > LISTENING_MAX_LINE || CYRILLIC.test(hr)) return null;
    const speaker = text(l.speaker);
    script.push({ ...(speaker ? { speaker } : {}), hr, ua });
  }
  if (script.length < 1 || script.length > 12) return null;
  if (!Array.isArray(r.questions)) return null;
  const questions = r.questions.map((q) => parseQuestion(q, script.length));
  if (questions.length < 1 || questions.length > 4 || questions.some((q) => q === null)) return null;
  const plays = Number.isInteger(r.max_plays) ? Math.min(5, Math.max(1, r.max_plays as number)) : DEFAULT_MAX_PLAYS;
  return { kind, situation_ua: situation, script, questions: questions as ListeningQuestion[], max_plays: plays };
}

/**
 * Коротка відповідь для порівняння: без регістру, діакритик, крапки в кінці й зайвих пробілів;
 * час — до вигляду «11:30» (11.30, 11:30, 11 i 30, 11 h 30, 11,30).
 */
export function normalizeShortAnswer(input: string): string {
  return normalizeCroatian(input)
    .replace(/(\d{1,2})\s*(?:[:.,h]|\s+i\s+)\s*(\d{2})\b/g, '$1:$2')
    .replace(/[«»"„“”!?;]/g, ' ')
    .replace(/[.,]+$/g, '')
    .replace(/\s+/g, ' ')
    .trim();
}

/** Чи правильна коротка відповідь. Порожня — ні. */
export function checkShortAnswer(input: string, q: Pick<ShortQuestion, 'answer_text' | 'accept'>): boolean {
  const got = normalizeShortAnswer(input);
  if (!got) return false;
  return [q.answer_text, ...q.accept].some((a) => normalizeShortAnswer(a) === got);
}

export type ListeningAnswer = number | string | null;

export interface ListeningScore {
  /** По одному на запитання */
  results: boolean[];
  correct: number;
  total: number;
  /** Усі правильні — вправа правильна */
  outcome: 'correct' | 'wrong';
}

/** Оцінка відповідей: вибір — за індексом, коротка — checkShortAnswer. */
export function scoreListening(task: Pick<ListeningTask, 'questions'>, answers: readonly ListeningAnswer[]): ListeningScore {
  const results = task.questions.map((q, i) => {
    const a = answers[i];
    if (q.kind === 'choice') return a === q.correct;
    return typeof a === 'string' && checkShortAnswer(a, q);
  });
  const correct = results.filter(Boolean).length;
  return { results, correct, total: results.length, outcome: correct === results.length ? 'correct' : 'wrong' };
}

/** Чи всі запитання мають відповідь (кнопка «Перевірити»). */
export function allAnswered(task: Pick<ListeningTask, 'questions'>, answers: readonly ListeningAnswer[]): boolean {
  return task.questions.every((q, i) => {
    const a = answers[i];
    return q.kind === 'choice' ? typeof a === 'number' : typeof a === 'string' && a.trim() !== '';
  });
}

/** Скільки прослуховувань лишилось. */
export function playsLeft(plays: number, maxPlays: number): number {
  return Math.max(0, maxPlays - plays);
}

/** Репліки, де є відповіді (для підсвічування в тексті). */
export function answerTurns(task: Pick<ListeningTask, 'questions'>): Set<number> {
  return new Set(task.questions.flatMap((q) => (q.answer_turn !== undefined ? [q.answer_turn] : [])));
}
