'use server';

import { createClient } from '@/utils/supabase/server';
import { isSituationCode } from '@/lib/situations';
import { MODULE_TEXTS, nextLessonIds, planUrls, type OrderedLesson } from '@/lib/offline-prefetch';

type Supabase = Awaited<ReturnType<typeof createClient>>;

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Що зберегти на телефоні наперед (§76, рішення власника 2026-11-16): адреси сторінок.
 * - `lessonId` — наступні уроки модуля цього уроку (з ним самим, якщо `includeCurrent`) і тексти модуля;
 * - `situations` — список ситуацій і кожна ситуація з фразами.
 * Усе — з опублікованого контенту, тож B1 / B2 підхопляться самі. Збій — порожній план (навчання не ламаємо).
 */
export async function getOfflinePlan(input: {
  lessonId?: string | null;
  includeCurrent?: boolean;
  situations?: boolean;
}): Promise<{ urls: string[] }> {
  try {
    const supabase = await createClient();
    const {
      data: { user },
    } = await supabase.auth.getUser();
    if (!user) return { urls: [] };

    const lessonId = input.lessonId && UUID_RE.test(input.lessonId) ? input.lessonId : null;
    const [module, situationCodes] = await Promise.all([
      lessonId ? moduleLessonsAndTexts(supabase, lessonId, Boolean(input.includeCurrent)) : Promise.resolve({ lessonIds: [], textIds: [] }),
      input.situations ? situationsWithPhrases(supabase) : Promise.resolve(null),
    ]);
    return { urls: planUrls({ ...module, situationCodes }) };
  } catch (err) {
    console.warn('План офлайну не склався:', err instanceof Error ? err.message : err);
    return { urls: [] };
  }
}

/** Наступні уроки модуля (за порядком юнітів і уроків) і тексти цього модуля (рівень + номер модуля). */
async function moduleLessonsAndTexts(
  supabase: Supabase,
  lessonId: string,
  includeCurrent: boolean,
): Promise<{ lessonIds: string[]; textIds: string[] }> {
  const none = { lessonIds: [], textIds: [] };
  const lesson = await supabase.from('lessons').select('unit_id').eq('id', lessonId).eq('status', 'PUBLISHED').maybeSingle();
  if (lesson.error) throw lesson.error;
  const unitId = (lesson.data as { unit_id: string | null } | null)?.unit_id;
  if (!unitId) return none;

  const unit = await supabase.from('units').select('module_id').eq('id', unitId).maybeSingle();
  if (unit.error) throw unit.error;
  const moduleId = (unit.data as { module_id: string | null } | null)?.module_id;
  if (!moduleId) return none;

  const [moduleRes, unitsRes] = await Promise.all([
    supabase.from('modules').select('level_code, order_index').eq('id', moduleId).eq('status', 'PUBLISHED').maybeSingle(),
    supabase.from('units').select('id, order_index').eq('module_id', moduleId).eq('status', 'PUBLISHED'),
  ]);
  if (moduleRes.error) throw moduleRes.error;
  if (unitsRes.error) throw unitsRes.error;
  const mod = moduleRes.data as { level_code: string; order_index: number } | null;
  const units = (unitsRes.data ?? []) as { id: string; order_index: number | null }[];
  if (!mod || units.length === 0) return none;

  const unitOrder = new Map(units.map((u) => [u.id, u.order_index ?? 0]));
  const [lessonsRes, textsRes] = await Promise.all([
    supabase.from('lessons').select('id, unit_id, order_index').in('unit_id', [...unitOrder.keys()]).eq('status', 'PUBLISHED'),
    supabase
      .from('reading_texts')
      .select('id')
      .eq('status', 'PUBLISHED')
      .eq('cefr', mod.level_code)
      .eq('module_order', mod.order_index)
      .order('order_index', { ascending: true })
      .limit(MODULE_TEXTS),
  ]);
  if (lessonsRes.error) throw lessonsRes.error;
  const lessons: OrderedLesson[] = ((lessonsRes.data ?? []) as { id: string; unit_id: string; order_index: number | null }[]).map((l) => ({
    id: l.id,
    unitOrder: unitOrder.get(l.unit_id) ?? 0,
    order: l.order_index ?? 0,
  }));
  // тексти необов'язкові: збій не скасовує уроки
  if (textsRes.error) console.warn('Тексти модуля для офлайну не завантажились:', textsRes.error.message);
  const textIds = textsRes.error ? [] : ((textsRes.data ?? []) as { id: string }[]).map((t) => t.id);
  return { lessonIds: nextLessonIds(lessons, lessonId, { includeCurrent }), textIds };
}

/** Коди ситуацій, у яких є опубліковані фрази (сторінку ситуації наперед зберігаємо лише з фразами). */
async function situationsWithPhrases(supabase: Supabase): Promise<string[]> {
  const { data, error } = await supabase.from('phrases').select('situation').eq('status', 'PUBLISHED').not('situation', 'is', null).limit(5000);
  if (error) throw error;
  const codes = new Set(((data ?? []) as { situation: string | null }[]).map((p) => p.situation).filter((c): c is string => !!c && isSituationCode(c)));
  return [...codes];
}
