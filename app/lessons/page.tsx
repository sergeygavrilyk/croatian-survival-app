'use client';

import { useState, useEffect } from 'react';
import { createClient } from '@/utils/supabase/client';
import Link from 'next/link';
import { BookOpen, Check, ChevronDown, ChevronRight, ClipboardCheck, Dumbbell, Play } from 'lucide-react';
import { ASSESSED_LEVELS, assessmentSlug } from '@/lib/assessment';
import { LEVEL_CODES, levelStyle, moduleIcon } from '@/lib/levels';
import { moduleCardTitles } from '@/lib/reading';
import { cn } from '@/lib/ui';
import Button from '@/components/ui/Button';
import EmptyState from '@/components/ui/EmptyState';
import Hr from '@/components/ui/Hr';
import ProgressBar from '@/components/ui/ProgressBar';
import Skeleton from '@/components/ui/Skeleton';

interface Module {
  id: string;
  level_code: string;
  title_ua: string;
  title_hr: string | null;
  description: string | null;
  order_index: number;
}

interface Unit {
  id: string;
  module_id: string;
  title_ua: string;
  title_hr: string | null;
  order_index: number;
}

interface Lesson {
  id: string;
  unit_id: string;
  title_ua: string;
  title_hr: string | null;
  status: string;
}

// Кеш списку модулів / уроків у браузері: версія змінюється, коли змінюється програма,
// а TTL гарантує, що нові уроки з'являться без очищення сховища.
// v3 (2026-10-13): опубліковано A1; порожній рівень більше не кешуємо.
const CURRICULUM_CACHE_VERSION = 'v11'; // v11 (2026-10-20): модуль A0.10 «Survival» за темою (7 уроків: 5 + 2 нові), уроків A0 — 66; v10 (2026-10-19): модуль A0.9 «Grad» за темою (5 уроків, новий порядок), уроків A0 — 64; v9 (2026-10-19): модулі A0.7 «Hrana» (5 уроків) і A0.8 «Kupovina» (6 уроків), уроків A0 — 64; v8 (2026-10-19): модулі A0.5 «Obitelj» (7 уроків) і A0.6 «Moj dom» (6 уроків), уроків A0 — 63; v7 (2026-10-19): модуль A0.4 «Vrijeme» — 7 уроків, уроків A0 — 58; v6 (2026-10-19): модуль A0.3 — 10 уроків, уроків A0 — 56; v5 (2026-10-19): модуль A0.2 — 9 уроків за темою, номери уроків A0 зсунулись на +4; v4 (2026-10-15): уроки A0.1 перебудовано за темою, нова назва уроку 4
const CURRICULUM_CACHE_TTL_MS = 6 * 60 * 60 * 1000; // 6 годин

function readCache<T>(key: string): T | null {
  try {
    const raw = localStorage.getItem(`${key}_${CURRICULUM_CACHE_VERSION}`);
    if (!raw) return null;
    const parsed = JSON.parse(raw) as { cachedAt?: number; data?: T };
    if (!parsed || typeof parsed.cachedAt !== 'number' || Date.now() - parsed.cachedAt > CURRICULUM_CACHE_TTL_MS) return null;
    return parsed.data ?? null;
  } catch {
    return null; // пошкоджений кеш або недоступне сховище — просто йдемо на сервер
  }
}

function writeCache(key: string, data: unknown) {
  try {
    localStorage.setItem(`${key}_${CURRICULUM_CACHE_VERSION}`, JSON.stringify({ cachedAt: Date.now(), data }));
  } catch {
    // сховище переповнене або недоступне — сторінка працює і без кешу
  }
}

/**
 * «Уроки» (UI-003, 2026-10-20 — на дизайн-системі): рівні → модулі → юніти → уроки.
 * Кожен рівень — свій колір, кожен модуль — тематична іконка (lib/levels.ts, рішення власника 2026-10-20).
 * Дані й кеш у браузері (офлайн, §76) — як і раніше; змінено лише вигляд.
 */
export default function LessonsPage() {
  const supabase = createClient();

  const [activeLevel, setActiveLevel] = useState<string>('A0');
  const [modules, setModules] = useState<Module[]>([]);
  const [units, setUnits] = useState<Record<string, Unit[]>>({});
  const [lessons, setLessons] = useState<Record<string, Lesson[]>>({});
  
  const [expandedModuleId, setExpandedModuleId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  // Пройдені уроки — завжди свіжі з сервера (не кешуємо: прогрес змінюється після кожного уроку)
  const [completedIds, setCompletedIds] = useState<Set<string>>(new Set());

  useEffect(() => {
    let cancelled = false;
    async function fetchCompleted() {
      const { data: { user } } = await supabase.auth.getUser();
      if (!user) return;
      const { data, error } = await supabase
        .from('lesson_progress')
        .select('lesson_id')
        .eq('user_id', user.id)
        .eq('status', 'completed');
      if (error) {
        console.error('Помилка завантаження прогресу уроків:', error);
        return;
      }
      if (!cancelled) setCompletedIds(new Set((data ?? []).map(row => row.lesson_id as string)));
    }
    fetchCompleted();
    return () => {
      cancelled = true;
    };
  }, [supabase]);

  // 1. Завантаження модулів з урахуванням localStorage кешу
  useEffect(() => {
    async function fetchModules() {
      setLoading(true);
      const cacheKey = `cs_modules_${activeLevel}`;
      
      try {
        // Перевіряємо локальний кеш клієнта
        const parsedModules = readCache<Module[]>(cacheKey);
        if (parsedModules) {
          setModules(parsedModules);
          if (parsedModules.length > 0) {
            setExpandedModuleId(parsedModules[0].id);
          } else {
            setExpandedModuleId(null);
          }
          setLoading(false);
          return;
        }

        // Якщо в кеші немає — робимо оптимізований запит до Supabase
        const { data, error } = await supabase
          .from('modules')
          .select('id, level_code, title_ua, title_hr, description, order_index')
          .eq('level_code', activeLevel)
          .eq('status', 'PUBLISHED') // адмін бачить і чернетки (RLS), але в застосунку — лише опубліковане
          .order('order_index', { ascending: true });

        if (error) throw error;
        const fetchedModules = data || [];
        
        // Зберігаємо у клієнтський кеш. Порожній рівень не кешуємо: щойно там з'являться
        // модулі, користувач має їх побачити одразу, а не через 6 годин.
        if (fetchedModules.length > 0) writeCache(cacheKey, fetchedModules);
        
        setModules(fetchedModules);
        if (fetchedModules.length > 0) {
          setExpandedModuleId(fetchedModules[0].id);
        } else {
          setExpandedModuleId(null);
        }
      } catch (err) {
        console.error('Помилка завантаження модулів:', err);
      } finally {
        setLoading(false);
      }
    }
    fetchModules();
  }, [activeLevel, supabase]);

  // 2. Завантаження юнітів та уроків з урахуванням localStorage кешу
  useEffect(() => {
    async function fetchUnitsAndLessons() {
      if (!expandedModuleId) return;
      
      // Якщо юніти для цього модуля вже завантажені в стейт, не робимо зайвих дій
      if (units[expandedModuleId]) return;

      const cacheUnitsKey = `cs_units_${expandedModuleId}`;
      const cacheLessonsKey = `cs_lessons_${expandedModuleId}`;

      try {
        const parsedUnits = readCache<Unit[]>(cacheUnitsKey);
        const parsedLessons = readCache<Record<string, Lesson[]>>(cacheLessonsKey);

        if (parsedUnits && parsedLessons) {

          setUnits(prev => ({ ...prev, [expandedModuleId]: parsedUnits }));
          setLessons(prev => ({ ...prev, ...parsedLessons }));
          return;
        }

        // Запит юнітів
        const { data: unitsData } = await supabase
          .from('units')
          .select('id, module_id, title_ua, title_hr, order_index')
          .eq('module_id', expandedModuleId)
          .eq('status', 'PUBLISHED')
          .order('order_index', { ascending: true });

        if (unitsData && unitsData.length > 0) {
          setUnits(prev => ({ ...prev, [expandedModuleId]: unitsData }));
          writeCache(cacheUnitsKey, unitsData);

          const unitIds = unitsData.map(u => u.id);
          // Запит уроків
          const { data: lessonsData } = await supabase
            .from('lessons')
            .select('id, unit_id, title_ua, title_hr, status')
            .in('unit_id', unitIds)
            .eq('status', 'PUBLISHED')
            .order('order_index', { ascending: true })
            .order('created_at', { ascending: true });

          if (lessonsData) {
            const groupedLessons: Record<string, Lesson[]> = {};
            unitIds.forEach(id => groupedLessons[id] = []);
            lessonsData.forEach(lesson => {
              if (groupedLessons[lesson.unit_id]) {
                groupedLessons[lesson.unit_id].push(lesson);
              }
            });
            setLessons(prev => ({ ...prev, ...groupedLessons }));
            writeCache(cacheLessonsKey, groupedLessons);
          }
        } else {
          setUnits(prev => ({ ...prev, [expandedModuleId]: [] }));
          writeCache(cacheUnitsKey, []);
          writeCache(cacheLessonsKey, {});
        }
      } catch (err) {
        console.error('Помилка завантаження юнітів та уроків:', err);
      }
    }
    fetchUnitsAndLessons();
  }, [expandedModuleId, supabase, units]);

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

        <div role="group" aria-label="Рівень" className="flex rounded-control bg-surface-muted p-1">
          {LEVEL_CODES.map((level) => {
            const active = activeLevel === level;
            return (
              <button
                key={level}
                type="button"
                aria-pressed={active}
                onClick={() => setActiveLevel(level)}
                className={cn(
                  'flex min-h-11 flex-1 items-center justify-center rounded-control px-2 text-label transition-colors duration-150',
                  active ? cn(levelStyle(level).solid, 'shadow-sm') : 'text-ink-muted hover:text-ink',
                )}
              >
                {level}
              </button>
            );
          })}
        </div>
      </header>

      <main className="mx-auto flex max-w-2xl flex-col gap-4 px-5">
        {loading && modules.length === 0 ? (
          <div className="flex flex-col gap-4" aria-busy="true" aria-label="Завантаження уроків">
            <Skeleton className="h-20" />
            <Skeleton className="h-24" />
            <Skeleton className="h-24" />
            <Skeleton className="h-24" />
          </div>
        ) : modules.length === 0 ? (
          <EmptyState
            icon={<BookOpen className="size-6" aria-hidden="true" />}
            title={`Уроки рівня ${activeLevel} ще готуються`}
            text="Поки що вчіть уроки A0 і A1 — вони вже відкриті."
            action={
              <Button variant="secondary" onClick={() => setActiveLevel('A0')}>
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
              const moduleUnits = units[mod.id] || [];
              const moduleLessons = moduleUnits.flatMap((u) => lessons[u.id] || []);
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
                        <div className="flex flex-col gap-2" aria-busy="true" aria-label="Завантаження уроків модуля">
                          <Skeleton className="h-14" />
                          <Skeleton className="h-14" />
                        </div>
                      ) : (
                        <div className="flex flex-col gap-5">
                          {moduleUnits.map((unit) => (
                            <section key={unit.id} aria-label={unit.title_ua} className="flex flex-col gap-2">
                              {moduleUnits.length > 1 && (
                                <h3 className="text-label text-ink-muted">
                                  Юніт {unit.order_index}: {unit.title_ua}
                                </h3>
                              )}
                              {(lessons[unit.id] || []).length === 0 ? (
                                <p className="text-label font-normal text-ink-subtle">Уроків поки немає</p>
                              ) : (
                                <ul className="flex flex-col gap-2">
                                  {(lessons[unit.id] || []).map((lesson) => {
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
