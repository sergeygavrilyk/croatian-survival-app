import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import { DEFAULT_TIME_ZONE, LEARNING_EVENTS, activityWeek, learningStreak } from '@/lib/progress';
import { displayName, greetingFor, nextLesson, suggestAssessment, todayLevel, type TodayAssessment, type TodayLesson } from '@/lib/today';
import { parseMascot } from '@/lib/mascot';
import TodayView from '@/components/TodayView';

export const metadata = { title: 'Сьогодні · Croatian Survival App' };

const LESSON_LEVELS = ['A0', 'A1'];

type ModuleRef = { id: string; order_index: number | null; title_ua: string | null };
type UnitRef = { order_index: number | null; modules: ModuleRef | ModuleRef[] | null };
type LessonRow = {
  id: string;
  title_ua: string;
  order_index: number | null;
  units: UnitRef | UnitRef[] | null;
};

const one = <T,>(v: T | T[] | null | undefined): T | null => (Array.isArray(v) ? v[0] ?? null : v ?? null);

/**
 * «Сьогодні» (docs/DESIGN_SYSTEM.md §7.1): одна головна дія «Продовжити» (наступний урок), повторення на сьогодні,
 * «Мені потрібно сказати…», активність за 7 днів. Сервер бере дані (§75), TodayView — інтерактив.
 * Привітання, дні й серія рахуються тут, у часовому поясі профілю, — сервер і браузер показують однаковий текст.
 */
export default async function TodayPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile, error: profileError } = await supabase
    .from('profiles')
    .select('onboarding_completed, current_level, timezone')
    .eq('id', user.id)
    .maybeSingle();
  // Новий користувач → онбординг (M7). Якщо полів ще немає в БД — не заважаємо.
  if (!profileError && profile && profile.onboarding_completed === false) redirect('/onboarding');

  const now = new Date();
  const timeZone = (!profileError && profile?.timezone) || DEFAULT_TIME_ZONE;
  const level = todayLevel(!profileError ? profile?.current_level : null, LESSON_LEVELS);
  const since = new Date(now.getTime() - 120 * 24 * 60 * 60 * 1000).toISOString();

  const [dueRes, lessonsRes, doneRes, eventsRes, reviewsRes, mascotRes, testsRes, attemptsRes] = await Promise.all([
    supabase
      .from('user_progress')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', user.id)
      .lte('next_review_date', now.toISOString()),
    supabase
      .from('lessons')
      .select('id, title_ua, order_index, units!inner(order_index, modules!inner(id, order_index, title_ua))')
      .eq('level_code', level)
      .eq('status', 'PUBLISHED'),
    supabase.from('lesson_progress').select('lesson_id').eq('user_id', user.id).eq('status', 'completed'),
    // Активність і 🔥 — усе навчання (lib/progress.ts, баг 2026-10-20)
    supabase
      .from('analytics_events')
      .select('occurred_at')
      .eq('user_id', user.id)
      .in('event_name', [...LEARNING_EVENTS])
      .gte('occurred_at', since)
      .order('occurred_at', { ascending: false })
      .limit(5000),
    supabase
      .from('srs_reviews')
      .select('created_at')
      .eq('user_id', user.id)
      .gte('created_at', since)
      .order('created_at', { ascending: false })
      .limit(5000),
    // Талісман — окремим запитом: якщо міграції M18 ще немає, решта профілю не страждає
    supabase.from('profiles').select('mascot').eq('id', user.id).maybeSingle(),
    // Перевірки рівня (§60) — щоб запропонувати перевірку щойно пройденого модуля
    supabase
      .from('assessments')
      .select('id, slug, kind, module_id, estimated_minutes')
      .eq('cefr', level)
      .in('kind', ['module', 'mid', 'final'])
      .eq('status', 'PUBLISHED')
      .limit(50),
    supabase.from('assessment_attempts').select('assessment_id').eq('user_id', user.id).limit(1000),
  ]);

  const lessons: TodayLesson[] = ((lessonsRes.data ?? []) as LessonRow[]).map((row) => {
    const unit = one(row.units);
    const mod = one(unit?.modules ?? null);
    return {
      id: row.id,
      title_ua: row.title_ua,
      order_index: row.order_index ?? 0,
      unit_order: unit?.order_index ?? 0,
      module_order: mod?.order_index ?? 0,
      module_id: mod?.id ?? null,
      module_title: mod?.title_ua ?? null,
    };
  });
  const completed = new Set(((doneRes.data ?? []) as Array<{ lesson_id: string }>).map((r) => r.lesson_id));
  const next = nextLesson(lessons, completed);
  // Збій запиту перевірок не ламає «Сьогодні» — просто без пропозиції
  const suggestion =
    testsRes.error || attemptsRes.error
      ? null
      : suggestAssessment(
          lessons,
          completed,
          (testsRes.data ?? []) as TodayAssessment[],
          new Set(((attemptsRes.data ?? []) as Array<{ assessment_id: string }>).map((r) => r.assessment_id)),
        );

  const timestamps = [
    ...((eventsRes.data ?? []) as Array<{ occurred_at: string }>).map((r) => r.occurred_at),
    ...((reviewsRes.data ?? []) as Array<{ created_at: string }>).map((r) => r.created_at),
  ];

  return (
    <TodayView
      name={displayName(user.user_metadata?.full_name as string | undefined, user.email)}
      greeting={greetingFor(now, timeZone)}
      level={level}
      next={next.lesson ? { id: next.lesson.id, title: next.lesson.title_ua, moduleOrder: next.lesson.module_order } : null}
      lessonsDone={next.done}
      lessonsTotal={next.total}
      dueCount={dueRes.count ?? 0}
      week={activityWeek(timestamps, now, timeZone)}
      streak={learningStreak(timestamps, now, timeZone)}
      loadFailed={Boolean(lessonsRes.error || dueRes.error)}
      assessment={suggestion}
      mascot={mascotRes.error ? null : parseMascot((mascotRes.data as { mascot?: string | null } | null)?.mascot)}
    />
  );
}
