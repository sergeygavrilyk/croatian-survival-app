import { notFound, redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import { isSituationCode, situationInfo } from '@/lib/situations';
import { getScenario, isCefr } from '@/lib/roleplay';
import RoleplayChat from '@/components/RoleplayChat';

type Params = { params: Promise<{ code: string }> };

export const metadata = { title: 'Рольова гра · Croatian Survival App' };

/** Рольова гра з AI у ситуації (VS-004). Повноекранна, без нижньої панелі. */
export default async function RoleplayPage({ params }: Params) {
  const { code } = await params;
  const scenario = isSituationCode(code) ? getScenario(code) : null;
  if (!scenario) notFound();

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const [profileRes, phrasesRes] = await Promise.all([
    supabase.from('profiles').select('current_level').eq('id', user.id).maybeSingle(),
    supabase
      .from('phrases')
      .select('id, text_hr, ukrainian_translation')
      .eq('situation', code)
      .eq('status', 'PUBLISHED')
      .order('cefr', { ascending: true, nullsFirst: false })
      .limit(8),
  ]);

  const level = isCefr(profileRes.data?.current_level) ? profileRes.data!.current_level : 'A1';
  return (
    <RoleplayChat
      situation={situationInfo(code)}
      scenario={scenario}
      level={level}
      phrases={phrasesRes.data ?? []}
    />
  );
}
