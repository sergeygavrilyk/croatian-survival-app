'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@supabase/supabase-js';
import Link from 'next/link';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

export default function Home() {
  const [topics, setTopics] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function fetchTopics() {
      const { data, error } = await supabase
        .from('topics')
        .select('*')
        .order('order_index', { ascending: true });
        
      if (data) setTopics(data);
      else if (error) console.error('Помилка завантаження:', error);
      
      setIsLoading(false);
    }
    fetchTopics();
  }, []);

  return (
    <div className="max-w-md mx-auto p-4 min-h-screen bg-gray-50">
      <header className="mb-8 mt-4 text-center">
        <h1 className="text-3xl font-bold text-blue-600">Croatian Survival</h1>
        <p className="text-gray-500 mt-2">Базовий курс для впевненої комунікації</p>
      </header>

      {isLoading ? (
        <div className="text-center text-gray-400 mt-10 animate-pulse">Завантаження модулів...</div>
      ) : (
        <div className="space-y-4 pb-8">
          {topics.map((topic) => (
            <Link href={`/lesson/${topic.id}`} key={topic.id} className="block">
              <div className="bg-white p-5 rounded-2xl shadow-sm border border-gray-100 hover:shadow-md transition-all cursor-pointer active:scale-95">
                <div className="flex justify-between items-center mb-2">
                  <h2 className="text-xl font-bold text-gray-800">{topic.title_hr}</h2>
                  <span className="bg-blue-100 text-blue-800 text-xs font-semibold px-2.5 py-0.5 rounded-full">
                    Модуль {topic.order_index}
                  </span>
                </div>
                <h3 className="text-md text-blue-500 font-medium mb-2">{topic.title_ua}</h3>
                <p className="text-sm text-gray-500">{topic.description}</p>
              </div>
            </Link>
          ))}
        </div>
      )}
    </div>
  );
}