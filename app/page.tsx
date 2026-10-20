'use client';

import React, { useEffect, useState } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import { speakCroatian } from '@/utils/speech';
import { quickTranslateToCroatian, type TranslationSource } from '@/app/actions/translate';
import { LEARNING_EVENTS, activityWeek, learningStreak } from '@/lib/progress';

export default function DashboardPage() {
  const router = useRouter();
  const supabase = createClient();

  const [isLoading, setIsLoading] = useState(true);
  const [userName, setUserName] = useState('');
  const [activityData, setActivityData] = useState<{ day: string; level: number }[]>([]);
  
  // Стейт для фічі "Що сказати?"
  const [phrase, setPhrase] = useState('');
  const [quickTranslation, setQuickTranslation] = useState('');
  const [translateError, setTranslateError] = useState('');
  const [translationSource, setTranslationSource] = useState<TranslationSource>('ai');
  const [canRetry, setCanRetry] = useState(false);
  const [isTranslating, setIsTranslating] = useState(false);

  const [stats, setStats] = useState({
    learnedWords: 0,
    reviewToday: 0,
    totalWords: 5000,
    streak: 0,
    activeChats: 0
  });

  const hour = new Date().getHours();
  const greeting = hour < 12 ? 'Dobro jutro' : hour < 18 ? 'Dobar dan' : 'Dobra večer';

  const getActivityColor = (level: number) => {
    if (level === 0) return 'bg-slate-100 border border-slate-200';
    if (level === 1) return 'bg-teal-100 border border-teal-200';
    if (level === 2) return 'bg-teal-300 border border-teal-400';
    if (level === 3) return 'bg-teal-500 shadow-md shadow-teal-500/30';
    return 'bg-teal-600 shadow-lg shadow-teal-600/40';
  };

  useEffect(() => {
    async function fetchDashboardData() {
      try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
          router.push('/login');
          return;
        }

        setUserName(user.user_metadata?.full_name || user.email?.split('@')[0] || 'Студент');

        // Новий користувач → онбординг (міграція M7). Якщо поля ще немає в БД — не заважаємо.
        const { data: profile, error: profileError } = await supabase
          .from('profiles')
          .select('onboarding_completed')
          .eq('id', user.id)
          .maybeSingle();
        if (!profileError && profile && profile.onboarding_completed === false) {
          router.replace('/onboarding');
          return;
        }
        const now = new Date().toISOString();

        // 1. Повторень сьогодні (з user_progress)
        const { count: reviewCount } = await supabase
          .from('user_progress')
          .select('*', { count: 'exact', head: true })
          .eq('user_id', user.id)
          .lte('next_review_date', now);

        // 2. Всього вивчено слів
        const { count: learnedCount } = await supabase
          .from('user_progress')
          .select('*', { count: 'exact', head: true })
          .eq('user_id', user.id)
          .gt('interval_days', 0);

        // 3. Збережені AI сесії
        const { count: chatsCount } = await supabase
          .from('ai_conversations')
          .select('*', { count: 'exact', head: true })
          .eq('user_id', user.id);

        // 4–5. Активність за 7 днів і 🔥 серія — усе навчання (уроки, вправи, повторення, читання, говоріння),
        // дні — у часовому поясі користувача (lib/progress.ts; баг 2026-10-20: рахувались лише картки й у UTC)
        const timeZone = Intl.DateTimeFormat().resolvedOptions().timeZone;
        const since = new Date(Date.now() - 120 * 24 * 60 * 60 * 1000).toISOString();
        const [eventsRes, reviewsRes] = await Promise.all([
          supabase
            .from('analytics_events')
            .select('occurred_at')
            .eq('user_id', user.id)
            .in('event_name', [...LEARNING_EVENTS])
            .gte('occurred_at', since)
            .order('occurred_at', { ascending: false })
            .limit(5000),
          supabase
            .from('srs_reviews')
            .select('created_at')
            .eq('user_id', user.id)
            .gte('created_at', since)
            .order('created_at', { ascending: false })
            .limit(5000),
        ]);
        const timestamps = [
          ...((eventsRes.data ?? []) as Array<{ occurred_at: string }>).map((r) => r.occurred_at),
          ...((reviewsRes.data ?? []) as Array<{ created_at: string }>).map((r) => r.created_at),
        ];
        const nowDate = new Date();
        setActivityData(activityWeek(timestamps, nowDate, timeZone).map((d) => ({ day: d.label, level: d.level })));
        const calculatedStreak = learningStreak(timestamps, nowDate, timeZone);

        setStats({
          learnedWords: learnedCount || 0,
          reviewToday: reviewCount || 0,
          totalWords: 5000, 
          streak: calculatedStreak,
          activeChats: chatsCount || 0
        });

      } catch (error) {
        console.error('Помилка завантаження дашборду:', error);
      } finally {
        setIsLoading(false);
      }
    }
    fetchDashboardData();
  }, [supabase, router]);

  const runTranslate = async () => {
    if (!phrase.trim() || isTranslating) return;

    setIsTranslating(true);
    setTranslateError('');
    setCanRetry(false);
    try {
      const result = await quickTranslateToCroatian(phrase);
      if (result.ok) {
        setQuickTranslation(result.text);
        setTranslationSource(result.source);
      } else {
        setQuickTranslation('');
        setTranslateError(result.error);
        setCanRetry(result.retryable);
      }
    } catch (error) {
      console.error(error);
      setQuickTranslation('');
      setTranslateError('Немає зв’язку з сервером. Перевірте інтернет і спробуйте ще раз.');
      setCanRetry(true);
    } finally {
      setIsTranslating(false);
    }
  };

  const handleQuickTranslate = (e: React.FormEvent) => {
    e.preventDefault();
    void runTranslate();
  };

  const sourceLabel: Record<TranslationSource, string> = {
    verified: '✓ Перевірена фраза застосунку',
    cache: 'Ваш попередній переклад · AI',
    ai: 'Переклад AI',
  };
    
  const progressPercent = stats.totalWords > 0 
    ? Math.min(Math.round((stats.learnedWords / stats.totalWords) * 100), 100) 
    : 0;

  const circleRadius = 24;
  const circleCircumference = 2 * Math.PI * circleRadius;
  const strokeDashoffset = circleCircumference - (progressPercent / 100) * circleCircumference;

  const containerVariants = {
    hidden: { opacity: 0 },
    show: { opacity: 1, transition: { staggerChildren: 0.1 } }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0, transition: { type: "spring" as const, stiffness: 300, damping: 24 } }
  };

  if (isLoading) {
    return (
      <div className="min-h-screen bg-slate-50 flex justify-center items-center">
        <div className="w-10 h-10 border-4 border-indigo-200 border-t-indigo-600 rounded-full animate-spin"></div>
      </div>
    );
  }

  return (
    <div className="min-h-screen bg-slate-50 pb-32 overflow-x-hidden">
      
      {/* Шапка */}
      <header className="pt-12 px-6 mb-8 flex justify-between items-start">
        <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} transition={{ duration: 0.5 }}>
          <p className="font-bold text-slate-400 uppercase tracking-widest text-xs mb-1">Bok, {userName}!</p>
          <h1 className="font-heading text-4xl font-extrabold text-slate-800 tracking-tight">
            {greeting}! <span className="inline-block animate-wave origin-bottom-right">👋</span>
          </h1>
        </motion.div>

        <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: 0.2 }} className="flex gap-3 items-center">
          <div className="flex items-center gap-1.5 bg-orange-50 border border-orange-100 px-3 py-2 rounded-2xl shadow-sm">
             <span className={`text-lg transition-transform ${stats.streak > 0 ? 'scale-110 drop-shadow-md' : 'opacity-50 grayscale'}`}>🔥</span>
             <span className={`font-heading font-black ${stats.streak > 0 ? 'text-orange-500' : 'text-slate-400'}`}>{stats.streak}</span>
          </div>
          <button 
            onClick={() => router.push('/profile')}
            className="w-11 h-11 bg-white rounded-full flex items-center justify-center text-slate-400 hover:text-indigo-600 shadow-md shadow-slate-200/50 border border-slate-100 transition-all active:scale-90"
          >
            <svg width="22" height="22" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
          </button>
        </motion.div>
      </header>

      <motion.main variants={containerVariants} initial="hidden" animate="show" className="px-6 flex flex-col gap-8">
        
        {/* СЕКЦІЯ 1: DANAS (Сьогоднішній план) */}
        <motion.section variants={itemVariants}>
          <div className="flex justify-between items-end mb-4">
            <h2 className="font-heading text-xl font-bold text-slate-800">Danas <span className="text-slate-400 text-sm font-normal">(Сьогодні)</span></h2>
          </div>
          
          <div className="grid grid-cols-2 gap-4">
            <div 
              onClick={() => router.push('/lessons')}
              className="bg-white p-5 rounded-[2rem] shadow-lg shadow-slate-200/50 border border-slate-100 cursor-pointer active:scale-95 transition-all group"
            >
              <div className="w-12 h-12 bg-indigo-50 text-indigo-600 rounded-2xl flex items-center justify-center text-2xl mb-4 group-hover:scale-110 transition-transform">
                📚
              </div>
              <h3 className="font-heading font-bold text-slate-800 text-lg leading-tight mb-1">Навчання</h3>
              <p className="text-xs font-semibold text-slate-400 uppercase">Продовжити курс</p>
            </div>

            <div 
              onClick={() => router.push('/trainer')}
              className={`p-5 rounded-[2rem] shadow-xl cursor-pointer active:scale-95 transition-all group ${
                stats.reviewToday > 0 
                  ? 'bg-gradient-to-br from-indigo-500 to-indigo-700 shadow-indigo-500/30 text-white border border-indigo-400' 
                  : 'bg-white shadow-slate-200/50 border border-slate-100 text-slate-800'
              }`}
            >
              <div className={`w-12 h-12 rounded-2xl flex items-center justify-center text-2xl mb-4 group-hover:scale-110 transition-transform ${stats.reviewToday > 0 ? 'bg-white/20' : 'bg-teal-50 text-teal-600'}`}>
                {stats.reviewToday > 0 ? '🧠' : '✨'}
              </div>
              <h3 className="font-heading font-bold text-lg leading-tight mb-1">Повторити<br/>слова</h3>
              <p className={`text-xs font-semibold uppercase ${stats.reviewToday > 0 ? 'text-indigo-200' : 'text-slate-400'}`}>
                {stats.reviewToday > 0 ? `${stats.reviewToday} карток` : 'Все виконано'}
              </p>
            </div>
          </div>
        </motion.section>

        {/* СЕКЦІЯ 2: ЩО СКАЗАТИ? (Переклад) */}
        <motion.section variants={itemVariants} className="bg-white/80 backdrop-blur-xl border border-slate-200/60 p-6 rounded-[2rem] shadow-xl shadow-slate-200/50 relative overflow-hidden">
          <div className="absolute -top-10 -right-10 w-32 h-32 bg-blue-100 rounded-full blur-3xl opacity-50"></div>
          
          <div className="relative z-10">
            <h2 className="font-heading text-lg font-bold text-slate-800 mb-1 flex items-center gap-2">
              💬 Мені потрібно сказати...
            </h2>
            <p className="text-slate-500 text-sm font-medium mb-4">Пишіть українською, ми перекладемо.</p>
            
            <form onSubmit={handleQuickTranslate} className="relative">
              <input 
                type="text" 
                value={phrase}
                onChange={(e) => setPhrase(e.target.value)}
                placeholder="Напр: Як записатися до лікаря?" 
                className="w-full bg-slate-50 text-slate-800 font-medium rounded-2xl py-4 px-4 pr-14 focus:outline-none focus:ring-2 focus:ring-blue-500/50 border border-slate-200 transition-all shadow-inner"
              />
              <button 
                type="submit"
                disabled={!phrase.trim() || isTranslating}
                className="absolute right-2 top-2 bottom-2 aspect-square bg-blue-600 text-white rounded-xl flex items-center justify-center shadow-md disabled:opacity-50 disabled:bg-slate-300 transition-colors active:scale-95"
              >
                {isTranslating ? (
                  <div className="w-5 h-5 border-2 border-white border-t-transparent rounded-full animate-spin"></div>
                ) : (
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M5 12h14M12 5l7 7-7 7"/></svg>
                )}
              </button>
            </form>

            {translateError && (
              <div role="alert" className="mt-4 flex items-start gap-3 bg-danger-soft border border-danger-line text-danger-ink p-4 rounded-card">
                <div className="flex-1">
                  <p className="text-body font-medium">{translateError}</p>
                  {canRetry && (
                    <button
                      type="button"
                      onClick={() => void runTranslate()}
                      disabled={isTranslating}
                      className="mt-3 min-h-11 px-4 bg-white text-danger-ink font-semibold rounded-control border border-danger-line disabled:opacity-50"
                    >
                      {isTranslating ? 'Перекладаємо…' : 'Спробувати ще раз'}
                    </button>
                  )}
                </div>
                <button
                  type="button"
                  onClick={() => setTranslateError('')}
                  aria-label="Закрити повідомлення"
                  className="w-11 h-11 -m-2 shrink-0 flex items-center justify-center rounded-control"
                >
                  ✕
                </button>
              </div>
            )}

            <AnimatePresence>
              {quickTranslation && (
                <motion.div 
                  initial={{ opacity: 0, height: 0, marginTop: 0 }} 
                  animate={{ opacity: 1, height: 'auto', marginTop: 16 }} 
                  exit={{ opacity: 0, height: 0, marginTop: 0 }}
                  className="bg-blue-50 border border-blue-100 p-4 rounded-2xl"
                >
                  <p className={`text-caption font-semibold uppercase tracking-wide mb-1 ${translationSource === 'verified' ? 'text-success-ink' : 'text-ai-ink'}`}>
                    {sourceLabel[translationSource]}
                  </p>
                  <p lang="hr" className="font-heading font-bold text-blue-900 text-lg mb-3">{quickTranslation}</p>
                  <div className="flex gap-2">
                    <button 
                      onClick={() => speakCroatian(quickTranslation)}
                      className="flex-1 bg-white text-blue-600 font-bold py-2.5 rounded-xl shadow-sm border border-blue-100 active:scale-95 transition-transform text-sm flex justify-center items-center gap-2"
                    >
                      🔊 Слухати
                    </button>
                    <button 
                      onClick={() => { setPhrase(''); setQuickTranslation(''); setTranslateError(''); setCanRetry(false); }}
                      aria-label="Очистити переклад"
                      className="w-10 h-10 bg-white text-slate-400 rounded-xl shadow-sm border border-blue-100 flex items-center justify-center active:scale-95 transition-transform"
                    >
                      ✕
                    </button>
                  </div>
                </motion.div>
              )}
            </AnimatePresence>
          </div>
        </motion.section>

        {/* СЕКЦІЯ 3: ПРОГРЕС ТА АКТИВНІСТЬ */}
        <motion.section variants={itemVariants} className="grid grid-cols-[1fr_auto] gap-4">
          
          <div className="bg-white p-5 rounded-[2rem] shadow-lg shadow-slate-200/50 border border-slate-100 flex flex-col justify-between">
            <div className="flex justify-between items-center mb-3">
              <h3 className="text-xs font-bold text-slate-400 uppercase tracking-widest">Останні 7 днів</h3>
              <div className="text-[10px] font-bold text-purple-600 bg-purple-50 px-2 py-0.5 rounded-lg">🤖 {stats.activeChats} чатів</div>
            </div>
            
            <div className="flex justify-between items-center gap-1">
              {activityData.map((item, idx) => (
                <div key={idx} className="flex flex-col items-center gap-1.5">
                  <div className={`w-7 h-7 rounded-lg transition-all duration-500 ${getActivityColor(item.level)}`}></div>
                  <span className={`text-[9px] font-bold ${idx === 6 ? 'text-indigo-600' : 'text-slate-400'}`}>{item.day}</span>
                </div>
              ))}
            </div>
          </div>

          <div className="bg-white p-5 rounded-[2rem] shadow-lg shadow-slate-200/50 border border-slate-100 flex flex-col items-center justify-center w-28">
            <h3 className="text-xs font-bold text-slate-400 uppercase tracking-widest mb-2">Мета 5K</h3>
            <div className="relative w-14 h-14 flex items-center justify-center">
              <svg className="w-full h-full transform -rotate-90" viewBox="0 0 100 100">
                <circle cx="50" cy="50" r={circleRadius} stroke="#f1f5f9" strokeWidth="12" fill="none" />
                <circle 
                  cx="50" cy="50" r={circleRadius} stroke="url(#indigoGradient)" strokeWidth="12" fill="none" 
                  strokeDasharray={circleCircumference} strokeDashoffset={strokeDashoffset} strokeLinecap="round" 
                  className="transition-all duration-1000 ease-out"
                />
                <defs>
                  <linearGradient id="indigoGradient" x1="0%" y1="0%" x2="100%" y2="100%"><stop offset="0%" stopColor="#818cf8" /><stop offset="100%" stopColor="#4f46e5" /></linearGradient>
                </defs>
              </svg>
              <div className="absolute font-bold text-xs text-indigo-600">{progressPercent}%</div>
            </div>
          </div>

        </motion.section>

      </motion.main>

    </div>
  );
}