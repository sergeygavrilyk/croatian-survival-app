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
  /** Модуль уроку — для пропозиції перевірки модуля */
  module_id?: string | null;
  module_title?: string | null;
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

export interface SessionCheer {
  emoji: '🎉' | '💪' | '🌱';
  title: string;
}

/**
 * Підбадьорення в кінці сесії (тренажер, помилки, типові помилки, читання) за часткою правильних відповідей.
 * Без «провалу»: навіть 0 з 10 — «Крок за кроком» (DESIGN_SYSTEM §3.4, §9.2 — підтримувальний тон).
 */
export function sessionCheer(correct: number, total: number): SessionCheer {
  const share = total > 0 ? Math.max(0, correct) / total : 0;
  if (share >= 0.8) return { emoji: '🎉', title: 'Чудово!' };
  if (share >= 0.5) return { emoji: '💪', title: 'Добре попрацювали!' };
  return { emoji: '🌱', title: 'Крок за кроком!' };
}

// ---------------------------------------------------------------- пропозиція перевірки (§60)

export interface TodayAssessment {
  id: string;
  slug: string;
  /** module / mid / final */
  kind: string;
  /** Для перевірки модуля — її модуль */
  module_id: string | null;
  estimated_minutes: number | null;
}

export interface AssessmentSuggestion {
  slug: string;
  kind: 'module' | 'mid' | 'final';
  /** Номер модуля (для перевірки модуля) або найбільший номер пройденого модуля (середина / фінал) */
  moduleOrder: number;
  moduleTitle: string | null;
  minutes: number | null;
}

/** Середина рівня — після модулів 1–5 (як у «Перевірках рівня»: «Модулі 1–5»). */
const MID_LAST_MODULE = 5;

/**
 * Яку перевірку запропонувати на «Сьогодні» (до 2026-10-21 — лише після всього рівня).
 * Модуль вважається пройденим, коли пройдено всі його опубліковані уроки. Пропонуємо лише перевірку,
 * яку ще жодного разу не починали (після невдалої спроби не нагадуємо — тест не блокує уроки, рішення власника),
 * найсвіжішу: фінал → середина → модуль з найбільшим номером.
 */
export function suggestAssessment(
  lessons: ReadonlyArray<TodayLesson>,
  completed: ReadonlySet<string>,
  tests: ReadonlyArray<TodayAssessment>,
  attempted: ReadonlySet<string>,
): AssessmentSuggestion | null {
  const modules = new Map<string, { order: number; title: string | null; total: number; done: number }>();
  for (const l of lessons) {
    if (!l.module_id) continue;
    const m = modules.get(l.module_id) ?? { order: l.module_order, title: l.module_title ?? null, total: 0, done: 0 };
    m.total += 1;
    if (completed.has(l.id)) m.done += 1;
    modules.set(l.module_id, m);
  }
  const all = [...modules.values()];
  if (all.length === 0) return null;
  const isDone = (m: { total: number; done: number }) => m.total > 0 && m.done === m.total;
  const doneOrders = all.filter(isDone).map((m) => m.order);
  if (doneOrders.length === 0) return null;
  const lastDone = Math.max(...doneOrders);

  const candidates: Array<AssessmentSuggestion & { rank: number }> = [];
  for (const t of tests) {
    if (attempted.has(t.id)) continue;
    if (t.kind === 'module' && t.module_id) {
      const m = modules.get(t.module_id);
      if (m && isDone(m)) {
        candidates.push({ slug: t.slug, kind: 'module', moduleOrder: m.order, moduleTitle: m.title, minutes: t.estimated_minutes, rank: m.order });
      }
    } else if (t.kind === 'mid') {
      const firstHalf = all.filter((m) => m.order <= MID_LAST_MODULE);
      if (firstHalf.length > 0 && firstHalf.every(isDone)) {
        candidates.push({ slug: t.slug, kind: 'mid', moduleOrder: lastDone, moduleTitle: null, minutes: t.estimated_minutes, rank: MID_LAST_MODULE + 0.5 });
      }
    } else if (t.kind === 'final') {
      if (all.every(isDone)) {
        candidates.push({ slug: t.slug, kind: 'final', moduleOrder: lastDone, moduleTitle: null, minutes: t.estimated_minutes, rank: 1000 });
      }
    }
  }
  if (candidates.length === 0) return null;
  candidates.sort((a, b) => b.rank - a.rank);
  const best = candidates[0];
  return { slug: best.slug, kind: best.kind, moduleOrder: best.moduleOrder, moduleTitle: best.moduleTitle, minutes: best.minutes };
}
