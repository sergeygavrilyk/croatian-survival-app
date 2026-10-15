/**
 * Оцінювання рівня (§60 ТЗ): тести модуля, середини й кінця рівня — чиста логіка без бази.
 *
 * Тест міряє чотири навички §60 — «розумію», «кажу», «спілкуюся», «переказую», —
 * а не відсоток пройдених уроків. Рішення власника 2026-10-15:
 *   - пройдено = ≥ 70 % загалом і ≥ 50 % у кожній навичці, де були відповіді;
 *   - говоріння можна пропустити (немає мікрофона чи браузер не розпізнає) — тоді воно не рахується;
 *   - тест не блокує уроки: це доказ рівня й порада, що повторити.
 * Сервер сам перевіряє відповіді (клієнтському «правильно» не довіряє).
 */
import { checkTypedAnswer } from './answer.ts';
import { checkSentence } from './mistakes.ts';
import { evaluateSpeech } from './speaking.ts';

export const AREAS = ['understand', 'produce', 'interact', 'mediate'] as const;
export type Area = (typeof AREAS)[number];

/** Назви навичок §60 для інтерфейсу. */
export const AREA_LABELS: Record<Area, { title: string; hint: string }> = {
  understand: { title: 'Розумію', hint: 'на слух і в тексті' },
  produce: { title: 'Кажу', hint: 'пишу й говорю хорватською' },
  interact: { title: 'Спілкуюся', hint: 'відповідаю в розмові' },
  mediate: { title: 'Переказую', hint: 'пояснюю іншій людині, що сказано' },
};

export const ASSESSMENT_KINDS = ['module', 'mid', 'final'] as const;
export type AssessmentKind = (typeof ASSESSMENT_KINDS)[number];

export const ITEM_TYPES = ['multiple_choice', 'type_answer', 'sentence_builder', 'speaking'] as const;
export type ItemType = (typeof ITEM_TYPES)[number];

export const DEFAULT_PASS_RATIO = 0.7;
export const DEFAULT_AREA_MIN_RATIO = 0.5;

const LEVEL_ORDER = ['A0', 'A1', 'A2', 'B1', 'B2'] as const;
const EPS = 1e-9;

/** Завдання з правильною відповіддю (лише на сервері). */
export interface GradableItem {
  id: string;
  item_type: string;
  area: string | null;
  options: unknown;
  correct_index: number | null;
  answer_text: string | null;
  weight?: number | string | null;
  lesson_id?: string | null;
}

/** Відповідь користувача на одне завдання (з браузера; перевіряється тут). */
export interface ItemResponse {
  item_id: string;
  /** Номер вибраного варіанта (multiple_choice) */
  choice?: number | null;
  /** Введений текст (type_answer) або складене речення (sentence_builder) */
  text?: string | null;
  /** Варіанти розпізнаного мовлення (speaking) — до 5 */
  transcripts?: string[] | null;
  /** Пропуск: зараховується лише для говоріння */
  skipped?: boolean;
}

export interface GradedItem {
  item_id: string;
  area: Area;
  correct: boolean;
  /** Говоріння пропущено — не рахується в бал */
  skipped: boolean;
  /** Що відповів користувач (для розбору й «Помилок»), до 300 символів */
  given: string | null;
  verdict: string;
}

export interface AreaScore {
  correct: number;
  total: number;
  skipped: number;
}

export interface AssessmentScore {
  graded: GradedItem[];
  areaScores: Record<Area, AreaScore>;
  /** Частка правильних (з урахуванням ваги), 0…1, без пропущеного говоріння */
  score: number;
  correct: number;
  total: number;
  passed: boolean;
  /** Навички нижче порогу — що підтягнути */
  weakAreas: Area[];
  /** Уроки, з яких були помилки, — від найбільшої кількості помилок */
  lessonsToReview: string[];
}

export interface PassRules {
  passRatio?: number | string | null;
  areaMinRatio?: number | string | null;
}

export function isArea(v: unknown): v is Area {
  return typeof v === 'string' && (AREAS as readonly string[]).includes(v);
}

export function optionsOf(options: unknown): string[] {
  return Array.isArray(options) ? options.map((o) => String(o)) : [];
}

function clip(s: string | null | undefined, max = 300): string | null {
  if (typeof s !== 'string') return null;
  const t = s.trim();
  if (!t) return null;
  return t.length <= max ? t : t.slice(0, max - 1).trimEnd() + '…';
}

function num(v: number | string | null | undefined, fallback: number): number {
  const n = typeof v === 'string' ? Number(v) : v;
  return typeof n === 'number' && Number.isFinite(n) ? n : fallback;
}

/** Перевірка однієї відповіді. Немає відповіді = неправильно (крім говоріння — тоді пропуск). */
export function gradeItem(item: GradableItem, response: ItemResponse | undefined): GradedItem {
  const area: Area = isArea(item.area) ? item.area : 'understand';
  const base = { item_id: item.id, area };
  const answer = (item.answer_text ?? '').trim();

  switch (item.item_type) {
    case 'multiple_choice': {
      const options = optionsOf(item.options);
      const choice = response?.choice;
      if (typeof choice !== 'number' || !Number.isInteger(choice) || choice < 0 || choice >= options.length) {
        return { ...base, correct: false, skipped: false, given: null, verdict: 'no_answer' };
      }
      const correct = item.correct_index !== null && choice === item.correct_index;
      return { ...base, correct, skipped: false, given: clip(options[choice]), verdict: correct ? 'exact' : 'wrong' };
    }
    case 'type_answer': {
      const text = response?.text ?? '';
      const check = checkTypedAnswer(text, answer);
      if (check.verdict === 'empty') return { ...base, correct: false, skipped: false, given: null, verdict: 'no_answer' };
      return { ...base, correct: check.correct, skipped: false, given: clip(text), verdict: check.verdict };
    }
    case 'sentence_builder': {
      const text = response?.text ?? '';
      const verdict = checkSentence(text, answer);
      if (!text.trim()) return { ...base, correct: false, skipped: false, given: null, verdict: 'no_answer' };
      return { ...base, correct: verdict !== 'wrong', skipped: false, given: clip(text), verdict };
    }
    case 'speaking': {
      const transcripts = Array.isArray(response?.transcripts)
        ? response.transcripts.filter((t): t is string => typeof t === 'string').slice(0, 5)
        : [];
      if (response?.skipped || transcripts.length === 0) {
        return { ...base, correct: false, skipped: true, given: null, verdict: 'skipped' };
      }
      const ev = evaluateSpeech(answer, transcripts);
      if (ev.verdict === 'no_speech') return { ...base, correct: false, skipped: true, given: null, verdict: 'no_speech' };
      const correct = ev.verdict === 'great' || ev.verdict === 'understandable';
      return { ...base, correct, skipped: false, given: clip(ev.transcript || transcripts[0]), verdict: ev.verdict };
    }
    default:
      return { ...base, correct: false, skipped: false, given: null, verdict: 'unknown_type' };
  }
}

export function emptyAreaScores(): Record<Area, AreaScore> {
  return {
    understand: { correct: 0, total: 0, skipped: 0 },
    produce: { correct: 0, total: 0, skipped: 0 },
    interact: { correct: 0, total: 0, skipped: 0 },
    mediate: { correct: 0, total: 0, skipped: 0 },
  };
}

export function areaRatio(s: AreaScore): number | null {
  return s.total > 0 ? s.correct / s.total : null;
}

/**
 * Оцінка всього тесту: бал загалом і за навичками, «пройдено» за правилами власника.
 * Порядок відповідей не важить; відповіді на чужі завдання ігноруються.
 */
export function scoreAssessment(
  items: ReadonlyArray<GradableItem>,
  responses: ReadonlyArray<ItemResponse>,
  rules: PassRules = {},
): AssessmentScore {
  const passRatio = num(rules.passRatio, DEFAULT_PASS_RATIO);
  const areaMin = num(rules.areaMinRatio, DEFAULT_AREA_MIN_RATIO);
  const byId = new Map<string, ItemResponse>();
  for (const r of Array.isArray(responses) ? responses : []) {
    if (r && typeof r.item_id === 'string' && !byId.has(r.item_id)) byId.set(r.item_id, r);
  }

  const areaScores = emptyAreaScores();
  const graded: GradedItem[] = [];
  const wrongByLesson = new Map<string, number>();
  let weightTotal = 0;
  let weightCorrect = 0;
  let correctCount = 0;
  let totalCount = 0;

  for (const item of items) {
    const g = gradeItem(item, byId.get(item.id));
    graded.push(g);
    const s = areaScores[g.area];
    if (g.skipped) {
      s.skipped += 1;
      continue;
    }
    const w = Math.max(num(item.weight, 1), 0) || 1;
    s.total += 1;
    totalCount += 1;
    weightTotal += w;
    if (g.correct) {
      s.correct += 1;
      correctCount += 1;
      weightCorrect += w;
    } else if (item.lesson_id) {
      wrongByLesson.set(item.lesson_id, (wrongByLesson.get(item.lesson_id) ?? 0) + 1);
    }
  }

  const score = weightTotal > 0 ? weightCorrect / weightTotal : 0;
  const weakAreas = AREAS.filter((a) => {
    const r = areaRatio(areaScores[a]);
    return r !== null && r + EPS < areaMin;
  });
  const passed = totalCount > 0 && score + EPS >= passRatio && weakAreas.length === 0;
  const lessonsToReview = [...wrongByLesson.entries()]
    .sort((a, b) => b[1] - a[1])
    .map(([id]) => id);

  return {
    graded,
    areaScores,
    score: Math.round(score * 1000) / 1000,
    correct: correctCount,
    total: totalCount,
    passed,
    weakAreas,
    lessonsToReview,
  };
}

export function percent(ratio: number | null | undefined): number {
  return typeof ratio === 'number' && Number.isFinite(ratio) ? Math.round(ratio * 100) : 0;
}

export function nextLevel(cefr: string): string | null {
  const i = (LEVEL_ORDER as readonly string[]).indexOf(cefr);
  return i >= 0 && i < LEVEL_ORDER.length - 1 ? LEVEL_ORDER[i + 1] : null;
}

/** Поля assessment_attempts, обов'язкові з M7 (оцінка застосунку, не сертифікат). */
export function attemptMeta(kind: string, cefr: string, result: Pick<AssessmentScore, 'passed' | 'total'>) {
  const level = (LEVEL_ORDER as readonly string[]).includes(cefr) ? cefr : 'A0';
  const confidence = result.total >= 25 ? 'high' : result.total >= 10 ? 'medium' : 'low';
  const recommended = kind === 'final' && result.passed ? nextLevel(level) ?? level : level;
  return { estimated_cefr: level, confidence, recommended_start: recommended } as const;
}

/** Адреса тесту: a0-m01, a0-mid, a1-final. */
export function assessmentSlug(cefr: string, kind: AssessmentKind, moduleOrder?: number): string {
  const lv = cefr.toLowerCase();
  if (kind === 'module') return `${lv}-m${String(moduleOrder ?? 0).padStart(2, '0')}`;
  return `${lv}-${kind}`;
}

const SLUG_RE = /^(a0|a1|a2|b1|b2)-(m\d{2}|mid|final)$/;

export function isLevelAssessmentSlug(v: unknown): v is string {
  return typeof v === 'string' && SLUG_RE.test(v);
}

export function kindTitle(kind: string, cefr: string, moduleOrder?: number | null): string {
  if (kind === 'module') return `Перевірка модуля ${cefr}.${moduleOrder ?? ''}`;
  if (kind === 'mid') return `Перевірка середини рівня ${cefr}`;
  if (kind === 'final') return `Фінальна перевірка рівня ${cefr}`;
  return 'Перевірка';
}

export interface AttemptRow {
  assessment_id: string;
  score: number | string | null;
  passed: boolean | null;
  completed_at: string;
}

export interface AttemptSummary {
  attempts: number;
  bestScore: number;
  passed: boolean;
  lastAt: string | null;
}

/** Підсумок спроб для списку тестів: найкращий бал, чи пройдено хоч раз. */
export function summarizeAttempts(rows: ReadonlyArray<AttemptRow>): Map<string, AttemptSummary> {
  const out = new Map<string, AttemptSummary>();
  for (const r of rows) {
    const prev = out.get(r.assessment_id) ?? { attempts: 0, bestScore: 0, passed: false, lastAt: null };
    const s = num(r.score, 0);
    out.set(r.assessment_id, {
      attempts: prev.attempts + 1,
      bestScore: Math.max(prev.bestScore, s),
      passed: prev.passed || r.passed === true,
      lastAt: !prev.lastAt || r.completed_at > prev.lastAt ? r.completed_at : prev.lastAt,
    });
  }
  return out;
}

/** Рівні, для яких є тести модулів (у порядку). Для списку перевірок і перемикача рівнів. */
export const ASSESSED_LEVELS = ['A0', 'A1'] as const;

/** Рівень списку перевірок: з адреси, інакше з профілю, інакше перший доступний. */
export function pickAssessmentLevel(requested: unknown, profileLevel: unknown, available: ReadonlyArray<string>): string | null {
  if (typeof requested === 'string' && available.includes(requested)) return requested;
  if (typeof profileLevel === 'string' && available.includes(profileLevel)) return profileLevel;
  return available[0] ?? null;
}

/** Порядок у списку: модулі 1–5 → середина → модулі 6–10 → фінал. */
export function displayOrder(kind: string, orderIndex: number | null | undefined): number {
  if (kind === 'mid') return 5.5;
  if (kind === 'final') return 1000;
  return typeof orderIndex === 'number' ? orderIndex : 999;
}

export interface LevelStatus {
  total: number;
  passed: number;
  midPassed: boolean;
  finalPassed: boolean;
}

/** Підсумок рівня для списку перевірок: скільки тестів пройдено, чи підтверджено рівень фіналом. */
export function levelStatus(
  assessments: ReadonlyArray<{ id: string; kind: string }>,
  summaries: ReadonlyMap<string, AttemptSummary>,
): LevelStatus {
  let passed = 0;
  let midPassed = false;
  let finalPassed = false;
  for (const a of assessments) {
    if (!summaries.get(a.id)?.passed) continue;
    passed += 1;
    if (a.kind === 'mid') midPassed = true;
    if (a.kind === 'final') finalPassed = true;
  }
  return { total: assessments.length, passed, midPassed, finalPassed };
}

const CYR = /[Ѐ-ӿ]/;

/**
 * Помилки тесту, які варто повторити в «Помилках» (user_errors): лише ті, де правильна відповідь —
 * хорватська фраза з ≥ 2 слів (її можна скласти з плиток). Пропущене говоріння — не помилка.
 */
export function mistakesToSave(
  items: ReadonlyArray<GradableItem>,
  graded: ReadonlyArray<GradedItem>,
): Array<{ item_id: string; original: string; corrected: string; error_type: 'word_order' | 'other' | 'pronunciation' }> {
  const byId = new Map(items.map((i) => [i.id, i]));
  const out: Array<{ item_id: string; original: string; corrected: string; error_type: 'word_order' | 'other' | 'pronunciation' }> = [];
  for (const g of graded) {
    if (g.correct || g.skipped) continue;
    const item = byId.get(g.item_id);
    if (!item) continue;
    const corrected =
      item.item_type === 'multiple_choice'
        ? optionsOf(item.options)[item.correct_index ?? -1] ?? ''
        : (item.answer_text ?? '').trim();
    if (!corrected || CYR.test(corrected) || corrected.split(/\s+/).length < 2 || corrected.length > 300) continue;
    const given = g.given && !CYR.test(g.given) ? g.given : '—';
    out.push({
      item_id: g.item_id,
      original: given,
      corrected,
      error_type: item.item_type === 'sentence_builder' ? 'word_order' : item.item_type === 'speaking' ? 'pronunciation' : 'other',
    });
  }
  return out;
}
