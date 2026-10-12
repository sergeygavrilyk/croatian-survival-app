/**
 * Говоріння (VS-003, §48–49): порівняння розпізнаного мовлення з очікуваною фразою.
 * Чиста логіка без браузера і БД — та сама функція працює в браузері (миттєвий відгук)
 * і на сервері (те, що зберігаємо).
 *
 * Пріоритет відгуку (§49): зміст → зрозумілість → конкретні слова. Без «відсотків вимови» (§48):
 * розпізнавання браузером — приблизне, тож оцінюємо, чи фразу зрозуміють, а не звуки.
 */
import { editDistance } from './answer.ts';

export type SpeechVerdict = 'great' | 'understandable' | 'almost' | 'retry' | 'no_speech';
export type WordStatus = 'ok' | 'close' | 'missed';

export interface SpeechEvaluation {
  verdict: SpeechVerdict;
  /** Внутрішня частка збігу 0…1 (не показуємо користувачу) */
  score: number;
  /** Найкращий варіант розпізнавання */
  transcript: string;
  /** Слова очікуваної фрази з позначкою, чи їх почули */
  words: Array<{ word: string; status: WordStatus }>;
  /** До 3 слів, над якими попрацювати (не почули або почули неточно) */
  practiceWords: string[];
}

export const SPEECH_VERDICTS: readonly SpeechVerdict[] = ['great', 'understandable', 'almost', 'retry', 'no_speech'];

/** Слова з фрази: нижній регістр, без розділових знаків (діакритики лишаються). */
export function speechTokens(text: string): string[] {
  return text
    .toLowerCase()
    .replace(/[.,!?;:"'«»„“”()…—–\-]/g, ' ')
    .split(/\s+/)
    .filter(Boolean);
}

/** Без діакритик: č ć → c, đ → d, š → s, ž → z (розпізнавач інколи їх губить). */
export function foldDiacritics(word: string): string {
  return word.normalize('NFD').replace(/[̀-ͯ]/g, '').replace(/đ/g, 'd').replace(/dj/g, 'd');
}

function matchStatus(target: string, spoken: string): 'ok' | 'close' | null {
  if (target === spoken) return 'ok';
  const a = foldDiacritics(target);
  const b = foldDiacritics(spoken);
  if (a === b) return 'ok';
  const allowed = a.length >= 8 ? 2 : a.length >= 4 ? 1 : 0;
  return allowed > 0 && editDistance(a, b) <= allowed ? 'close' : null;
}

/** Короткі службові слова (je, u, i, se, li…) важать менше: зміст несуть повнозначні. */
const weightOf = (word: string) => (foldDiacritics(word).length <= 2 ? 0.5 : 1);

function align(target: string[], spoken: string[]): WordStatus[] {
  // Найкраще вирівнювання (як LCS): ok = 2 бали, close = 1
  const n = target.length;
  const m = spoken.length;
  const dp: number[][] = Array.from({ length: n + 1 }, () => new Array<number>(m + 1).fill(0));
  for (let i = n - 1; i >= 0; i--) {
    for (let j = m - 1; j >= 0; j--) {
      const s = matchStatus(target[i], spoken[j]);
      const pair = s ? (s === 'ok' ? 2 : 1) + dp[i + 1][j + 1] : -1;
      dp[i][j] = Math.max(pair, dp[i + 1][j], dp[i][j + 1]);
    }
  }
  const out: WordStatus[] = [];
  let i = 0;
  let j = 0;
  while (i < n) {
    if (j < m) {
      const s = matchStatus(target[i], spoken[j]);
      if (s && dp[i][j] === (s === 'ok' ? 2 : 1) + dp[i + 1][j + 1]) {
        out.push(s);
        i++;
        j++;
        continue;
      }
      if (dp[i][j] === dp[i][j + 1]) {
        j++;
        continue;
      }
    }
    out.push('missed');
    i++;
  }
  return out;
}

function verdictFor(score: number, statuses: WordStatus[]): SpeechVerdict {
  if (score >= 0.9 && !statuses.includes('missed')) return 'great';
  if (score >= 0.7) return 'understandable';
  if (score >= 0.5) return 'almost';
  return 'retry';
}

/**
 * Оцінює кілька варіантів розпізнавання (n-best) і бере найкращий.
 * @param target очікувана хорватська фраза
 * @param transcripts варіанти, які повернув розпізнавач
 */
export function evaluateSpeech(target: string, transcripts: ReadonlyArray<string>): SpeechEvaluation {
  const targetWords = speechTokens(target);
  const candidates = transcripts.map((t) => t.trim()).filter(Boolean);
  const totalWeight = targetWords.reduce((s, w) => s + weightOf(w), 0) || 1;

  if (targetWords.length === 0 || candidates.length === 0) {
    return {
      verdict: 'no_speech',
      score: 0,
      transcript: candidates[0] ?? '',
      words: targetWords.map((word) => ({ word, status: 'missed' as const })),
      practiceWords: [],
    };
  }

  let best: { score: number; statuses: WordStatus[]; transcript: string } | null = null;
  for (const t of candidates) {
    const statuses = align(targetWords, speechTokens(t));
    const got = statuses.reduce((s, st, k) => s + (st === 'ok' ? 1 : st === 'close' ? 0.5 : 0) * weightOf(targetWords[k]), 0);
    const score = Math.round((got / totalWeight) * 1000) / 1000;
    if (!best || score > best.score) best = { score, statuses, transcript: t };
  }
  const { score, statuses, transcript } = best!;

  const practiceWords = targetWords
    .map((word, k) => ({ word, status: statuses[k], weight: weightOf(word) }))
    .filter((w) => w.status !== 'ok')
    .sort((a, b) => b.weight - a.weight) // спершу повнозначні слова
    .slice(0, 3)
    .map((w) => w.word);

  return {
    verdict: verdictFor(score, statuses),
    score,
    transcript,
    words: targetWords.map((word, k) => ({ word, status: statuses[k] })),
    practiceWords,
  };
}

/**
 * Позначки для показу фрази в оригінальному написанні (з великими літерами й розділовими знаками).
 * Кожен шматок між пробілами отримує статус своїх слів (найгірший, якщо слів кілька), чистий розділовий знак — null.
 */
export function annotateOriginal(
  target: string,
  words: ReadonlyArray<{ word: string; status: WordStatus }>,
): Array<{ text: string; status: WordStatus | null }> {
  const rank: Record<WordStatus, number> = { ok: 0, close: 1, missed: 2 };
  let k = 0;
  return target
    .trim()
    .split(/\s+/)
    .filter(Boolean)
    .map((piece) => {
      const n = speechTokens(piece).length;
      let status: WordStatus | null = null;
      for (let i = 0; i < n && k < words.length; i++, k++) {
        const s = words[k].status;
        if (status === null || rank[s] > rank[status]) status = s;
      }
      return { text: piece, status };
    });
}
