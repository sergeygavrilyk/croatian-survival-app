'use client';

import React, { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import { motion } from 'framer-motion';
import { speakCroatian } from '@/utils/speech';

export default function DictionaryPage() {
  const router = useRouter();
  const supabase = createClient();
  const [words, setWords] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    async function fetchWords() {
      try {
        // Отримуємо очищені унікальні слова з бази (ліміт для швидкодії)
        const { data, error } = await supabase
          .from('vocabulary')
          .select('*')
          .neq('item_type', 'dialogue_line')
          .order('frequency_rank', { ascending: true })
          .limit(300);

        if (data && !error) {
          setWords(data);
        }
      } catch (err) {
        console.error('Помилка завантаження словника:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchWords();
  }, [supabase]);

  // Фільтрація слів за пошуком (хорватською або українською)
  const filteredWords = words.filter(word => {
    if (!searchQuery) return true;
    const query = searchQuery.toLowerCase();
    return (
      (word.hr_text && word.hr_text.toLowerCase().includes(query)) || 
      (word.ua_translation && word.ua_translation.toLowerCase().includes(query))
    );
  });

  return (
    <div className="min-h-screen bg-slate-50 pb-32 font-sans overflow-x-hidden">
      
      {/* Шапка з пошуком (Glassmorphism) */}
      <header className="sticky top-0 z-20 backdrop-blur-2xl bg-white/70 border-b border-slate-200/50 px-6 pt-10 pb-6 shadow-sm">
        <h1 className="font-heading text-3xl font-extrabold text-slate-800 tracking-tight mb-4">
          Мій Словник 📖
        </h1>
        
        <div className="relative">
          <input 
            type="text" 
            placeholder="Пошук слова..." 
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            className="w-full bg-slate-100/80 text-slate-700 font-medium rounded-2xl py-3.5 px-4 pl-12 focus:outline-none focus:ring-2 focus:ring-indigo-500/50 border border-slate-200 transition-all shadow-inner"
          />
          <svg className="w-5 h-5 absolute left-4 top-4 text-slate-400" fill="none" stroke="currentColor" viewBox="0 0 24 24" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round">
            <circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line>
          </svg>
          
          {searchQuery && (
            <button 
              onClick={() => setSearchQuery('')}
              className="absolute right-4 top-4 text-slate-400 hover:text-slate-600"
            >
              ✕
            </button>
          )}
        </div>
      </header>

      {/* Список слів */}
      <main className="px-6 mt-6">
        <div className="flex justify-between items-end mb-4 px-1">
          <h2 className="text-sm font-bold text-slate-400 uppercase tracking-widest">
            {searchQuery ? 'Результати пошуку' : 'Всі слова'}
          </h2>
          <span className="text-xs font-bold bg-slate-200 text-slate-500 px-2 py-1 rounded-lg">
            {filteredWords.length}
          </span>
        </div>

        {loading ? (
          <div className="flex justify-center py-20">
            <div className="w-10 h-10 border-4 border-indigo-200 border-t-indigo-600 rounded-full animate-spin"></div>
          </div>
        ) : filteredWords.length > 0 ? (
          <div className="flex flex-col gap-3">
            {filteredWords.map((word, index) => (
              <motion.div 
                initial={{ opacity: 0, y: 10 }}
                animate={{ opacity: 1, y: 0 }}
                transition={{ delay: Math.min(index * 0.02, 0.5) }} // Обмеження затримки для великих списків
                key={word.id} 
                className="bg-white p-4 rounded-2xl shadow-sm border border-slate-100 flex justify-between items-center hover:shadow-md transition-shadow"
              >
                <div className="pr-3">
                  <h3 className="font-heading font-bold text-slate-800 text-lg mb-0.5">{word.hr_text}</h3>
                  <div className="flex items-center gap-2">
                    <p className="text-slate-500 text-sm font-medium">{word.ua_translation}</p>
                    {word.phonetic_note && (
                      <span className="bg-slate-50 border border-slate-100 text-slate-400 text-[10px] font-bold uppercase tracking-wider px-2 py-0.5 rounded-md">
                        {word.phonetic_note}
                      </span>
                    )}
                  </div>
                </div>
                
                <button 
                  onClick={() => speakCroatian(word.hr_text)}
                  className="shrink-0 w-12 h-12 bg-indigo-50 text-indigo-600 rounded-full flex items-center justify-center hover:bg-indigo-100 transition-colors active:scale-90"
                >
                  <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/></svg>
                </button>
              </motion.div>
            ))}
          </div>
        ) : (
          <div className="text-center py-20 text-slate-400 bg-white rounded-3xl border border-dashed border-slate-200">
            <span className="text-4xl mb-3 block">🔍</span>
            <p className="font-medium">Слів не знайдено</p>
          </div>
        )}
      </main>

      {/* Нижня навігація */}
      <div className="fixed bottom-6 left-0 right-0 px-6 z-50">
        <div className="bg-white/80 backdrop-blur-2xl border border-white/50 p-2 rounded-[2rem] shadow-2xl shadow-slate-300/50 flex justify-between items-center">
          <button onClick={() => router.push('/')} className="flex-1 flex flex-col items-center gap-1 py-3 text-slate-400 hover:text-slate-600 transition-colors">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            <span className="text-[10px] font-bold">Головна</span>
          </button>
          
          <button onClick={() => router.push('/lessons')} className="flex-1 flex flex-col items-center gap-1 py-3 text-slate-400 hover:text-slate-600 transition-colors">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="M4 19.5v-15A2.5 2.5 0 0 1 6.5 2H20v20H6.5a2.5 2.5 0 0 1 0-5H20"/></svg>
            <span className="text-[10px] font-bold">Уроки</span>
          </button>
          
          {/* Активна кнопка Словника */}
          <button className="flex-1 flex flex-col items-center gap-1 py-3 text-indigo-600">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><circle cx="12" cy="12" r="10"/><path d="M12 2a14.5 14.5 0 0 0 0 20 14.5 14.5 0 0 0 0-20"/><path d="M2 12h20"/></svg>
            <span className="text-[10px] font-bold">Словник</span>
          </button>
        </div>
      </div>
    </div>
  );
}