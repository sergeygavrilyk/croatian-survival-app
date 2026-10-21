import { createClient } from '@/utils/supabase/server';
import LessonsView, { type CurriculumLesson, type CurriculumModule, type CurriculumUnit } from '@/components/LessonsView';
import { groupByParent, pickLessonsLevel } from '@/lib/curriculum';

export const metadata = { title: 'Уроки · Croatian Survival App' };
export const dynamic = 'force-dynamic';

/**
 * «Уроки» (§75, з 2026-10-21 — Server Component): рівень з адреси (?level=A1, за замовчуванням A0),
 * модулі → юніти → уроки рівня й пройдені уроки — одним заходом на сервері; LessonsView — малює.
 * Онлайн програма завжди свіжа, тож ручна версія кешу (CURRICULUM_CACHE_VERSION) більше не потрібна.
 */
export default async function LessonsPage({ searchParams }: { searchParams: Promise<{ level?: string }> }) {
  const { level: requested } = await searchParams;
  const level = pickLessonsLevel(requested);

  let modules: CurriculumModule[] = [];
  let unitsByModule: Record<string, CurriculumUnit[]> = {};
  let lessonsByUnit: Record<string, CurriculumLesson[]> = {};
  let completedIds: string[] = [];
  let failed = false;

  try {
    const supabase = await createClient();
    const [{ data: { user } }, modulesRes] = await Promise.all([
      supabase.auth.getUser(),
      supabase
        .from('modules')
        .select('id, level_code, title_ua, title_hr, description, order_index')
        .eq('level_code', level)
        .eq('status', 'PUBLISHED') // адмін бачить і чернетки (RLS), але в застосунку — лише опубліковане
        .order('order_index', { ascending: true }),
    ]);
    if (modulesRes.error) throw modulesRes.error;
    modules = (modulesRes.data ?? []) as CurriculumModule[];
    const moduleIds = modules.map((m) => m.id);

    // Пройдені уроки — завжди свіжі (прогрес змінюється після кожного уроку); збій прогресу не ховає уроки
    const [unitsRes, progressRes] = await Promise.all([
      moduleIds.length
        ? supabase
            .from('units')
            .select('id, module_id, title_ua, title_hr, order_index')
            .in('module_id', moduleIds)
            .eq('status', 'PUBLISHED')
            .order('order_index', { ascending: true })
        : Promise.resolve({ data: [], error: null }),
      user
        ? supabase.from('lesson_progress').select('lesson_id').eq('user_id', user.id).eq('status', 'completed')
        : Promise.resolve({ data: [], error: null }),
    ]);
    if (unitsRes.error) throw unitsRes.error;
    if (progressRes.error) console.error('Помилка завантаження прогресу уроків:', progressRes.error.message);
    const units = (unitsRes.data ?? []) as CurriculumUnit[];
    const unitIds = units.map((u) => u.id);

    const lessonsRes = unitIds.length
      ? await supabase
          .from('lessons')
          .select('id, unit_id, title_ua, title_hr')
          .in('unit_id', unitIds)
          .eq('status', 'PUBLISHED')
          .order('order_index', { ascending: true })
          .order('created_at', { ascending: true })
      : { data: [], error: null };
    if (lessonsRes.error) throw lessonsRes.error;

    unitsByModule = groupByParent(moduleIds, units, 'module_id');
    lessonsByUnit = groupByParent(unitIds, (lessonsRes.data ?? []) as CurriculumLesson[], 'unit_id');
    completedIds = ((progressRes.error ? [] : progressRes.data) ?? []).map((row) => (row as { lesson_id: string }).lesson_id);
  } catch (err) {
    console.error('Помилка завантаження уроків:', err instanceof Error ? err.message : err);
    failed = true;
  }

  return (
    <LessonsView
      key={level}
      level={level}
      modules={modules}
      unitsByModule={unitsByModule}
      lessonsByUnit={lessonsByUnit}
      completedIds={completedIds}
      failed={failed}
    />
  );
}
