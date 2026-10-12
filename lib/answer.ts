/**
 * Перевірка слова, яке користувач ввів сам (VS-001: «produce the Croatian word»),
 * і приклад речення з пропуском. Чиста логіка — без бази і без браузера.
 */
import { normalizeCroatian } from './srs.ts';

export type AnswerVerdict =
  | 'exact'       // збіг повністю
  | 'diacritics'  // правильно, але без/з іншими діакритиками (kuca → kuća)
  | 'typo'        // одна дрібна одруківка в довгому слові
  | 'wrong'
  | 'empty';

export interface AnswerCheck {
  verdict: AnswerVerdict;
  /** Зараховується як правильна відповідь у SRS */
  correct: boolean;
  /** Правильний варіант для показу користувачу */
  expected: string;
}

/** Нижній регістр, без розділових знаків і зайвих пробілів (діакритики лишаються). */
export function normalizeAnswer(text: string): string {
  return text
    .toLowerCase()
    .replace(/[.,!?;:"'«»„“”()…]/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

/** Варіанти правильної відповіді: «tipkovnica / tastatura» → два варіанти; «(pl)» прибираємо. */
export function answerVariants(lemma: string): string[] {
  return lemma
    .replace(/\([^)]*\)/g, ' ')
    .split(/[\/;]/)
    .map((v) => normalizeAnswer(v))
    .filter(Boolean);
}

/** Відстань Левенштейна (кількість вставок/видалень/замін). */
export function editDistance(a: string, b: string): number {
  if (a === b) return 0;
  const prev = Array.from({ length: b.length + 1 }, (_, i) => i);
  for (let i = 1; i <= a.length; i++) {
    let diag = prev[0];
    prev[0] = i;
    for (let j = 1; j <= b.length; j++) {
      const tmp = prev[j];
      prev[j] = Math.min(prev[j] + 1, prev[j - 1] + 1, diag + (a[i - 1] === b[j - 1] ? 0 : 1));
      diag = tmp;
    }
  }
  return prev[b.length];
}

/** Скільки одруківок пробачаємо: короткі слова — жодної, довгі — одну-дві. */
function allowedTypos(length: number): number {
  if (length >= 10) return 2;
  if (length >= 5) return 1;
  return 0;
}

export function checkTypedAnswer(input: string, lemma: string): AnswerCheck {
  const expected = lemma.trim();
  const given = normalizeAnswer(input);
  if (!given) return { verdict: 'empty', correct: false, expected };

  const variants = answerVariants(lemma);
  if (variants.length === 0) return { verdict: 'wrong', correct: false, expected };

  if (variants.some((v) => v === given)) return { verdict: 'exact', correct: true, expected };

  const givenPlain = normalizeCroatian(given);
  if (variants.some((v) => normalizeCroatian(v) === givenPlain)) {
    return { verdict: 'diacritics', correct: true, expected };
  }

  if (variants.some((v) => {
    const plain = normalizeCroatian(v);
    const limit = allowedTypos(plain.length);
    return limit > 0 && editDistance(plain, givenPlain) <= limit;
  })) {
    return { verdict: 'typo', correct: true, expected };
  }

  return { verdict: 'wrong', correct: false, expected };
}

export const BLANK = '_____';

/**
 * Приклад речення з пропуском замість слова (з урахуванням відмінків:
 * «kuća» ховає і «kući», «kuću»). Якщо слово в прикладі не знайдено — found = false,
 * і приклад не можна показувати до відповіді (він видав би підказку або заплутав).
 */
export function maskExample(example: string, lemma: string): { text: string; found: boolean } {
  // Значущі слова леми (без «se», коротких прийменників тощо)
  const lemmaWords = answerVariants(lemma)
    .flatMap((v) => v.split(' '))
    .map((w) => normalizeCroatian(w))
    .filter((w) => w.length >= 3);
  if (lemmaWords.length === 0) return { text: example, found: false };

  // Основа слова: відкидаємо закінчення, щоб знайти відмінкові форми, але не коротше 3 літер
  const stems = lemmaWords.map((w) => w.slice(0, w.length >= 6 ? w.length - 2 : Math.max(3, w.length - 1)));

  let found = false;
  const text = example.replace(/[\p{L}]+/gu, (token) => {
    const t = normalizeCroatian(token.toLowerCase());
    const hit = stems.some((stem, i) => {
      const len = lemmaWords[i].length;
      // Короткі слова (до 4 літер) — лише форми близької довжини: «kuća → kući», але не «more → moramo»
      const maxLen = len <= 4 ? len + 1 : len + 4;
      return t.startsWith(stem) && t.length <= maxLen;
    });
    if (hit) {
      found = true;
      return BLANK;
    }
    return token;
  });

  return { text, found };
}

/** Перший приклад-рядок із jsonb-масиву examples (або undefined). */
export function firstExample(examples: unknown): string | undefined {
  if (!Array.isArray(examples)) return undefined;
  const first = examples.find((e) => typeof e === 'string' && e.trim());
  return typeof first === 'string' ? first.trim() : undefined;
}
