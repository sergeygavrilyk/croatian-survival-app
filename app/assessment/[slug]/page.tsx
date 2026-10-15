import { notFound, redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import AssessmentPlayer, { type PlayerItem } from '@/components/AssessmentPlayer';
import { isArea, isLevelAssessmentSlug, kindTitle } from '@/lib/assessment';

export const metadata = { title: 'Перевірка знань · Croatian Survival App' };
export const dynamic = 'force-dynamic';

type Params = { params: Promise<{ slug: string }> };

/**
 * Тест модуля / середини / кінця рівня (§60). Сторінка бере опубліковані завдання
 * БЕЗ правильних відповідей (перевіряє сервер у submitAssessment), AssessmentPlayer — проводить тест.
 */
export default async function AssessmentPage({ params }: Params) {
  const { slug } = await params;
  if (!isLevelAssessmentSlug(slug)) notFound();

  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: assessment } = await supabase
    .from('assessments')
    .select('id, slug, kind, cefr, title_ua, description_ua, estimated_minutes, pass_ratio, area_min_ratio, module_id')
    .eq('slug', slug)
    .eq('status', 'PUBLISHED')
    .maybeSingle();
  if (!assessment) notFound();

  const [itemsRes, moduleRes] = await Promise.all([
    supabase
      .from('assessment_items')
      .select('id, order_index, area, skill, item_type, prompt_ua, prompt_hr, options, audio_hr, passage_hr')
      .eq('assessment_id', assessment.id)
      .eq('status', 'PUBLISHED')
      .order('order_index', { ascending: true }),
    assessment.module_id
      ? supabase.from('modules').select('title_ua, order_index').eq('id', assessment.module_id).maybeSingle()
      : Promise.resolve({ data: null }),
  ]);

  const items: PlayerItem[] = (itemsRes.data ?? [])
    .filter((i) => isArea(i.area))
    .map((i) => ({
      id: i.id as string,
      area: i.area as PlayerItem['area'],
      skill: i.skill as string,
      item_type: i.item_type as string,
      prompt_ua: i.prompt_ua as string,
      prompt_hr: (i.prompt_hr as string | null) ?? null,
      options: Array.isArray(i.options) ? (i.options as unknown[]).map(String) : [],
      audio_hr: (i.audio_hr as string | null) ?? null,
      passage_hr: (i.passage_hr as string | null) ?? null,
    }));

  const moduleData = moduleRes.data as { title_ua: string; order_index: number } | null;
  const title = kindTitle(assessment.kind as string, assessment.cefr as string, moduleData?.order_index);

  return (
    <AssessmentPlayer
      slug={slug}
      kind={assessment.kind as string}
      cefr={assessment.cefr as string}
      title={title}
      subtitle={moduleData?.title_ua ?? null}
      description={(assessment.description_ua as string | null) ?? null}
      minutes={(assessment.estimated_minutes as number | null) ?? null}
      passRatio={Number(assessment.pass_ratio)}
      areaMinRatio={Number(assessment.area_min_ratio)}
      items={items}
      loadError={Boolean(itemsRes.error) || items.length === 0}
    />
  );
}
