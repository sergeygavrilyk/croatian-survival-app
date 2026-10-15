import { redirect } from 'next/navigation';
import { createClient } from '@/utils/supabase/server';
import PageHeader from '@/components/ui/PageHeader';
import SegmentedLinks from '@/components/ui/SegmentedLinks';
import ErrorState from '@/components/ui/ErrorState';
import AssessmentListView, { type AssessmentListItem } from '@/components/AssessmentListView';
import {
  ASSESSED_LEVELS, displayOrder, kindTitle, levelStatus, pickAssessmentLevel, summarizeAttempts, type AttemptRow,
} from '@/lib/assessment';

export const metadata = { title: 'Перевірки рівня · Croatian Survival App' };
export const dynamic = 'force-dynamic';

/**
 * «Уроки» → «Перевірки» (§60): тести модулів, середини й кінця рівня, найкращий результат і чи підтверджено рівень.
 * Рівень — з адреси (?level=A1) або з профілю. Сторінка бере дані, AssessmentListView — малює.
 */
export default async function AssessmentsPage({ searchParams }: { searchParams: Promise<{ level?: string }> }) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) redirect('/login');
  const { level: requested } = await searchParams;

  const [testsRes, profileRes, attemptsRes] = await Promise.all([
    supabase
      .from('assessments')
      .select('id, slug, kind, cefr, order_index, estimated_minutes, module_id')
      .in('kind', ['module', 'mid', 'final'])
      .in('cefr', [...ASSESSED_LEVELS])
      .eq('status', 'PUBLISHED')
      .limit(200),
    supabase.from('profiles').select('current_level').eq('id', user.id).maybeSingle(),
    supabase
      .from('assessment_attempts')
      .select('assessment_id, score, passed, completed_at')
      .eq('user_id', user.id)
      .order('completed_at', { ascending: false })
      .limit(1000),
  ]);

  const all = testsRes.data ?? [];
  const available = ASSESSED_LEVELS.filter((l) => all.some((t) => t.cefr === l));
  const level = pickAssessmentLevel(requested, profileRes.data?.current_level, available);
  const tests = all
    .filter((t) => t.cefr === level)
    .sort((a, b) => displayOrder(a.kind as string, a.order_index as number) - displayOrder(b.kind as string, b.order_index as number));

  const moduleIds = tests.map((t) => t.module_id as string | null).filter((id): id is string => Boolean(id));
  const modulesRes = moduleIds.length
    ? await supabase.from('modules').select('id, order_index, title_ua').in('id', moduleIds)
    : { data: [] as Array<{ id: string; order_index: number; title_ua: string }> };
  type ModuleRow = { id: string; order_index: number; title_ua: string };
  const modules = new Map<string, ModuleRow>(((modulesRes.data ?? []) as ModuleRow[]).map((m) => [m.id, m]));

  const summaries = summarizeAttempts((attemptsRes.data ?? []) as AttemptRow[]);
  const items: AssessmentListItem[] = tests.map((t) => {
    const mod = t.module_id ? modules.get(t.module_id as string) : undefined;
    const s = summaries.get(t.id as string);
    return {
      slug: t.slug as string,
      kind: t.kind as string,
      title: kindTitle(t.kind as string, t.cefr as string, mod?.order_index),
      subtitle:
        t.kind === 'module' ? mod?.title_ua ?? null : t.kind === 'mid' ? 'Модулі 1–5' : 'Усі 10 модулів',
      minutes: (t.estimated_minutes as number | null) ?? null,
      attempts: s?.attempts ?? 0,
      bestScore: s?.bestScore ?? null,
      passed: s?.passed ?? false,
    };
  });
  const status = levelStatus(tests.map((t) => ({ id: t.id as string, kind: t.kind as string })), summaries);
  const levelTabs = available.map((l) => ({ href: `/lessons/tests?level=${l}`, label: l }));

  return (
    <div className="min-h-screen pb-28">
      <PageHeader title="Перевірки рівня" backHref="/lessons" />
      <main className="mx-auto max-w-md px-4 py-4">
        {testsRes.error ? (
          <ErrorState text="Не вдалося завантажити перевірки. Перевірте інтернет і оновіть сторінку." />
        ) : (
          <>
            {levelTabs.length > 1 && level && (
              <SegmentedLinks items={levelTabs} activeHref={`/lessons/tests?level=${level}`} label="Рівень" className="mb-4" />
            )}
            <AssessmentListView level={level} items={items} status={status} />
          </>
        )}
      </main>
    </div>
  );
}
