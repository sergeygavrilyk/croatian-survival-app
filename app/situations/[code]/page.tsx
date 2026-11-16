import { headers } from 'next/headers';
import { notFound } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import { isSituationCode, situationInfo } from '@/lib/situations';
import { getScenario } from '@/lib/roleplay';
import { newSeed } from '@/lib/random';
import { PREFETCH_HEADER, isPrefetchRequest } from '@/lib/offline-prefetch';
import SituationView, { type SituationDialogue, type SituationPhrase } from '@/components/SituationView';

type Params = { params: Promise<{ code: string }> };

export async function generateMetadata({ params }: Params) {
  const { code } = await params;
  return { title: `${isSituationCode(code) ? situationInfo(code).label : 'Ситуація'} · Croatian Survival App` };
}

/**
 * Ситуація: фрази й діалоги однієї теми (docs/DESIGN_SYSTEM.md §9.4). Лише PUBLISHED.
 * Збереження наперед для офлайну (§76, рішення власника 2026-11-16: «всі фрази всіх ситуацій»): запит із
 * заголовком X-Offline-Prefetch отримує сторінку лише з фразами, а діалоги — числом (вони лише з інтернетом).
 * Відкрита онлайн сторінка — повна і в кеші замінює цю копію.
 */
export default async function SituationPage({ params }: Params) {
  const { code } = await params;
  if (!isSituationCode(code)) notFound();
  if (isPrefetchRequest((await headers()).get(PREFETCH_HEADER))) return phrasesOnlyPage(code);

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
      // спершу простіші (A0 → A1), а в межах рівня — за порядком уроків
      .order('level', { ascending: true, nullsFirst: false })
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
      seed={newSeed()}
    />
  );
}

/** Копія для офлайну: фрази ситуації і кількість діалогів (без реплік — вони важать у десятки разів більше). */
async function phrasesOnlyPage(code: string) {
  const supabase = await createClient();
  const [phrasesRes, convRes] = await Promise.all([
    supabase
      .from('phrases')
      .select('id, text_hr, ukrainian_translation, cefr')
      .eq('situation', code)
      .eq('status', 'PUBLISHED')
      .order('cefr', { ascending: true, nullsFirst: false })
      .order('text_hr', { ascending: true }),
    supabase.from('conversations').select('id', { count: 'exact', head: true }).eq('situation', code).eq('status', 'PUBLISHED'),
  ]);
  const phrases: SituationPhrase[] = phrasesRes.data ?? [];
  // збій чи порожньо → 404: у кеш потрапляє лише відповідь 200 (lib/pwa-cache.ts), тож нічого зламаного не збережемо
  if (phrasesRes.error || phrases.length === 0) notFound();
  const scenario = getScenario(code);
  return (
    <SituationView
      situation={situationInfo(code)}
      phrases={phrases}
      dialogues={[]}
      dialoguesOnline={convRes.error ? 0 : (convRes.count ?? 0)}
      roleplay={scenario ? { aiRoleUa: scenario.aiRoleUa, goalUa: scenario.goalUa } : null}
      seed={newSeed()}
    />
  );
}
