import { notFound } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import { isSituationCode, situationInfo } from '@/lib/situations';
import { getScenario } from '@/lib/roleplay';
import SituationView, { type SituationDialogue, type SituationPhrase } from '@/components/SituationView';

type Params = { params: Promise<{ code: string }> };

export async function generateMetadata({ params }: Params) {
  const { code } = await params;
  return { title: `${isSituationCode(code) ? situationInfo(code).label : 'Ситуація'} · Croatian Survival App` };
}

/** Ситуація: фрази й діалоги однієї теми (docs/DESIGN_SYSTEM.md §9.4). Лише PUBLISHED. */
export default async function SituationPage({ params }: Params) {
  const { code } = await params;
  if (!isSituationCode(code)) notFound();

  const supabase = await createClient();
  const [phrasesRes, convRes] = await Promise.all([
    supabase
      .from('phrases')
      .select('id, text_hr, ukrainian_translation, cefr')
      .eq('situation', code)
      .eq('status', 'PUBLISHED')
      .order('cefr', { ascending: true, nullsFirst: false })
      .order('text_hr', { ascending: true }),
    supabase
      .from('conversations')
      .select('id, title_ua, title_hr, level')
      .eq('situation', code)
      .eq('status', 'PUBLISHED')
      .order('order_index', { ascending: true }),
  ]);

  const conversations = convRes.data ?? [];
  const turnsRes = conversations.length
    ? await supabase
        .from('conversation_turns')
        .select('id, conversation_id, speaker_name, hr_text, ua_translation, order_index')
        .in('conversation_id', conversations.map((c) => c.id))
        .order('order_index', { ascending: true })
    : { data: [], error: null };

  const loadError = Boolean(phrasesRes.error || convRes.error || turnsRes.error);
  const phrases: SituationPhrase[] = phrasesRes.data ?? [];
  const dialogues: SituationDialogue[] = conversations.map((c) => ({
    ...c,
    turns: (turnsRes.data ?? []).filter((t) => t.conversation_id === c.id),
  }));

  if (!loadError && phrases.length === 0 && dialogues.length === 0) notFound();

  const scenario = getScenario(code);
  return (
    <SituationView
      situation={situationInfo(code)}
      phrases={phrases}
      dialogues={dialogues}
      loadError={loadError}
      roleplay={scenario ? { aiRoleUa: scenario.aiRoleUa, goalUa: scenario.goalUa } : null}
    />
  );
}
