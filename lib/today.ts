/**
 * Екран «Сьогодні» (docs/DESIGN_SYSTEM.md §7.1: одна головна дія «Продовжити», повторення, «Що сказати?»).
 * Чиста логіка без БД — тестується в today.test.ts.
 */

export type Greeting = 'Dobro jutro' | 'Dobar dan' | 'Dobra večer';

/** Година (0–23) у часовому поясі користувача; невідомий пояс → UTC. */
export function hourIn(now: Date, timeZone?: string | null): number {
  const fmt = (tz: string) =>
    Number(new Intl.DateTimeFormat('en-GB', { timeZone: tz, hour: '2-digit', hourCycle: 'h23' }).format(now));
  try {
    return fmt(timeZone || 'UTC');
  } catch {
    return fmt('UTC');
  }
}

/**
 * Привітання за годиною користувача. Рахується на сервері з часовим поясом профілю: якщо рахувати
 * в браузері, сервер і браузер дали б різний текст (помилка React #418).
 */
export function greetingFor(now: Date, timeZone?: string | null): Greeting {
  const h = hourIn(now, timeZone);
  if (h >= 4 && h < 12) return 'Dobro jutro';
  if (h >= 12 && h < 18) return 'Dobar dan';
  return 'Dobra večer';
}

export interface TodayLesson {
  id: string;
  title_ua: string;
  order_index: number;
  unit_order: number;
  module_order: number;
}

export interface NextLesson {
  /** Наступний непройдений урок у порядку програми; null — усі пройдено або уроків немає */
  lesson: TodayLesson | null;
  done: number;
  total: number;
}

/** Наступний урок рівня: перший за порядком (модуль → юніт → урок), якого ще немає серед пройдених. */
export function nextLesson(lessons: ReadonlyArray<TodayLesson>, completed: ReadonlySet<string>): NextLesson {
  const ordered = [...lessons].sort(
    (a, b) => a.module_order - b.module_order || a.unit_order - b.unit_order || a.order_index - b.order_index,
  );
  const done = ordered.filter((l) => completed.has(l.id)).length;
  return { lesson: ordered.find((l) => !completed.has(l.id)) ?? null, done, total: ordered.length };
}

/** Рівень для «Продовжити»: рівень з профілю, якщо для нього вже є уроки, інакше A0. */
export function todayLevel(currentLevel: string | null | undefined, levelsWithLessons: ReadonlyArray<string>): string {
  return currentLevel && levelsWithLessons.includes(currentLevel) ? currentLevel : 'A0';
}

/** Ім'я для привітання: з профілю акаунта або частина email до «@». */
export function displayName(fullName: string | null | undefined, email: string | null | undefined): string {
  const name = (fullName ?? '').trim();
  if (name) return name.split(/\s+/)[0];
  const local = (email ?? '').split('@')[0].trim();
  return local || 'друже';
}

/** Підбадьорення під «Останні 7 днів» за кількістю днів із навчанням. */
export function weekCheer(activeDays: number): string {
  if (activeDays >= 7) return 'Цілий тиждень без пропусків — неймовірно! 🏆';
  if (activeDays >= 5) return 'Чудовий тиждень, так тримати! 💪';
  if (activeDays >= 3) return 'Добрий ритм — ще трохи, і буде звичка 🌱';
  if (activeDays >= 1) return 'Гарний початок! Повертайтеся завтра 🙂';
  return 'Почніть сьогодні — 5 хвилин уже рахуються ✨';
}
