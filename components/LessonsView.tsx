'use client';

import { useState, useTransition } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { BookOpen, Check, ChevronDown, ChevronRight, ClipboardCheck, Dumbbell, Play } from 'lucide-react';
import { ASSESSED_LEVELS, assessmentSlug } from '@/lib/assessment';
import { lessonsHref } from '@/lib/curriculum';
import { LEVEL_CODES, levelStyle, moduleIcon } from '@/lib/levels';
import { moduleCardTitles } from '@/lib/reading';
import { cn } from '@/lib/ui';
import Button from '@/components/ui/Button';
import EmptyState from '@/components/ui/EmptyState';
import ErrorState from '@/components/ui/ErrorState';
import Hr from '@/components/ui/Hr';
import ProgressBar from '@/components/ui/ProgressBar';

export interface CurriculumModule {
  id: string;
  level_code: string;
  title_ua: string;
  title_hr: string | null;
  description: string | null;
  order_index: number;
}

export interface CurriculumUnit {
  id: string;
  module_id: string;
  title_ua: string;
  title_hr: string | null;
  order_index: number;
}

export interface CurriculumLesson {
  id: string;
  unit_id: string;
  title_ua: string;
  title_hr: string | null;
}

/**
 * «Уроки» (UI-003, 2026-10-20 — на дизайн-системі): рівні → модулі → юніти → уроки.
 * Кожен рівень — свій колір, кожен модуль — тематична іконка (lib/levels.ts, рішення власника 2026-10-20).
 * З 2026-10-21 дані бере сервер (app/lessons/page.tsx, §75): рівень — в адресі (?level=A1),
 * тут — лише розгортання модулів. Офлайн (§76) — сторінку, як і решту, кешує PWA.
 */
export default function LessonsView({
  level: activeLevel,
  modules,
  unitsByModule,
  lessonsByUnit,
  completedIds: completed,
  failed,
}: {
  level: string;
  modules: CurriculumModule[];
  unitsByModule: Record<string, CurriculumUnit[]>;
  lessonsByUnit: Record<string, CurriculumLesson[]>;
  completedIds: string[];
  failed: boolean;
}) {
  const router = useRouter();
  const [, startRetry] = useTransition();
  // Перший модуль рівня розгорнуто, як і раніше
  const [expandedModuleId, setExpandedModuleId] = useState<string | null>(modules[0]?.id ?? null);
  const completedIds = new Set(completed);

  const assessed = (ASSESSED_LEVELS as readonly string[]).includes(activeLevel);
  const lv = levelStyle(activeLevel);

  return (
    <div className="min-h-screen pb-28">
      <header className="mx-auto flex max-w-2xl flex-col gap-4 px-5 pt-[calc(2.5rem+env(safe-area-inset-top))] pb-4">
        <div className="flex items-start justify-between gap-3">
          <div className="min-w-0">
            <h1 className="font-heading text-h1">Уроки</h1>
            <p className={cn('text-label', lv.ink)}>
              {activeLevel} · {lv.name}
            </p>
            <p className="text-label font-normal text-ink-muted">{lv.goal}</p>
          </div>
          <Button href="/trainer" variant="secondary" size="sm">
            <Dumbbell className="size-4" aria-hidden="true" />
            Тренажер
          </Button>
        </div>

        <nav aria-label="Рівень" className="flex rounded-control bg-surface-muted p-1">
          {LEVEL_CODES.map((level) => {
            const active = activeLevel === level;
            return (
              <Link
                key={level}
                href={lessonsHref(level)}
                aria-current={active ? 'page' : undefined}
                className={cn(
                  'flex min-h-11 flex-1 items-center justify-center rounded-control px-2 text-label transition-colors duration-150',
                  active ? cn(levelStyle(level).solid, 'shadow-sm') : 'text-ink-muted hover:text-ink',
                )}
              >
                {level}
              </Link>
            );
          })}
        </nav>
      </header>

      <main className="mx-auto flex max-w-2xl flex-col gap-4 px-5">
        {failed ? (
          <ErrorState
            text="Не вдалося завантажити уроки. Перевірте інтернет і спробуйте ще раз."
            onRetry={() => startRetry(() => router.refresh())}
          />
        ) : modules.length === 0 ? (
          <EmptyState
            icon={<BookOpen className="size-6" aria-hidden="true" />}
            title={`Уроки рівня ${activeLevel} ще готуються`}
            text="Поки що вчіть уроки A0 і A1 — вони вже відкриті."
            action={
              <Button variant="secondary" href={lessonsHref('A0')}>
                До уроків A0
              </Button>
            }
          />
        ) : (
          <>
            {assessed && (
              <Link
                href={`/lessons/tests?level=${activeLevel}`}
                className="flex min-h-16 items-center gap-3 rounded-card border border-line bg-surface p-4 shadow-sm transition-colors duration-150 hover:bg-surface-muted"
              >
                <span className={cn('flex size-10 shrink-0 items-center justify-center rounded-full', lv.soft, lv.ink)}>
                  <ClipboardCheck className="size-5" aria-hidden="true" />
                </span>
                <span className="min-w-0 flex-1">
                  <span className="block font-heading text-h3 text-ink">Перевірки рівня {activeLevel}</span>
                  <span className="block text-label font-normal text-ink-muted">Після модуля, середина й фінал: розумію, кажу, спілкуюся, переказую</span>
                </span>
                <ChevronRight className="size-5 shrink-0 text-ink-subtle" aria-hidden="true" />
              </Link>
            )}

            {modules.map((mod) => {
              const isExpanded = mod.id === expandedModuleId;
              const moduleUnits = unitsByModule[mod.id] || [];
              const moduleLessons = moduleUnits.flatMap((u) => lessonsByUnit[u.id] || []);
              const doneCount = moduleLessons.filter((l) => completedIds.has(l.id)).length;
              const complete = moduleLessons.length > 0 && doneCount === moduleLessons.length;
              const head = moduleCardTitles(mod.title_ua, mod.title_hr, mod.level_code, mod.order_index);
              const panelId = `module-${mod.id}`;

              return (
                <div
                  key={mod.id}
                  className={cn(
                    'overflow-hidden rounded-card border bg-surface shadow-sm transition-colors duration-150',
                    isExpanded ? lv.line : 'border-line',
                  )}
                >
                  <button
                    type="button"
                    aria-expanded={isExpanded}
                    aria-controls={panelId}
                    onClick={() => setExpandedModuleId(isExpanded ? null : mod.id)}
                    className="flex w-full items-center gap-4 p-4 text-left transition-colors duration-150 hover:bg-surface-muted"
                  >
                    <span
                      className={cn('relative flex size-14 shrink-0 items-center justify-center rounded-card text-3xl leading-none', lv.soft)}
                      aria-hidden="true"
                    >
                      {moduleIcon(mod.level_code, mod.order_index, mod.title_hr ?? mod.title_ua)}
                      {complete && (
                        <span className="absolute -right-1.5 -bottom-1.5 flex size-6 items-center justify-center rounded-full border-2 border-surface bg-success text-white">
                          <Check className="size-3.5" strokeWidth={3} />
                        </span>
                      )}
                    </span>
                    <span className="min-w-0 flex-1">
                      <span className={cn('block text-caption uppercase tracking-wide', lv.ink)}>{head.kicker}</span>
                      <span className="block font-heading text-h3 break-words line-clamp-2">{head.title}</span>
                      {head.subtitle && (
                        <Hr className="block text-label font-normal text-ink-muted line-clamp-1">{head.subtitle}</Hr>
                      )}
                      {moduleLessons.length > 0 && (
                        <span className="mt-2 flex items-center gap-2">
                          <ProgressBar
                            value={doneCount}
                            max={moduleLessons.length}
                            label={`Пройдено уроків модуля ${mod.order_index}`}
                            className="h-1.5 flex-1"
                            barClassName={complete ? 'bg-success' : lv.bar}
                          />
                          <span className={cn('shrink-0 text-caption', complete ? 'text-success-ink' : 'text-ink-subtle')}>
                            {complete ? '🎉 Пройдено!' : `${doneCount} з ${moduleLessons.length}`}
                          </span>
                        </span>
                      )}
                    </span>
                    <ChevronDown
                      className={cn('size-5 shrink-0 text-ink-subtle transition-transform duration-200', isExpanded && 'rotate-180')}
                      aria-hidden="true"
                    />
                  </button>

                  {isExpanded && (
                    <div id={panelId} className="animate-fade-in-up border-t border-line p-4">
                      {mod.description && <p className="mb-4 text-body text-ink-muted">{mod.description}</p>}

                      {moduleUnits.length === 0 ? (
                        <p className="text-label font-normal text-ink-subtle">Уроків поки немає</p>
                      ) : (
                        <div className="flex flex-col gap-5">
                          {moduleUnits.map((unit) => (
                            <section key={unit.id} aria-label={unit.title_ua} className="flex flex-col gap-2">
                              {moduleUnits.length > 1 && (
                                <h3 className="text-label text-ink-muted">
                                  Юніт {unit.order_index}: {unit.title_ua}
                                </h3>
                              )}
                              {(lessonsByUnit[unit.id] || []).length === 0 ? (
                                <p className="text-label font-normal text-ink-subtle">Уроків поки немає</p>
                              ) : (
                                <ul className="flex flex-col gap-2">
                                  {(lessonsByUnit[unit.id] || []).map((lesson) => {
                                    const done = completedIds.has(lesson.id);
                                    return (
                                      <li key={lesson.id}>
                                        <Link
                                          href={`/lesson/${lesson.id}`}
                                          aria-label={done ? `${lesson.title_ua} — пройдено` : lesson.title_ua}
                                          className={cn(
                                            'flex min-h-14 items-center gap-3 rounded-control border px-4 py-3 transition-colors duration-150 active:scale-[0.98]',
                                            done
                                              ? 'border-success-line bg-success-soft hover:bg-success-soft/70'
                                              : 'border-line bg-surface hover:bg-surface-muted',
                                          )}
                                        >
                                          <span
                                            className={cn(
                                              'flex size-9 shrink-0 items-center justify-center rounded-full',
                                              done ? 'bg-success text-white' : cn(lv.soft, lv.ink),
                                            )}
                                            aria-hidden="true"
                                          >
                                            {done ? <Check className="size-5" strokeWidth={3} /> : <Play className="size-4 translate-x-px fill-current" />}
                                          </span>
                                          <span className="min-w-0 flex-1">
                                            <span className="block text-body font-semibold text-ink">{lesson.title_ua}</span>
                                            {lesson.title_hr && (
                                              <Hr className="block text-label font-normal text-ink-muted">{lesson.title_hr}</Hr>
                                            )}
                                            {done && <span className="mt-0.5 block text-caption text-success-ink">Пройдено · можна повторити</span>}
                                          </span>
                                          <ChevronRight className="size-5 shrink-0 text-ink-subtle" aria-hidden="true" />
                                        </Link>
                                      </li>
                                    );
                                  })}
                                </ul>
                              )}
                            </section>
                          ))}
                        </div>
                      )}

                      {(ASSESSED_LEVELS as readonly string[]).includes(mod.level_code) && moduleUnits.length > 0 && (
                        <Link
                          href={`/assessment/${assessmentSlug(mod.level_code, 'module', mod.order_index)}`}
                          className={cn(
                            'mt-4 flex min-h-12 items-center gap-3 rounded-control border px-4 py-3 transition-colors duration-150 hover:bg-surface',
                            lv.line,
                            lv.soft,
                            lv.ink,
                          )}
                        >
                          <ClipboardCheck className="size-5 shrink-0" aria-hidden="true" />
                          <span className="min-w-0 flex-1 text-body font-semibold">Перевірка модуля · ~5 хв</span>
                          <ChevronRight className="size-5 shrink-0" aria-hidden="true" />
                        </Link>
                      )}
                    </div>
                  )}
                </div>
              );
            })}
          </>
        )}
      </main>
    </div>
  );
}
