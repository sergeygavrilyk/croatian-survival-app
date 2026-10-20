'use client';

import React, { useEffect, useState, useCallback, useRef } from 'react';
import { createClient } from '@/utils/supabase/client';
import { motion } from 'framer-motion';
import { speakCroatian } from '@/utils/speech';
import PracticeTabs from '@/components/ui/PracticeTabs';
import { dictionarySearchTerm, posLabelUk } from '@/lib/format';

const PAGE_SIZE = 30; // Розмір однієї порції слів

export default function DictionaryPage() {
  const supabase = createClient();
  
  const [words, setWords] = useState<any[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  // Пошук іде в базі по всьому словнику (раніше — лише серед 30 завантажених слів), із затримкою 300 мс
  const [term, setTerm] = useState<string | null>(null);
  const requestRef = useRef(0); // відповідь старішого запиту (попередній пошук) не перезаписує новішу
  const [page, setPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);

  // ОПТИМІЗОВАНО: Порційне завантаження з точковими полями
  const fetchWords = useCallback(async (pageIndex: number, isReset: boolean = false, search: string | null = null) => {
    if (isReset) {
      setLoading(true);
    } else {
      setLoadingMore(true);
    }

    const requestId = ++requestRef.current;
    const from = pageIndex * PAGE_SIZE;
    const to = from + PAGE_SIZE - 1;

    try {
      let request = supabase
        .from('lexemes')
        .select('id, lemma, ukrainian_translation, part_of_speech, cefr') // Точкові поля замість *
        .eq('status', 'PUBLISHED')
        .not('lemma', 'like', '%:%'); // без реплік діалогів («Konobar: …»)
      if (search) {
        // лема, лема без діакритики (macka → mačka) або переклад
        request = request.or(`lemma.ilike.%${search}%,normalized.ilike.%${search}%,ukrainian_translation.ilike.%${search}%`);
      }
      const { data, error } = await request
        .order('cefr', { ascending: true, nullsFirst: false }) // спершу A0, потім A1…
        .order('frequency_rank', { ascending: true, nullsFirst: false })
        .order('lemma', { ascending: true })
        .range(from, to); // Пагінація на рівні БД

      if (error) throw error;
      if (requestId !== requestRef.current) return;

      if (data) {
        setHasMore(data.length === PAGE_SIZE); // менше за порцію — кінець словника чи результатів
        // Поля під існуючу розмітку картки слова
        const mapped = data.map((lex) => ({
          id: lex.id,
          hr_text: lex.lemma,
          ua_translation: lex.ukrainian_translation,
          phonetic_note: [posLabelUk(lex.part_of_speech), lex.cefr].filter(Boolean).join(' · '),
        }));
        setWords(prev => isReset ? mapped : [...prev, ...mapped]);
      }
    } catch (err) {
      console.error('Помилка завантаження словника:', err);
    } finally {
      if (requestId === requestRef.current) {
        setLoading(false);
        setLoadingMore(false);
      }
    }
  }, [supabase]);

  // Затримка: шукаємо, коли користувач перестав друкувати
  useEffect(() => {
    const timer = setTimeout(() => setTerm(dictionarySearchTerm(searchQuery)), 300);
    return () => clearTimeout(timer);
  }, [searchQuery]);

  useEffect(() => {
    setPage(0);
    fetchWords(0, true, term);
  }, [fetchWords, term]);

  const loadMore = () => {
    if (loadingMore || !hasMore) return;
    const nextPage = page + 1;
    setPage(nextPage);
    fetchWords(nextPage, false, term);
  };

  const filteredWords = words;

  return (
    <div className="min-h-screen pb-28 font-sans overflow-x-hidden">
      
      {/* Шапка з пошуком */}
      <header className="sticky top-0 z-20 backdrop-blur-2xl bg-white/70 border-b border-slate-200/50 px-6 pt-10 pb-6 shadow-sm">
        <h1 className="font-heading text-h1 mb-2">Практика</h1>
        <PracticeTabs className="mb-4" />
        
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
            {filteredWords.length} показано
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
                transition={{ delay: Math.min(index * 0.02, 0.3) }}
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

            {/* Кнопка "Завантажити ще" */}
            {hasMore && (
              <button
                onClick={loadMore}
                disabled={loadingMore}
                className="mt-4 w-full bg-indigo-50 text-indigo-600 font-bold py-4 rounded-2xl shadow-sm border border-indigo-100 active:scale-[0.98] transition-all disabled:opacity-50 flex items-center justify-center gap-2"
              >
                {loadingMore ? (
                  <>
                    <div className="w-5 h-5 border-2 border-indigo-600 border-t-transparent rounded-full animate-spin"></div>
                    <span>Завантаження...</span>
                  </>
                ) : (
                  <span>Завантажити ще 30 слів ➔</span>
                )}
              </button>
            )}

            {!hasMore && !searchQuery && (
              <div className="text-center text-xs text-slate-400 mt-6 font-medium">
                Ви переглянули весь словник 🎉
              </div>
            )}
          </div>
        ) : (
          <div className="text-center py-20 text-slate-400 bg-white rounded-3xl border border-dashed border-slate-200">
            <span className="text-4xl mb-3 block">🔍</span>
            <p className="font-medium">Слів не знайдено</p>
          </div>
        )}
      </main>

    </div>
  );
}