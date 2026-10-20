'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import Link from 'next/link';
import { motion, AnimatePresence } from 'framer-motion';
import { ChevronRight, CircleCheck, ClipboardCheck } from 'lucide-react';
import { ASSESSED_LEVELS, assessmentSlug } from '@/lib/assessment';

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

const getTopicIcon = (title: string) => {
  const t = (title || '').toLowerCase();
  if (t.includes('kafić') || t.includes('restoran') || t.includes('hrana') || t.includes('їж') || t.includes('кафе')) return '☕️';
  if (t.includes('obitelj') || t.includes('odnosi') || t.includes('родин')) return '🫂';
  if (t.includes('auto') || t.includes('promet') || t.includes('транспорт')) return '🚗';
  if (t.includes('posao') || t.includes('ured') || t.includes('робот')) return '💼';
  if (t.includes('putovanj') || t.includes('hotel') || t.includes('подорож')) return '✈️️';
  if (t.includes('bolnic') || t.includes('zdravlje') || t.includes('здоров')) return '🏥';
  if (t.includes('novac') || t.includes('kupovina') || t.includes('грош') || t.includes('покупк')) return '💳';
  if (t.includes('policija') || t.includes('sud') || t.includes('закон')) return '⚖️';
  if (t.includes('tehnologija') || t.includes('internet') || t.includes('техн')) return '💻';
  return '📚';
};

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

const levelThemes: Record<string, { bg: string; text: string; lightBg: string; activeTab: string; border: string; gradient: string }> = {
  'A0': { bg: 'bg-slate-50', text: 'text-rose-600', lightBg: 'bg-rose-50', activeTab: 'bg-rose-500 text-white shadow-rose-200', border: 'border-rose-100', gradient: 'from-rose-500 to-rose-600' },
  'A1': { bg: 'bg-slate-50', text: 'text-indigo-600', lightBg: 'bg-indigo-50', activeTab: 'bg-indigo-600 text-white shadow-indigo-200', border: 'border-indigo-100', gradient: 'from-indigo-500 to-indigo-600' },
  'A2': { bg: 'bg-slate-50', text: 'text-teal-600', lightBg: 'bg-teal-50', activeTab: 'bg-teal-500 text-white shadow-teal-200', border: 'border-teal-100', gradient: 'from-teal-400 to-teal-500' },
  'B1': { bg: 'bg-slate-50', text: 'text-orange-600', lightBg: 'bg-orange-50', activeTab: 'bg-orange-500 text-white shadow-orange-200', border: 'border-orange-100', gradient: 'from-orange-400 to-orange-500' },
  'B2': { bg: 'bg-slate-50', text: 'text-purple-600', lightBg: 'bg-purple-50', activeTab: 'bg-purple-600 text-white shadow-purple-200', border: 'border-purple-100', gradient: 'from-purple-500 to-purple-600' },
};

export default function LessonsPage() {
  const router = useRouter();
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

  if (loading && modules.length === 0) {
    return (
      <div className="min-h-screen bg-slate-50 flex justify-center items-center">
        <div className="w-10 h-10 border-4 border-indigo-200 border-t-indigo-600 rounded-full animate-spin"></div>
      </div>
    );
  }

  const theme = levelThemes[activeLevel] || levelThemes['A1'];

  return (
    <div className={`min-h-screen pb-32 font-sans transition-colors duration-500 bg-slate-50 overflow-x-hidden`}>
      <header className="sticky top-0 z-20 backdrop-blur-2xl bg-white/70 border-b border-slate-200/50 px-6 pt-10 pb-4 shadow-sm flex flex-col gap-4">
        <div className="flex justify-between items-center">
          <h1 className="font-heading text-3xl font-extrabold text-slate-800 tracking-tight">Навчання 📚</h1>
          <Link href="/trainer" className={`bg-gradient-to-r ${theme.gradient} text-white px-5 py-2.5 rounded-full text-sm font-bold shadow-lg shadow-indigo-200 hover:shadow-indigo-300 active:scale-95 transition-all flex items-center gap-2`}>
            Тренажер 
            <span className="bg-white/20 p-1 rounded-full"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="m9 18 6-6-6-6"/></svg></span>
          </Link>
        </div>

        <div className="flex gap-2 bg-slate-100/80 p-1.5 rounded-2xl border border-slate-200 overflow-x-auto no-scrollbar">
          {['A0', 'A1', 'A2', 'B1', 'B2'].map(level => {
            const isActive = activeLevel === level;
            const tabTheme = levelThemes[level] || levelThemes['A1'];
            return (
              <button
                key={level}
                onClick={() => setActiveLevel(level)}
                className={`flex-1 min-w-[70px] py-2 rounded-xl text-sm font-bold transition-all duration-300 ${
                  isActive ? tabTheme.activeTab : 'text-slate-500 hover:text-slate-800'
                }`}
              >
                {level === 'A0' ? '🚑 A0' : level}
              </button>
            );
          })}
        </div>
      </header>

      <main className="px-6 mt-6">
        {(ASSESSED_LEVELS as readonly string[]).includes(activeLevel) && modules.length > 0 && (
          <Link
            href={`/lessons/tests?level=${activeLevel}`}
            className="mb-6 flex min-h-16 items-center gap-3 rounded-card border border-primary bg-surface p-4 shadow-sm transition-colors hover:bg-primary-soft"
          >
            <span className="flex size-10 shrink-0 items-center justify-center rounded-full bg-primary-soft text-primary-ink">
              <ClipboardCheck className="size-5" aria-hidden="true" />
            </span>
            <span className="min-w-0 flex-1">
              <span className="block font-heading text-h3 text-ink">Перевірки рівня {activeLevel}</span>
              <span className="block text-label font-normal text-ink-muted">Після модуля, середина й фінал: розумію, кажу, спілкуюся, переказую</span>
            </span>
            <ChevronRight className="size-5 shrink-0 text-ink-subtle" aria-hidden="true" />
          </Link>
        )}
        {modules.length === 0 && !loading && (
          <div className="text-center py-10 text-slate-400">
            <p>Модулі для цього рівня ще не створені.</p>
            <button onClick={() => router.push('/admin')} className="mt-4 text-blue-500 underline text-sm">Перейти в Адмін-панель</button>
          </div>
        )}

        <div className="flex flex-col gap-6">
          <AnimatePresence>
            {modules.map((module, index) => {
              const isExpanded = module.id === expandedModuleId;
              const moduleUnits = units[module.id] || [];

              return (
                <motion.div 
                  layout
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.05 }}
                  key={module.id} 
                  className={`relative transition-all duration-300 rounded-[2rem] bg-white border ${
                    isExpanded ? `${theme.border} shadow-xl shadow-slate-200/50` : 'border-slate-100 shadow-sm'
                  }`}
                >
                  <div className={`absolute left-0 top-6 bottom-6 w-1 rounded-r-full ${isExpanded ? theme.bg : 'bg-transparent'}`}></div>

                  <div 
                    onClick={() => setExpandedModuleId(isExpanded ? null : module.id)}
                    className="p-6 flex items-center gap-4 cursor-pointer select-none"
                  >
                    <div className={`shrink-0 w-16 h-16 rounded-2xl flex items-center justify-center text-3xl shadow-sm ${theme.lightBg}`}>
                      {getTopicIcon(module.title_ua)}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className={`text-[10px] font-black uppercase tracking-widest mb-1 ${theme.text}`}>
                        Модуль {module.order_index}
                      </div>
                      <h2 className="font-heading text-lg font-extrabold text-slate-800 leading-tight mb-1 truncate">{module.title_ua}</h2>
                      {module.title_hr && <h3 lang="hr" className="text-sm font-medium text-slate-400 truncate">{module.title_hr}</h3>}
                      {(() => {
                        const moduleLessons = (units[module.id] || []).flatMap(u => lessons[u.id] || []);
                        if (moduleLessons.length === 0) return null;
                        const doneCount = moduleLessons.filter(l => completedIds.has(l.id)).length;
                        return (
                          <p className={`text-xs font-semibold mt-1 ${doneCount === moduleLessons.length ? 'text-success-ink' : 'text-slate-500'}`}>
                            Пройдено {doneCount} з {moduleLessons.length}
                          </p>
                        );
                      })()}
                    </div>
                    <div className={`shrink-0 w-8 h-8 rounded-full flex items-center justify-center transition-transform duration-300 ${isExpanded ? 'rotate-180 bg-slate-100' : 'bg-slate-50'}`}>
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-slate-400" strokeLinecap="round" strokeLinejoin="round"><path d="m6 9 6 6 6-6"/></svg>
                    </div>
                  </div>

                  <AnimatePresence>
                    {isExpanded && (
                      <motion.div 
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="overflow-hidden"
                      >
                        <div className="px-6 pb-6 border-t border-slate-50 pt-4">
                          {module.description && (
                            <p className="text-slate-500 text-sm font-medium leading-relaxed mb-6 bg-slate-50 p-4 rounded-2xl border border-slate-100">
                              {module.description}
                            </p>
                          )}
                          
                          {moduleUnits.length === 0 ? (
                            <div className="text-center py-6 text-slate-400 bg-slate-50 rounded-2xl border border-dashed border-slate-200">
                              <p className="text-sm font-medium">Юніти ще не додані...</p>
                            </div>
                          ) : (
                            <div className="flex flex-col gap-6">
                              {moduleUnits.map(unit => (
                                <div key={unit.id} className="bg-slate-50/50 p-4 rounded-2xl border border-slate-100">
                                  <h4 className="font-heading text-sm font-bold text-slate-600 mb-3 uppercase tracking-wider">
                                    Юніт {unit.order_index}: {unit.title_ua}
                                  </h4>
                                  
                                  <div className="flex flex-col gap-2">
                                    {(lessons[unit.id] || []).length === 0 ? (
                                       <div className="text-xs text-slate-400 p-2 italic">Немає уроків</div>
                                    ) : (
                                      (lessons[unit.id] || []).map(lesson => {
                                        const done = completedIds.has(lesson.id);
                                        return (
                                        <button 
                                          key={lesson.id}
                                          aria-label={done ? `${lesson.title_ua} — пройдено` : lesson.title_ua}
                                          onClick={(e) => {
                                            e.stopPropagation();
                                            router.push(`/lesson/${lesson.id}`);
                                          }} 
                                          className={`w-full flex items-center justify-between gap-3 p-4 rounded-xl shadow-sm transition-transform active:scale-[0.98] border ${done ? 'bg-success-soft border-success-line' : 'bg-white border-slate-200 hover:border-indigo-300'}`}
                                        >
                                          <div className="text-left">
                                            <div className="text-sm font-bold text-slate-800">{lesson.title_ua}</div>
                                            {lesson.title_hr && <div lang="hr" className="text-xs text-slate-500 mt-0.5">{lesson.title_hr}</div>}
                                            {done && <div className="text-xs font-semibold text-success-ink mt-1">Пройдено · можна повторити</div>}
                                          </div>
                                          {done ? (
                                            <CircleCheck aria-hidden="true" className="shrink-0 w-8 h-8 text-success-ink" />
                                          ) : (
                                            <div aria-hidden="true" className={`shrink-0 w-8 h-8 rounded-full flex items-center justify-center ${theme.lightBg} ${theme.text}`}>
                                              ➔
                                            </div>
                                          )}
                                        </button>
                                        );
                                      })
                                    )}
                                  </div>
                                </div>
                              ))}
                            </div>
                          )}
                          {(ASSESSED_LEVELS as readonly string[]).includes(module.level_code) && moduleUnits.length > 0 && (
                            <Link
                              href={`/assessment/${assessmentSlug(module.level_code, 'module', module.order_index)}`}
                              onClick={(e) => e.stopPropagation()}
                              className="mt-4 flex min-h-12 items-center gap-3 rounded-control border border-primary bg-primary-soft px-4 py-3 text-primary-ink transition-colors hover:bg-surface"
                            >
                              <ClipboardCheck className="size-5 shrink-0" aria-hidden="true" />
                              <span className="min-w-0 flex-1 text-body font-semibold">Перевірка модуля · ~5 хв</span>
                              <ChevronRight className="size-5 shrink-0" aria-hidden="true" />
                            </Link>
                          )}
                        </div>
                      </motion.div>
                    )}
                  </AnimatePresence>
                </motion.div>
              );
            })}
          </AnimatePresence>
        </div>
      </main>

    </div>
  );
}