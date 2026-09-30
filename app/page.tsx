'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { speakCroatian } from '@/utils/speech'; // Додано для озвучення "Слова дня"

export default function Home() {
  const router = useRouter();
  const supabase = createClient();
  
  const [topics, setTopics] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [wordOfTheDay, setWordOfTheDay] = useState<any>(null); // Стейт для Слова дня
  
  const [stats, setStats] = useState({
    learnedWords: 0,
    reviewToday: 0,
    totalWords: 0,
    streak: 1 // Закладаємо фундамент для "вогника"
  });

  // Динамічне привітання залежно від часу
  const hour = new Date().getHours();
  const greeting = hour < 12 ? 'Dobro jutro' : hour < 18 ? 'Dobar dan' : 'Dobra večer';

  const handleLogout = async () => {
    await supabase.auth.signOut();
    router.push('/login');
    router.refresh();
  };

  useEffect(() => {
    async function fetchDashboardData() {
      try {
        const { data: { user } } = await supabase.auth.getUser();
        
        // 1. Завантажуємо модулі
        const { data: topicsData } = await supabase
          .from('topics')
          .select('*')
          .order('order_index', { ascending: true });
          
        if (topicsData) setTopics(topicsData);

        // 2. Вибір Слова дня (на основі дати, щоб змінювалося раз на добу)
        const { data: vocabData } = await supabase
          .from('vocabulary')
          .select('*')
          .limit(31); // Беремо слова для розрахунку

        if (vocabData && vocabData.length > 0) {
          const dayIndex = new Date().getDate() % vocabData.length;
          setWordOfTheDay(vocabData[dayIndex]);
        }

        if (user) {
          const now = new Date().toISOString();

          // Статистика
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

          // Якщо людина вже вчила слова, даємо вогник 1, якщо ні - 0
          const currentStreak = (learnedCount && learnedCount > 0) ? 1 : 0;

          setStats({
            learnedWords: learnedCount || 0,
            reviewToday: reviewCount || 0,
            totalWords: totalCount || 0,
            streak: currentStreak
          });
        }
      } catch (error) {
        console.error('Помилка завантаження дашборду:', error);
      } finally {
        setIsLoading(false);
      }
    }
    fetchDashboardData();
  }, [supabase]);

  if (isLoading) {
    return <div className="text-center text-gray-400 mt-20 animate-pulse">Завантаження...</div>;
  }

  const progressPercent = stats.totalWords > 0 
    ? Math.round((stats.learnedWords / stats.totalWords) * 100) 
    : 0;

  return (
    <div className="max-w-md mx-auto p-4 min-h-screen bg-gray-50 pb-12">
      
      {/* Шапка з динамічним привітанням та Вогником */}
      <header className="mb-6 mt-4 flex justify-between items-center">
        <div>
          <h1 className="text-3xl font-bold text-blue-600">{greeting}!</h1>
          <p className="text-gray-500 mt-1">Твій шлях до впевненої комунікації</p>
        </div>
        <div className="flex flex-col items-end gap-2">
          {/* Daily Streak (Вогник) */}
          <div className={`flex items-center gap-1.5 px-3 py-1.5 rounded-2xl text-sm font-bold shadow-sm ${stats.streak > 0 ? 'bg-orange-100 text-orange-600' : 'bg-gray-100 text-gray-400'}`}>
            🔥 <span className={stats.streak > 0 ? 'text-orange-700' : 'text-gray-500'}>{stats.streak}</span>
          </div>
          <button 
            onClick={handleLogout}
            className="text-xs text-gray-400 hover:text-red-500 transition-colors"
            title="Вийти з акаунту"
          >
            🚪 Вийти
          </button>
        </div>
      </header>

      {/* Віджет прогресу */}
      <div className="bg-white rounded-3xl p-6 shadow-sm border border-gray-100 mb-6">
        <div className="flex justify-between items-end mb-4">
          <div>
            <p className="text-sm font-semibold text-gray-500 uppercase tracking-wider mb-1">Твій словник</p>
            <p className="text-3xl font-bold text-gray-800">{stats.learnedWords} <span className="text-lg text-gray-400 font-medium">/ {stats.totalWords}</span></p>
          </div>
          <div className="text-right">
            <div className="inline-flex items-center justify-center w-12 h-12 rounded-full bg-blue-50 text-blue-600 font-bold text-lg">
              {progressPercent}%
            </div>
          </div>
        </div>

        {/* Прогрес-бар */}
        <div className="w-full bg-gray-100 rounded-full h-2.5 mb-6">
          <div 
            className="bg-blue-600 h-2.5 rounded-full transition-all duration-1000" 
            style={{ width: `${progressPercent}%` }}
          ></div>
        </div>

        {/* Завдання на сьогодні */}
        <Link href="/trainer" className="block">
          <div className="bg-orange-50 hover:bg-orange-100 transition-colors rounded-2xl p-4 flex justify-between items-center border border-orange-100 cursor-pointer active:scale-95">
            <div>
              <p className="text-sm font-semibold text-orange-800">Повторення на сьогодні</p>
              <p className="text-xs text-orange-600 mt-0.5">
                {stats.reviewToday > 0 ? 'Час освіжити пам\'ять!' : 'Тренувати нові слова'}
              </p>
            </div>
            <div className="text-2xl font-black text-orange-500 bg-white w-10 h-10 rounded-full flex items-center justify-center shadow-sm">
              {stats.reviewToday > 0 ? stats.reviewToday : '➔'}
            </div>
          </div>
        </Link>
      </div>

      {/* НОВЕ: Слово дня */}
      {wordOfTheDay && (
        <div className="bg-gradient-to-br from-blue-500 to-blue-600 rounded-3xl p-5 shadow-sm mb-6 text-white relative overflow-hidden">
          <div className="absolute -right-2 -top-2 opacity-10 text-7xl">💡</div>
          <p className="text-sm text-blue-200 font-bold mb-1 uppercase tracking-wider">Слово дня</p>
          <div className="flex justify-between items-end relative z-10">
            <div>
              <p className="text-2xl font-bold mb-1">{wordOfTheDay.hr_text}</p>
              <p className="text-blue-100 text-sm">{wordOfTheDay.ua_translation}</p>
            </div>
            <button 
              onClick={(e) => {
                e.preventDefault();
                speakCroatian(wordOfTheDay.hr_text);
              }}
              className="bg-white/20 hover:bg-white/30 p-3 rounded-full backdrop-blur-sm transition active:scale-95"
            >
              🔊
            </button>
          </div>
        </div>
      )}

      {/* Швидка навігація (Quick Actions) */}
      <div className="grid grid-cols-2 gap-3 mb-8">
        <Link href="/trainer" className="bg-white border border-gray-100 hover:border-blue-300 hover:bg-blue-50 p-5 rounded-3xl shadow-sm transition-all active:scale-95 flex flex-col justify-between min-h-[110px]">
          <span className="text-3xl mb-2">🏋️</span>
          <span className="font-bold text-gray-800 text-sm">Тренажер слів</span>
        </Link>
        
        <Link href="/lessons" className="bg-white border border-gray-100 hover:border-blue-300 hover:bg-blue-50 p-5 rounded-3xl shadow-sm transition-all active:scale-95 flex flex-col justify-between min-h-[110px]">
          <span className="text-3xl mb-2">📚</span>
          <span className="font-bold text-gray-800 text-sm">Всі уроки</span>
        </Link>
      </div>

      {/* Популярні теми */}
      <div className="flex justify-between items-end mb-4">
        <h2 className="text-xl font-bold text-gray-800">Популярні теми</h2>
        <Link href="/lessons" className="text-sm text-blue-500 hover:underline mb-0.5 font-medium">
          Дивитись всі
        </Link>
      </div>
      
      <div className="space-y-4">
        {topics.slice(0, 3).map((topic) => (
          <Link href="/lessons" key={topic.id} className="block">
            <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-100 hover:shadow-md transition-all cursor-pointer active:scale-95">
              <div className="flex justify-between items-center mb-2">
                <h3 className="text-lg font-bold text-gray-800">{topic.title_hr}</h3>
                <span className="bg-blue-100 text-blue-800 text-xs font-semibold px-2.5 py-0.5 rounded-full">
                  Модуль {topic.order_index}
                </span>
              </div>
              <h4 className="text-sm text-blue-500 font-medium mb-1">{topic.title_ua}</h4>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}