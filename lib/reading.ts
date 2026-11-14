/**
 * Читання (§6 ТЗ «Extensive Reading», §55–56). Чиста логіка без БД; тести — reading.test.ts.
 * Тексти — таблиця reading_texts (M15), контент — scripts/reading_data.py, генератор — scripts/gen_reading.py.
 *
 *  - tokenize: текст → шматки; слова можна натиснути й побачити переклад (словничок тексту);
 *    правило розбиття те саме, що в генераторі (WORD + EMAIL_URL), тож кожне слово має пару в словничку;
 *  - seededShuffle: варіанти відповіді в сталому «випадковому» порядку (у даних правильна відповідь часто перша);
 *  - speechChunks: текст → шматки до 180 символів для озвучення (сервіс TTS не приймає довгих рядків).
 */

import { labelChips, readLabels, type LexemeLabels } from './lexeme-labels.ts';

export const TEXT_TYPES = [
  'message', 'chat', 'email', 'notice', 'ad', 'menu', 'instruction', 'form', 'story', 'article', 'news', 'dialogue', 'sign',
] as const;
export type TextType = (typeof TEXT_TYPES)[number];

export const TEXT_TYPE_LABEL: Record<TextType, string> = {
  message: 'Повідомлення',
  chat: 'Чат',
  email: 'Лист',
  notice: 'Оголошення',
  ad: 'Реклама',
  menu: 'Меню',
  instruction: 'Інструкція',
  form: 'Анкета',
  story: 'Історія',
  article: 'Стаття',
  news: 'Новини',
  dialogue: 'Діалог',
  sign: 'Вивіски',
};

/** Рівні, для яких є тексти (§6, §55): A0 — вивіски, A1 — мікротексти, A2 — короткі історії, листи, новини. */
export const READING_LEVELS = ['A0', 'A1', 'A2'] as const;
export type ReadingLevel = (typeof READING_LEVELS)[number];

export function isReadingLevel(v: unknown): v is ReadingLevel {
  return typeof v === 'string' && (READING_LEVELS as readonly string[]).includes(v);
}

/**
 * Який рівень показати: з адреси (?level=A2), інакше — за рівнем користувача (B1 і B2 → A2, найвищий наявний),
 * інакше A1. available — рівні, для яких є опубліковані тексти: якщо вибраного немає, беремо найближчий нижчий / перший.
 */
export function pickReadingLevel(requested: unknown, currentLevel: unknown, available: readonly ReadingLevel[] = READING_LEVELS): ReadingLevel {
  const fromProfile: ReadingLevel | null =
    currentLevel === 'A0' || currentLevel === 'A1' ? currentLevel : currentLevel === 'A2' || currentLevel === 'B1' || currentLevel === 'B2' ? 'A2' : null;
  const wanted: ReadingLevel = isReadingLevel(requested) ? requested : fromProfile ?? 'A1';
  if (available.length === 0 || available.includes(wanted)) return wanted;
  const lower = [...available].reverse().find((l) => READING_LEVELS.indexOf(l) < READING_LEVELS.indexOf(wanted));
  return lower ?? available[0];
}

// Назви модулів A2 v2 (програма 2026-11-12) — запасний варіант, якщо назву модуля не завантажено
export const A2_THEMES: Record<number, string> = {
  1: 'Туризм і подорожі: Адріатика', 2: 'Навчання: курси, університет, школа', 3: 'Моє минуле: дитинство й спогади',
  4: 'Люди й стосунки: характер, свята, конфлікти', 5: 'Робота й кар’єра', 6: 'Установи, послуги й гроші',
  7: 'Здоров’я: система й самопочуття', 8: 'Авто в Хорватії', 9: 'Неприємності в місті й довкілля', 10: 'Медіа, культура й думки',
  11: 'Хорватія: краї, звичаї, культура', 12: 'Українці в Хорватії', 13: 'Плани, мрії й домовленості', 14: 'Підсумок A2: моє життя в Хорватії',
};

/** «Модуль A0.3 — Brojevi (числа)» → «Brojevi (числа)». */
export function moduleTitle(raw: string | null | undefined): string | null {
  if (!raw) return null;
  return raw.replace(/^Модуль\s+[A-Z]\d\.\d+\s*[—–-]\s*/, '').trim() || null;
}

/** Заголовок групи текстів: «Після модуля A1.3 · Покупки» (A2 — так само, з програми A2 v2 2026-11-12). */
export function moduleHeading(level: string, order: number | null, rawTitle?: string | null): string {
  if (!order || order < 1) return 'Інші тексти';
  const title = moduleTitle(rawTitle) ?? (level === 'A2' ? A2_THEMES[order] ?? null : null);
  const head = `Після модуля ${level}.${order}`;
  return title ? `${head} · ${title}` : head;
}

/** Короткий опис рівня над списком текстів. */
export function levelIntro(level: string): string {
  if (level === 'A0') return 'Вивіски, цінники й розклади, які ви побачите в Хорватії з першого дня. Натисніть будь-яке слово — побачите переклад.';
  if (level === 'A2') return 'Короткі історії, листи, чати й новини: минулий і майбутній час. Натисніть будь-яке слово — побачите переклад і форму.';
  return 'Короткі тексти з життя в Хорватії. Натисніть будь-яке слово — побачите переклад.';
}

/** Варіант відповіді хорватською (є літери, немає кирилиці) — показуємо в <Hr> (lang="hr"). Числа й ціни — ні. */
export function isCroatianOption(text: string): boolean {
  return /\p{L}/u.test(text) && !/[\u0400-\u04FF]/.test(text);
}

export function textTypeLabel(t: string): string {
  return (TEXT_TYPES as readonly string[]).includes(t) ? TEXT_TYPE_LABEL[t as TextType] : 'Текст';
}

export interface GlossaryEntry {
  form: string;
  lemma: string;
  ua: string;
  /** слово з уроків A0–A1 — його можна зберегти в тренажер */
  lesson?: boolean;
  /** що це за слово: частина мови, рід, вид («іменник, жіночий рід») — §56 */
  pos?: string;
  /** що це за форма в тексті: відмінок і число, особа й час («знахідний відмінок (кого? що?), однина») */
  gram?: string;
  /** Позначка категорії слова з `lexemes` за лемою (DESIGN_SYSTEM.md §3.4); звичайне слово — без неї */
  labels?: LexemeLabels;
  /** Стандартний відповідник (`standard_lexeme_id` → лема): «стандартно: razumjeti» */
  standard_lemma?: string;
}

const HINT_MAX = 200;
/** Підказка з БД: лише непорожній рядок розумної довжини. */
function hint(v: unknown): string | undefined {
  return typeof v === 'string' && v.trim() !== '' ? v.trim().slice(0, HINT_MAX) : undefined;
}

export interface ReadingQuestion {
  question_ua: string;
  options: string[];
  answer: string;
}

export interface ReadingText {
  id: string;
  code: string;
  cefr: string;
  text_type: string;
  situation: string | null;
  module_order: number | null;
  title_ua: string;
  title_hr: string;
  body_hr: string;
  body_ua: string;
  glossary: GlossaryEntry[];
  questions: ReadingQuestion[];
  word_count: number;
  known_ratio: number | null;
}

export type Segment = { text: string; word: string | null };

// Слова з літер (хорватська латиниця), можна з дефісом: «SMS-om». Пошта й посилання — не слова.
const TOKEN = /(\S+@\S+|https?:\/\/\S+)|([A-Za-zČĆĐŠŽčćđšžÀ-ž]+(?:-[A-Za-zČĆĐŠŽčćđšžÀ-ž]+)*)/gu;

/** Рядок → шматки: слова (word — у нижньому регістрі, для словничка) і все інше (пробіли, розділові знаки, числа). */
export function tokenize(line: string): Segment[] {
  const out: Segment[] = [];
  let last = 0;
  for (const m of line.matchAll(TOKEN)) {
    const start = m.index ?? 0;
    if (start > last) out.push({ text: line.slice(last, start), word: null });
    out.push({ text: m[0], word: m[2] ? m[2].toLowerCase() : null });
    last = start + m[0].length;
  }
  if (last < line.length) out.push({ text: line.slice(last), word: null });
  return out;
}

/** Абзаци тексту (рядки). Порожні рядки пропускаємо. */
export function paragraphs(body: string): string[] {
  return body.split(/\r?\n/).map((l) => l.trim()).filter(Boolean);
}

/** Словничок з БД (jsonb) → лише коректні записи, за формою слова. */
export function glossaryIndex(v: unknown): Map<string, GlossaryEntry> {
  const map = new Map<string, GlossaryEntry>();
  if (!Array.isArray(v)) return map;
  for (const x of v) {
    if (!x || typeof x !== 'object') continue;
    const { form, lemma, ua, lesson, pos, gram, labels, standard_lemma } = x as Record<string, unknown>;
    if (typeof form !== 'string' || typeof lemma !== 'string' || typeof ua !== 'string' || !form) continue;
    const entry: GlossaryEntry = { form: form.toLowerCase(), lemma, ua, lesson: lesson === true };
    const p = hint(pos);
    const g = hint(gram);
    if (p) entry.pos = p;
    if (g) entry.gram = g;
    // мітки додає сервер (withGlossaryLabels); офлайн-копія тексту зберігає їх — невідомі значення відкидаємо
    if (labels && typeof labels === 'object') {
      const l = readLabels(labels as Record<string, unknown>);
      if (labelChips(l).length > 0) entry.labels = l;
    }
    const std = hint(standard_lemma);
    if (std) entry.standard_lemma = std;
    map.set(entry.form, entry);
  }
  return map;
}

/** Леми словничка тексту без повторів — для запиту міток до `lexemes` (глосарій — JSON без `lexeme_id`). */
export function glossaryLemmas(glossary: readonly GlossaryEntry[]): string[] {
  return [...new Set(glossary.map((g) => g.lemma).filter((l) => l.trim() !== ''))];
}

/** Рядок `lexemes` для міток словничка (лише потрібні колонки). */
export interface GlossaryLexemeRow {
  lemma: string;
  register?: unknown;
  regionality?: unknown;
  usage_tags?: unknown;
  standard_lexeme_id?: string | null;
}

/**
 * Позначка категорії в словничку тексту (рішення власника 2026-11-13, DESIGN_SYSTEM.md §3.4): мітки слова з `lexemes`
 * за лемою + «стандартно: …». Звичайне слово — без міток. Якщо одній лемі відповідає кілька слів з різними мітками
 * чи відповідниками (омоніми) — не вгадуємо, лишаємо без позначки.
 */
export function withGlossaryLabels(
  glossary: readonly GlossaryEntry[],
  lexemes: readonly GlossaryLexemeRow[],
  standards: ReadonlyArray<{ id: string; lemma: string }> = [],
): GlossaryEntry[] {
  const standardLemma = new Map(standards.map((r) => [r.id, r.lemma]));
  const byLemma = new Map<string, { labels: LexemeLabels; standard?: string }[]>();
  for (const row of lexemes) {
    const list = byLemma.get(row.lemma) ?? [];
    const standard = row.standard_lexeme_id ? standardLemma.get(row.standard_lexeme_id) : undefined;
    list.push({ labels: readLabels(row), standard });
    byLemma.set(row.lemma, list);
  }
  const key = (v: { labels: LexemeLabels; standard?: string }) =>
    JSON.stringify([labelChips(v.labels).map((c) => c.key), v.standard ?? null]);

  return glossary.map((entry) => {
    const found = byLemma.get(entry.lemma);
    if (!found || new Set(found.map(key)).size !== 1) return entry; // немає в словнику або омоніми з різними мітками
    const { labels, standard } = found[0];
    const next: GlossaryEntry = { ...entry };
    if (labelChips(labels).length > 0) next.labels = labels;
    if (standard) next.standard_lemma = standard;
    return next;
  });
}

/** Питання з БД (jsonb) → лише коректні (відповідь серед варіантів). */
export function questionsFrom(v: unknown): ReadingQuestion[] {
  if (!Array.isArray(v)) return [];
  return v.filter((x): x is ReadingQuestion => {
    if (!x || typeof x !== 'object') return false;
    const q = x as Record<string, unknown>;
    return (
      typeof q.question_ua === 'string' &&
      Array.isArray(q.options) &&
      q.options.every((o) => typeof o === 'string') &&
      typeof q.answer === 'string' &&
      (q.options as string[]).includes(q.answer)
    );
  });
}

/** Скільки відповідей правильні (answers — вибраний варіант для кожного питання або null). */
export function scoreAnswers(questions: readonly ReadingQuestion[], answers: ReadonlyArray<string | null>): number {
  return questions.reduce((n, q, i) => n + (answers[i] === q.answer ? 1 : 0), 0);
}

/** Детермінований генератор (mulberry32) з рядка-зерна. */
function seeded(seed: string): () => number {
  let h = 1779033703 ^ seed.length;
  for (let i = 0; i < seed.length; i++) {
    h = Math.imul(h ^ seed.charCodeAt(i), 3432918353);
    h = (h << 13) | (h >>> 19);
  }
  let a = h >>> 0;
  return () => {
    a = (a + 0x6d2b79f5) >>> 0;
    let t = a;
    t = Math.imul(t ^ (t >>> 15), t | 1);
    t ^= t + Math.imul(t ^ (t >>> 7), t | 61);
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

/** Перемішати в сталому порядку для зерна (той самий текст — той самий порядок варіантів). */
export function seededShuffle<T>(items: readonly T[], seed: string): T[] {
  const random = seeded(seed);
  const a = [...items];
  for (let i = a.length - 1; i > 0; i--) {
    const j = Math.floor(random() * (i + 1));
    [a[i], a[j]] = [a[j], a[i]];
  }
  return a;
}

/** Текст → шматки до max символів для озвучення: за реченнями, довгі — за комами, далі — за словами. */
export function speechChunks(body: string, max = 180): string[] {
  const sentences = paragraphs(body).flatMap((p) => p.split(/(?<=[.!?])\s+/)).map((s) => s.trim()).filter(Boolean);
  const out: string[] = [];
  const pushPiece = (piece: string) => {
    if (piece.length <= max) {
      out.push(piece);
      return;
    }
    let cur = '';
    for (const w of piece.split(/\s+/)) {
      if (cur && (cur + ' ' + w).length > max) {
        out.push(cur);
        cur = w;
      } else cur = cur ? cur + ' ' + w : w;
    }
    if (cur) out.push(cur);
  };
  for (const s of sentences) {
    if (s.length <= max) {
      out.push(s);
      continue;
    }
    let cur = '';
    for (const part of s.split(/(?<=,)\s+/)) {
      if (cur && (cur + ' ' + part).length > max) {
        pushPiece(cur);
        cur = part;
      } else cur = cur ? cur + ' ' + part : part;
    }
    if (cur) pushPiece(cur);
  }
  return out;
}

/** Скільки хвилин читати: ~60 слів на хвилину на A1, щонайменше 1. */
export function readingMinutes(wordCount: number): number {
  return Math.max(1, Math.round(wordCount / 60));
}

/** Частка знайомих слів → підпис («знайомих 92 %»); null — невідомо. */
export function knownLabel(ratio: number | null | undefined): string | null {
  if (typeof ratio !== 'number' || !Number.isFinite(ratio)) return null;
  return `знайомих слів ${Math.round(ratio * 100)}\u00a0%`; // нерозривний пробіл: «%» не переноситься на новий рядок
}

/**
 * Шапка картки модуля на «Уроки» (баг 2026-10-20: на телефоні назва «Модуль A0.1 — Pozdrav!» обрізалась,
 * а «Модуль 1 / Модуль A0.1 — … / Modul A0.1 — …» повторювались тричі).
 * kicker — «Модуль A0.1», title — назва без префікса, subtitle — хорватська назва, лише якщо вона нова.
 */
export function moduleCardTitles(
  titleUa: string,
  titleHr: string | null | undefined,
  level: string,
  order: number,
): { kicker: string; title: string; subtitle: string | null } {
  const title = moduleTitle(titleUa) ?? titleUa;
  const hr = titleHr ? titleHr.replace(/^Modul\s+[A-Z]\d\.\d+\s*[—–-]\s*/, '').trim() : '';
  const norm = (s: string) => s.toLowerCase().replace(/…/g, '...').replace(/\s+/g, ' ').trim();
  return {
    kicker: `Модуль ${level}.${order}`,
    title,
    subtitle: hr && !norm(title).includes(norm(hr)) ? hr : null,
  };
}

/** Емодзі типу тексту для списку й екрана читання (радісний дизайн, DESIGN_SYSTEM §3.4). Без прапорів. */
export const TEXT_TYPE_ICON: Record<TextType, string> = {
  message: '📱',
  chat: '💬',
  email: '✉️',
  notice: '📌',
  ad: '📢',
  menu: '🍽️',
  instruction: '📝',
  form: '📋',
  story: '📖',
  article: '🗞️',
  news: '📰',
  dialogue: '🗣️',
  sign: '🏷️',
};

export function textTypeIcon(t: string | null | undefined): string {
  return t && (TEXT_TYPES as readonly string[]).includes(t) ? TEXT_TYPE_ICON[t as TextType] : '📄';
}

/** Колонки reading_texts для екрана тексту (сторінка app/reading/[id]/page.tsx). */
export const READING_TEXT_COLUMNS =
  'id, code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio';

/** Рядок reading_texts → текст для ReadingView: словничок і питання — лише коректні записи. */
export function readingTextFrom(row: Record<string, unknown>): ReadingText {
  const str = (v: unknown, fallback = '') => (typeof v === 'string' ? v : fallback);
  const ratio = row.known_ratio === null || row.known_ratio === undefined ? null : Number(row.known_ratio);
  return {
    id: str(row.id),
    code: str(row.code),
    cefr: str(row.cefr),
    text_type: str(row.text_type),
    situation: typeof row.situation === 'string' ? row.situation : null,
    module_order: typeof row.module_order === 'number' ? row.module_order : null,
    title_ua: str(row.title_ua),
    title_hr: str(row.title_hr),
    body_hr: str(row.body_hr),
    body_ua: str(row.body_ua),
    glossary: [...glossaryIndex(row.glossary).values()],
    questions: questionsFrom(row.questions),
    word_count: typeof row.word_count === 'number' ? row.word_count : 0,
    known_ratio: ratio === null || Number.isNaN(ratio) ? null : ratio,
  };
}

/** Чи схожа офлайн-копія на текст для читання (копію іншого формату відкидаємо). */
export function isReadingText(v: unknown): v is ReadingText {
  if (!v || typeof v !== 'object') return false;
  const t = v as Partial<Record<keyof ReadingText, unknown>>;
  return (
    typeof t.id === 'string' &&
    typeof t.cefr === 'string' &&
    typeof t.title_hr === 'string' &&
    typeof t.body_hr === 'string' &&
    Array.isArray(t.glossary) &&
    Array.isArray(t.questions)
  );
}
