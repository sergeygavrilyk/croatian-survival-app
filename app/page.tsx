'use client';

import React, { useEffect, useState } from 'react';
import { motion } from 'framer-motion';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';

export default function DashboardPage() {
  const router = useRouter();
  const supabase = createClient();

  const [isLoading, setIsLoading] = useState(true);
  
  // Додаємо стейт для реального графіка активності
  const [activityData, setActivityData] = useState<{ day: string; level: number }[]>([]);
  
  const [stats, setStats] = useState({
    learnedWords: 0,
    reviewToday: 0,
    totalWords: 0,
    streak: 0
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

        const now = new Date().toISOString();

        // 1. БАЗОВА СТАТИСТИКА
        const { count: reviewCount } = await supabase
          .from('user_progress')
          .select('*', { count: 'exact', head: true })
          .eq('user_id', user.id)
          .lte('next_review_date', now);

        const { count: learnedCount } = await supabase
          .from('user_progress')
          .select('*', { count: 'exact', head: true })
          .eq('user_id', user.id)
          .gt('interval_days', 0);

        const { count: totalCount } = await supabase
          .from('vocabulary')
          .select('*', { count: 'exact', head: true });

        // 2. РЕАЛЬНИЙ ГРАФІК АКТИВНОСТІ (Останні 7 днів)
        const today = new Date();
        const sevenDaysAgo = new Date();
        sevenDaysAgo.setDate(today.getDate() - 6);
        sevenDaysAgo.setHours(0, 0, 0, 0);

        // Отримуємо всі дати повторення слів за останні 7 днів
        const { data: recentProgress } = await supabase
          .from('user_progress')
          .select('last_reviewed_at')
          .eq('user_id', user.id)
          .gte('last_reviewed_at', sevenDaysAgo.toISOString())
          .not('last_reviewed_at', 'is', null);

        // Рахуємо кількість повторених слів по датах
        const countsByDate: Record<string, number> = {};
        if (recentProgress) {
          recentProgress.forEach((row) => {
            const dateStr = new Date(row.last_reviewed_at).toISOString().split('T')[0];
            countsByDate[dateStr] = (countsByDate[dateStr] || 0) + 1;
          });
        }

        const newActivityData = [];
        const daysOfWeek = ['Нд', 'Пн', 'Вв', 'Ср', 'Чт', 'Пт', 'Сб'];

        for (let i = 6; i >= 0; i--) {
          const d = new Date();
          d.setDate(today.getDate() - i);
          const dateStr = d.toISOString().split('T')[0];
          const count = countsByDate[dateStr] || 0;

          // Розподіл інтенсивності (Level 0-4)
          let level = 0;
          if (count > 0 && count <= 5) level = 1;
          else if (count > 5 && count <= 15) level = 2;
          else if (count > 15 && count <= 30) level = 3;
          else if (count > 30) level = 4;

          newActivityData.push({
            day: daysOfWeek[d.getDay()],
            level: level,
          });
        }
        setActivityData(newActivityData);

        // 3. РЕАЛЬНИЙ STREAK (Дні підряд)
        const { data: allDates } = await supabase
          .from('user_progress')
          .select('last_reviewed_at')
          .eq('user_id', user.id)
          .not('last_reviewed_at', 'is', null);

        let calculatedStreak = 0;
        if (allDates && allDates.length > 0) {
          const uniqueDates = new Set(
            allDates.map(r => new Date(r.last_reviewed_at).toISOString().split('T')[0])
          );

          let checkD = new Date();
          let todayStr = checkD.toISOString().split('T')[0];
          
          let tempD = new Date();
          tempD.setDate(tempD.getDate() - 1);
          let yesterdayStr = tempD.toISOString().split('T')[0];

          // Якщо вчився сьогодні або вчора — стрік живий
          if (uniqueDates.has(todayStr) || uniqueDates.has(yesterdayStr)) {
             if (!uniqueDates.has(todayStr)) {
                checkD.setDate(checkD.getDate() - 1); // Починаємо рахувати з вчора
             }
             while(true) {
                let s = checkD.toISOString().split('T')[0];
                if (uniqueDates.has(s)) {
                   calculatedStreak++;
                   checkD.setDate(checkD.getDate() - 1); // Крок назад
                } else {
                   break; // Стрік перервався
                }
             }
          }
        }

        setStats({
          learnedWords: learnedCount || 0,
          reviewToday: reviewCount || 0,
          totalWords: totalCount || 1200,
          streak: calculatedStreak
        });

      } catch (error) {
        console.error('Помилка завантаження дашборду:', error);
      } finally {
        setIsLoading(false);
      }
    }
    fetchDashboardData();
  }, [supabase, router]);

  const progressPercent = stats.totalWords > 0 
    ? Math.min(Math.round((stats.learnedWords / stats.totalWords) * 100), 100) 
    : 0;

  const circleRadius = 40;
  const circleCircumference = 2 * Math.PI * circleRadius;
  const strokeDashoffset = circleCircumference - (progressPercent / 100) * circleCircumference;

  const containerVariants = {
    hidden: { opacity: 0 },
    show: { opacity: 1, transition: { staggerChildren: 0.1 } }
  };

  const itemVariants = {
    hidden: { opacity: 0, y: 20 },
    show: { opacity: 1, y: 0, transition: { type: "spring", stiffness: 300, damping: 24 } }
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
      <header className="pt-12 px-6 mb-6 flex justify-between items-start">
        <motion.div initial={{ opacity: 0, x: -20 }} animate={{ opacity: 1, x: 0 }} transition={{ duration: 0.5 }}>
          <h1 className="font-heading text-4xl font-extrabold text-slate-800 tracking-tight mb-2">
            {greeting}, Сергію! <span className="inline-block animate-wave origin-bottom-right">👋</span>
          </h1>
          <p className="text-slate-500 font-medium text-lg">Твій фокус на сьогодні:</p>
        </motion.div>

        {/* Кнопка Профілю */}
        <motion.div initial={{ opacity: 0, scale: 0.8 }} animate={{ opacity: 1, scale: 1 }} transition={{ delay: 0.2 }}>
          <button 
            onClick={() => router.push('/profile')}
            className="w-12 h-12 bg-white rounded-full flex items-center justify-center text-slate-400 hover:text-indigo-600 shadow-md shadow-slate-200/50 border border-slate-100 transition-all active:scale-90"
          >
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M19 21v-2a4 4 0 0 0-4-4H9a4 4 0 0 0-4 4v2"/><circle cx="12" cy="7" r="4"/></svg>
          </button>
        </motion.div>
      </header>

      <motion.main 
        variants={containerVariants}
        initial="hidden"
        animate="show"
        className="px-6 flex flex-col gap-6"
      >
        {/* Віджет 1: Круговий прогрес-бар */}
        <motion.div variants={itemVariants} className="bg-white/60 backdrop-blur-xl border border-white/80 p-6 rounded-[2rem] shadow-xl shadow-slate-200/50 flex items-center justify-between">
          <div>
            <span className="bg-indigo-100 text-indigo-600 px-3 py-1 rounded-full text-xs font-bold tracking-widest uppercase mb-3 inline-block">
              Глобальна ціль
            </span>
            <h2 className="font-heading text-2xl font-black text-slate-800 mb-1">Рівень B1</h2>
            <p className="text-slate-500 text-sm font-medium">Засвоєно {stats.learnedWords} / {stats.totalWords} слів</p>
          </div>
          
          <div className="relative w-24 h-24 flex items-center justify-center">
            <svg className="w-full h-full transform -rotate-90" viewBox="0 0 100 100">
              <circle cx="50" cy="50" r={circleRadius} stroke="#f1f5f9" strokeWidth="12" fill="none" />
              <circle 
                cx="50" cy="50" r={circleRadius} 
                stroke="url(#indigoGradient)" 
                strokeWidth="12" fill="none" 
                strokeDasharray={circleCircumference} 
                strokeDashoffset={strokeDashoffset} 
                strokeLinecap="round" 
                className="transition-all duration-1000 ease-out"
              />
              <defs>
                <linearGradient id="indigoGradient" x1="0%" y1="0%" x2="100%" y2="100%">
                  <stop offset="0%" stopColor="#818cf8" />
                  <stop offset="100%" stopColor="#4f46e5" />
                </linearGradient>
              </defs>
            </svg>
            <div className="absolute font-heading font-bold text-xl text-indigo-600">
              {progressPercent}%
            </div>
          </div>
        </motion.div>

        {/* Віджет 2: Тренажер (Action Card) */}
        <motion.div 
          variants={itemVariants}
          onClick={() => router.push('/trainer')}
          className={`relative overflow-hidden p-8 rounded-[2.5rem] shadow-2xl text-white cursor-pointer group active:scale-95 transition-transform ${
            stats.reviewToday > 0 
              ? 'bg-gradient-to-br from-indigo-500 to-indigo-700 shadow-indigo-500/30' 
              : 'bg-gradient-to-br from-teal-400 to-teal-600 shadow-teal-500/30'
          }`}
        >
          <div className="absolute -top-10 -right-10 w-40 h-40 bg-white/10 rounded-full blur-2xl"></div>
          <div className="absolute -bottom-10 -left-10 w-32 h-32 bg-white/10 rounded-full blur-xl"></div>
          
          <div className="relative z-10 flex items-center justify-between">
            <div className="max-w-[70%]">
              <h2 className="font-heading text-3xl font-black mb-2 leading-tight">
                {stats.reviewToday > 0 ? `${stats.reviewToday} слів` : 'Все виконано'}
              </h2>
              <p className="text-white/80 font-medium">
                {stats.reviewToday > 0 ? 'чекають на повторення' : 'Можна тренувати нові слова'}
              </p>
            </div>
            
            <div className="w-16 h-16 bg-white/20 backdrop-blur-md rounded-full flex items-center justify-center border border-white/30 group-hover:bg-white group-hover:text-indigo-600 transition-colors shadow-lg">
              <svg width="28" height="28" viewBox="0 0 24 24" fill="currentColor"><path d="M5 3l14 9-14 9V3z"/></svg>
            </div>
          </div>
        </motion.div>

        {/* Віджет 3: Графік активності (РЕАЛЬНІ ДАНІ) */}
        <motion.div variants={itemVariants} className="bg-white/60 backdrop-blur-xl border border-white/80 p-6 rounded-[2rem] shadow-xl shadow-slate-200/50">
          <div className="flex justify-between items-end mb-5">
            <div>
              <h3 className="font-heading text-lg font-bold text-slate-800">Активність</h3>
              <p className="text-slate-400 text-xs font-semibold uppercase tracking-wider mt-1">Останні 7 днів</p>
            </div>
            <div className="text-right flex items-center gap-2">
              <span className={`text-2xl transition-transform ${stats.streak > 0 ? 'scale-110 drop-shadow-md' : 'opacity-50 grayscale'}`}>🔥</span>
              <div>
                <span className={`font-heading text-2xl font-black leading-none block ${stats.streak > 0 ? 'text-orange-500' : 'text-slate-400'}`}>
                  {stats.streak}
                </span>
                <p className="text-slate-400 text-[10px] font-semibold uppercase tracking-wider">Дні підряд</p>
              </div>
            </div>
          </div>
          
          <div className="flex justify-between items-center gap-1 sm:gap-2">
            {activityData.map((item, idx) => (
              <div key={idx} className="flex flex-col items-center gap-2">
                <div className={`w-10 h-10 rounded-2xl flex items-center justify-center transition-all duration-500 ${getActivityColor(item.level)}`}>
                  {item.level > 0 && <span className="text-white text-xs font-bold">{item.level}</span>}
                </div>
                <span className={`text-[10px] font-bold ${idx === 6 ? 'text-indigo-600' : 'text-slate-400'}`}>
                  {item.day}
                </span>
              </div>
            ))}
          </div>
        </motion.div>
      </motion.main>

      {/* Нижня навігація */}
      <div className="fixed bottom-6 left-0 right-0 px-6 z-50">
        <div className="bg-white/80 backdrop-blur-2xl border border-white/50 p-2 rounded-[2rem] shadow-2xl shadow-slate-300/50 flex justify-between items-center">
          <button className="flex-1 flex flex-col items-center gap-1 py-3 text-indigo-600">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            <span className="text-[10px] font-bold">Головна</span>
          </button>
          
          <button onClick={() => router.push('/lessons')} className="flex-1 flex flex-col items-center gap-1 py-3 text-slate-400 hover:text-slate-600 transition-colors">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"/></svg>
            <span className="text-[10px] font-bold">Уроки</span>
          </button>
          
          <button onClick={() => router.push('/dictionary')} className="flex-1 flex flex-col items-center gap-1 py-3 text-slate-400 hover:text-slate-600 transition-colors">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20"/><path d="M2 12h20"/></svg>
            <span className="text-[10px] font-bold">Словник</span>
          </button>
        </div>
      </div>
    </div>
  );
}