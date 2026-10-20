/**
 * Святковий екран після уроку (рішення власника 2026-10-20: конфеті, «+N слів», серія днів 🔥) — чиста логіка.
 * Тести — lib/celebration.test.ts. Вигляд — LessonPlayer (SummaryStep) + SessionDone + components/ui/Confetti.tsx.
 *
 * Тон (docs/DESIGN_SYSTEM.md §10): радіємо вмінню й регулярності, без провини й тиску —
 * жодних «не переривайте серію!», «ви втратите…». Серія — приємний бонус, не головне.
 */
import { pluralUk } from './format.ts';
import { seededRandom } from './random.ts';

export interface CelebrationInput {
  /** Слова уроку, які щойно вперше потрапили в повторення */
  newWords: number;
  /** Усі слова уроку (без повторів) */
  lessonWords: number;
  /** Днів поспіль із навчанням, разом із сьогодні; null — невідомо (не показуємо) */
  streak: number | null;
}

export interface StatTileData {
  emoji: string;
  value: string;
  label: string;
  tone: 'success' | 'warning';
}

export interface Celebration {
  /** Плитки під заголовком: «+N нових слів», «🔥 N днів поспіль» */
  tiles: StatTileData[];
  /** Короткий рядок про серію; null — серії не показуємо */
  streakNote: string | null;
  /** Підказка про повторення завтра; null — нових слів немає */
  reviewNote: string | null;
}

/** Круглі дати серії — окреме привітання. */
const STREAK_MILESTONES: Record<number, string> = {
  3: 'Три дні поспіль — звичка вже народжується!',
  7: 'Тиждень поспіль! Ви чудово тримаєте ритм.',
  14: 'Два тижні поспіль — це вже справжня звичка!',
  30: 'Місяць поспіль! Неймовірна наполегливість.',
  50: '50 днів поспіль — вражає!',
  100: '100 днів поспіль! Справжній рекорд.',
  365: 'Рік поспіль! Čestitamo!',
};

export function streakNote(streak: number | null): string | null {
  if (streak === null || streak < 1) return null;
  if (streak === 1) return 'Перший день серії! Завтра — другий 🔥';
  if (STREAK_MILESTONES[streak]) return STREAK_MILESTONES[streak];
  return `${streak} ${pluralUk(streak, ['день', 'дні', 'днів'])} поспіль — так тримати!`;
}

export function lessonCelebration(input: CelebrationInput): Celebration {
  const newWords = Math.max(0, Math.trunc(input.newWords));
  const lessonWords = Math.max(0, Math.trunc(input.lessonWords));
  const tiles: StatTileData[] = [];
  if (newWords > 0) {
    tiles.push({ emoji: '📚', value: `+${newWords}`, label: pluralUk(newWords, ['нове слово', 'нові слова', 'нових слів']), tone: 'success' });
  } else if (lessonWords > 0) {
    // Урок пройдено вдруге: нових слів немає, але слова уроку повторили
    tiles.push({ emoji: '📚', value: `${lessonWords}`, label: pluralUk(lessonWords, ['слово повторили', 'слова повторили', 'слів повторили']), tone: 'success' });
  }
  const streak = input.streak !== null && input.streak >= 1 ? Math.trunc(input.streak) : null;
  if (streak !== null) {
    tiles.push({ emoji: '🔥', value: `${streak}`, label: pluralUk(streak, ['день поспіль', 'дні поспіль', 'днів поспіль']), tone: 'warning' });
  }
  return {
    tiles,
    streakNote: streakNote(streak),
    reviewNote: newWords > 0 ? `${newWords === 1 ? 'Нове слово чекає' : 'Нові слова чекають'} на вас у повторенні завтра.` : null,
  };
}

// ---------------------------------------------------------------- конфеті

export interface ConfettiPiece {
  /** Відступ зліва, % ширини екрана */
  left: number;
  /** Затримка й тривалість падіння, мс */
  delay: number;
  duration: number;
  /** Розмір, px */
  width: number;
  height: number;
  /** Зсув убік за час падіння, px, і оберт, градуси */
  drift: number;
  spin: number;
  /** Індекс кольору з CONFETTI_COLORS */
  color: number;
  round: boolean;
}

/** Кольори рівнів A0–B2 + бурштиновий і зелений — радісно, але з палітри застосунку (DESIGN_SYSTEM §3.4). */
export const CONFETTI_COLORS = [
  'var(--color-level-a0)',
  'var(--color-level-a1)',
  'var(--color-level-a2)',
  'var(--color-level-b1)',
  'var(--color-level-b2)',
  'var(--color-warning)',
  'var(--color-success)',
] as const;

/**
 * Шматочки конфеті: однаковий seed → однаковий набір (без Math.random під час рендеру, щоб React не бачив розбіжностей).
 * Падають 1,8–3,4 с, стартують протягом перших 0,6 с.
 */
export function confettiPieces(seed: string, count = 48): ConfettiPiece[] {
  const rnd = seededRandom(seed);
  const n = Math.max(0, Math.min(150, Math.trunc(count)));
  return Array.from({ length: n }, () => {
    const round = rnd() < 0.3;
    const width = Math.round(6 + rnd() * 6);
    return {
      left: Math.round(rnd() * 1000) / 10,
      delay: Math.round(rnd() * 600),
      duration: Math.round(1800 + rnd() * 1600),
      width,
      height: round ? width : Math.round(width * (1.4 + rnd() * 0.8)),
      drift: Math.round((rnd() - 0.5) * 160),
      spin: Math.round((rnd() < 0.5 ? -1 : 1) * (240 + rnd() * 480)),
      color: Math.floor(rnd() * CONFETTI_COLORS.length),
      round,
    };
  });
}
