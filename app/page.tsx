'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { speakCroatian } from '@/utils/speech';

export default function Home() {
  const router = useRouter();
  const supabase = createClient();
  
  const [topics, setTopics] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [wordOfTheDay, setWordOfTheDay] = useState<any>(null);
  
  const [stats, setStats] = useState({
    learnedWords: 0,
    reviewToday: 0,
    totalWords: 0,
    streak: 1
  });

  const hour = new Date().getHours();
  const greeting = hour < 12 ? 'Dobro jutro' : hour < 18 ? 'Dobar dan' : 'Dobra večer';

  useEffect(() => {
    async function fetchDashboardData() {
      try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) {
          router.push('/login');
          return;
        }
        
        const { data: topicsData } = await supabase
          .from('topics')
          .select('*')
          .order('order_index', { ascending: true });
          
        if (topicsData) setTopics(topicsData);

        const { data: vocabData } = await supabase
          .from('vocabulary')
          .select('*')
          .limit(31);

        if (vocabData && vocabData.length > 0) {
          const dayIndex = new Date().getDate() % vocabData.length;
          setWordOfTheDay(vocabData[dayIndex]);
        }

        const now = new Date().toISOString();

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

        const currentStreak = (learnedCount && learnedCount > 0) ? 1 : 0;

        setStats({
          learnedWords: learnedCount || 0,
          reviewToday: reviewCount || 0,
          totalWords: totalCount || 0,
          streak: currentStreak
        });
      } catch (error) {
        console.error('Помилка завантаження дашборду:', error);
      } finally {
        setIsLoading(false);
      }
    }
    fetchDashboardData();
  }, [supabase, router]);

  if (isLoading) {
    return (
      <div className="min-h-screen bg-[#F4F7F9] flex justify-center items-center">
        <div className="w-10 h-10 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin"></div>
      </div>
    );
  }

  const progressPercent = stats.totalWords > 0 
    ? Math.round((stats.learnedWords / stats.totalWords) * 100) 
    : 0;

  return (
    <div className="max-w-md mx-auto p-5 min-h-screen bg-[#F4F7F9] pb-24 font-sans text-gray-800">
      
      {/* 1. ШАПКА ПРОФІЛЮ (Виправлено верстку) */}
      <header className="mb-8 mt-4 flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-extrabold text-gray-900 tracking-tight">{greeting}!</h1>
          <p className="text-sm font-medium text-gray-500 mt-1">Продовжуємо навчання 🚀</p>
        </div>
        
        <div className="flex items-center gap-3">
          {/* Вогник */}
          <div className="flex items-center gap-1.5 px-3 py-1.5 rounded-2xl font-bold bg-orange-100 text-orange-600 border border-orange-200/50 shadow-sm">
            <span className="text-lg">🔥</span>
            <span>{stats.streak}</span>
          </div>
          {/* Аватар / Налаштування */}
          <Link href="/profile" className="w-11 h-11 bg-white border border-gray-200 rounded-full flex items-center justify-center text-xl shadow-sm hover:bg-gray-50 active:scale-95 transition-all">
            👤
          </Link>
        </div>
      </header>

      {/* 2. ГОЛОВНА КАРТКА ПРОГРЕСУ ТА СТАРТУ */}
      <div className="bg-white rounded-[2rem] p-6 shadow-sm border border-gray-100 mb-6">
        <div className="flex justify-between items-start mb-5">
          <div>
            <p className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-1.5">Твій словник</p>
            <div className="flex items-baseline gap-1">
              <span className="text-4xl font-black text-gray-900">{stats.learnedWords}</span>
              <span className="text-sm font-bold text-gray-400">/ {stats.totalWords}</span>
            </div>
          </div>
          <div className="w-14 h-14 rounded-full border-[4px] border-blue-50 flex items-center justify-center relative bg-white">
            <span className="font-bold text-blue-600 text-sm">{progressPercent}%</span>
          </div>
        </div>

        {/* Прогрес-бар */}
        <div className="w-full bg-gray-100 rounded-full h-3 mb-6 overflow-hidden">
          <div 
            className="bg-blue-500 h-full rounded-full transition-all duration-1000 ease-out" 
            style={{ width: `${progressPercent}%` }}
          ></div>
        </div>

        {/* ВЕЛИКА КНОПКА CTA */}
        <Link href="/trainer" className="block w-full">
          <div className={`w-full py-4 rounded-2xl flex justify-center items-center font-bold text-lg shadow-md transition-all active:scale-95 ${
            stats.reviewToday > 0 
              ? 'bg-orange-500 text-white shadow-orange-200 hover:bg-orange-600' 
              : 'bg-blue-600 text-white shadow-blue-200 hover:bg-blue-700'
          }`}>
            {stats.reviewToday > 0 ? `Повторити ${stats.reviewToday} слів` : 'Тренувати нові слова'}
          </div>
        </Link>
      </div>

      {/* 3. СЛОВО ДНЯ (Полірований дизайн) */}
      {wordOfTheDay && (
        <div className="bg-gradient-to-br from-blue-600 to-indigo-600 rounded-[2rem] p-6 shadow-md shadow-blue-200 mb-6 text-white relative overflow-hidden group">
          {/* Декоративний елемент */}
          <div className="absolute -right-6 -top-6 w-32 h-32 bg-white opacity-10 rounded-full blur-2xl group-hover:scale-110 transition-transform duration-700"></div>
          
          <div className="flex justify-between items-start relative z-10 mb-2">
            <p className="text-xs font-bold text-blue-200 uppercase tracking-widest flex items-center gap-1.5">
              <span>💡</span> Слово дня
            </p>
            <button 
              onClick={(e) => {
                e.preventDefault();
                speakCroatian(wordOfTheDay.hr_text);
              }}
              className="bg-white/20 hover:bg-white/30 w-10 h-10 flex items-center justify-center rounded-full backdrop-blur-sm transition-all active:scale-90 shadow-sm"
            >
              🔊
            </button>
          </div>
          
          <div className="relative z-10 mt-2">
            <p className="text-3xl font-extrabold mb-1 tracking-tight leading-tight">{wordOfTheDay.hr_text}</p>
            <p className="text-blue-100 text-base font-medium opacity-90">{wordOfTheDay.ua_translation}</p>
          </div>
        </div>
      )}

      {/* 4. ДОДАТКОВА НАВІГАЦІЯ (Мінімалістична) */}
      <div className="grid grid-cols-2 gap-4 mb-10">
        <Link href="/trainer" className="bg-white border border-gray-100 p-5 rounded-[1.5rem] shadow-sm hover:shadow-md transition-all active:scale-95 flex flex-col items-center justify-center text-center group">
          <span className="text-3xl mb-3 group-hover:scale-110 transition-transform">🏋️</span>
          <span className="font-bold text-gray-700 text-sm">Тренажер</span>
        </Link>
        
        <Link href="/lessons" className="bg-white border border-gray-100 p-5 rounded-[1.5rem] shadow-sm hover:shadow-md transition-all active:scale-95 flex flex-col items-center justify-center text-center group">
          <span className="text-3xl mb-3 group-hover:scale-110 transition-transform">📚</span>
          <span className="font-bold text-gray-700 text-sm">Всі уроки</span>
        </Link>
      </div>

      {/* 5. ПОПУЛЯРНІ ТЕМИ (Список) */}
      <div className="flex justify-between items-end mb-5 px-1">
        <h2 className="text-xl font-extrabold text-gray-900 tracking-tight">Популярні теми</h2>
        <Link href="/lessons" className="text-sm text-blue-600 font-bold hover:underline mb-0.5">
          Дивитись всі
        </Link>
      </div>
      
      <div className="space-y-3">
        {topics.slice(0, 3).map((topic) => (
          <Link href={`/lesson/${topic.id}`} key={topic.id} className="block">
            <div className="bg-white p-5 rounded-[1.5rem] shadow-sm border border-gray-100 hover:border-blue-200 transition-all active:scale-[0.98] flex justify-between items-center">
              <div>
                <h3 className="text-base font-bold text-gray-900 mb-1">{topic.title_hr}</h3>
                <h4 className="text-sm font-medium text-gray-500">{topic.title_ua}</h4>
              </div>
              <div className="bg-gray-50 border border-gray-200 text-gray-500 text-xs font-bold px-3 py-1.5 rounded-xl whitespace-nowrap">
                Модуль {topic.order_index}
              </div>
            </div>
          </Link>
        ))}
      </div>
      
    </div>
  );
}