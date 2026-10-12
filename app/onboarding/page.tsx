import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import OnboardingFlow from '@/components/OnboardingFlow';

export const metadata = { title: 'Налаштування навчання · Croatian Survival App' };

/** Онбординг (§90, §116): мета, щоденна ціль, рівень, тест рівня (§59). Повноекранний, без нижньої панелі. */
export default async function OnboardingPage() {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: profile } = await supabase
    .from('profiles')
    .select('learning_goals, daily_goal_minutes, current_level, onboarding_completed')
    .eq('id', user.id)
    .maybeSingle();

  return (
    <OnboardingFlow
      initialGoals={profile?.learning_goals ?? []}
      initialDailyGoal={profile?.daily_goal_minutes ?? null}
      isRepeat={Boolean(profile?.onboarding_completed)}
    />
  );
}
