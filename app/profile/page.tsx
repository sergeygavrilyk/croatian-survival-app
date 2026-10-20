import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import { LEARNING_EVENTS, summarizeProgress, type ProgressCard } from '@/lib/progress';
import ProfileView from '@/components/ProfileView';
import { displayName } from '@/lib/today';
import { parseMascot } from '@/lib/mascot';

export const metadata = { title: 'Профіль · Croatian Survival App' };

/** Профіль: прогрес (§10, §42 — без XP і загального «рівня у %»), рівень і цілі, акаунт. */
export default async function ProfilePage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const since = new Date(Date.now() - 8 * 24 * 60 * 60 * 1000).toISOString();
  const [profileRes, cardsRes, reviewsRes, lessonsRes, attemptRes, eventsRes, mascotRes] = await Promise.all([
    supabase
      .from('profiles')
      .select('learning_goals, daily_goal_minutes, current_level, timezone')
      .eq('id', user.id)
      .maybeSingle(),
    supabase.from('user_progress').select('interval_days, next_review_date, lexemes(cefr)').eq('user_id', user.id),
    supabase.from('srs_reviews').select('created_at').eq('user_id', user.id).gte('created_at', since),
    supabase
      .from('lesson_progress')
      .select('id', { count: 'exact', head: true })
      .eq('user_id', user.id)
      .eq('status', 'completed'),
    supabase
      .from('assessment_attempts')
      .select('estimated_cefr, confidence, recommended_start, completed_at')
      .eq('user_id', user.id)
      .order('completed_at', { ascending: false })
      .limit(1)
      .maybeSingle(),
    // Активність — усе навчання, як на «Сьогодні» (уроки, вправи, читання, говоріння), а не лише картки
    supabase
      .from('analytics_events')
      .select('occurred_at')
      .eq('user_id', user.id)
      .in('event_name', [...LEARNING_EVENTS])
      .gte('occurred_at', since)
      .limit(5000),
    // Талісман — окремим запитом (міграція M18): якщо колонки ще немає, решта профілю показується
    supabase.from('profiles').select('mascot').eq('id', user.id).maybeSingle(),
  ]);

  // Якщо міграцію M7 ще не застосовано, полів профілю немає — показуємо прогрес без них
  const profile = profileRes.error ? null : profileRes.data;
  const cards: ProgressCard[] = (cardsRes.data ?? []).map((row) => {
    const lexeme = row.lexemes as { cefr?: string | null } | { cefr?: string | null }[] | null;
    const cefr = Array.isArray(lexeme) ? lexeme[0]?.cefr : lexeme?.cefr;
    return { interval_days: row.interval_days, next_review_date: row.next_review_date, cefr: cefr ?? null };
  });

  const summary = summarizeProgress({
    now: new Date(),
    timeZone: profile?.timezone ?? 'Europe/Zagreb',
    cards,
    reviews: [
      ...(reviewsRes.data ?? []),
      ...((eventsRes.data ?? []) as Array<{ occurred_at: string }>).map((e) => ({ created_at: e.occurred_at })),
    ],
    lessonsCompleted: lessonsRes.count ?? 0,
  });

  return (
    <ProfileView
      email={user.email ?? ''}
      name={displayName(user.user_metadata?.full_name as string | undefined, user.email)}
      summary={summary}
      progressError={Boolean(cardsRes.error || reviewsRes.error || lessonsRes.error)}
      profile={
        profile
          ? {
              goals: profile.learning_goals ?? [],
              dailyGoalMinutes: profile.daily_goal_minutes,
              currentLevel: profile.current_level,
            }
          : null
      }
      placement={attemptRes.error || !attemptRes.data ? null : attemptRes.data}
      mascot={mascotRes.error ? null : parseMascot((mascotRes.data as { mascot?: string | null } | null)?.mascot)}
      mascotAvailable={!mascotRes.error}
    />
  );
}
