'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import { speakCroatian } from '@/utils/speech';
import Link from 'next/link';
import { motion, AnimatePresence } from 'framer-motion';

interface Topic {
  id: string;
  title_hr: string;
  title_ua: string;
  description: string;
  order_index: number;
  level: string;
}

interface VocabularyItem {
  id: string;
  topic_id: string;
  item_type: string;
  hr_text: string;
  ua_translation: string;
}

// Автоматичний підбір емодзі
const getTopicIcon = (title: string) => {
  const t = title.toLowerCase();
  if (t.includes('kafić') || t.includes('restoran') || t.includes('hrana')) return '☕️';
  if (t.includes('obitelj') || t.includes('odnosi')) return '🫂';
  if (t.includes('auto') || t.includes('promet')) return '🚗';
  if (t.includes('posao') || t.includes('ured')) return '💼';
  if (t.includes('putovanj') || t.includes('hotel')) return '✈️';
  if (t.includes('bolnic') || t.includes('zdravlje')) return '🏥';
  if (t.includes('novac') || t.includes('kupovina')) return '💳';
  if (t.includes('policija') || t.includes('sud')) return '⚖️';
  if (t.includes('tehnologija') || t.includes('internet')) return '💻';
  return '📚';
};

// Преміальні пастельні кольори для рівнів
const levelThemes: Record<string, { bg: string; text: string; lightBg: string; activeTab: string; border: string; gradient: string }> = {
  'A1': { bg: 'bg-slate-50', text: 'text-indigo-600', lightBg: 'bg-indigo-50', activeTab: 'bg-indigo-600 text-white shadow-indigo-200', border: 'border-indigo-100', gradient: 'from-indigo-500 to-indigo-600' },
  'A2': { bg: 'bg-slate-50', text: 'text-teal-600', lightBg: 'bg-teal-50', activeTab: 'bg-teal-500 text-white shadow-teal-200', border: 'border-teal-100', gradient: 'from-teal-400 to-teal-500' },
  'B1': { bg: 'bg-slate-50', text: 'text-orange-600', lightBg: 'bg-orange-50', activeTab: 'bg-orange-500 text-white shadow-orange-200', border: 'border-orange-100', gradient: 'from-orange-400 to-orange-500' },
  'Hitno': { bg: 'bg-slate-50', text: 'text-rose-600', lightBg: 'bg-rose-50', activeTab: 'bg-rose-500 text-white shadow-rose-200', border: 'border-rose-100', gradient: 'from-rose-500 to-rose-600' },
};

export default function LessonsPage() {
  const router = useRouter();
  const supabase = createClient();

  const [topics, setTopics] = useState<Topic[]>([]);
  const [vocabulary, setVocabulary] = useState<Record<string, VocabularyItem[]>>({});
  const [expandedTopicId, setExpandedTopicId] = useState<string | null>(null);
  const [activeLevel, setActiveLevel] = useState<string>('A1');
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    async function fetchData() {
      try {
        const { data: topicsData, error: topicsError } = await supabase
          .from('topics')
          .select('*')
          .order('level', { ascending: true })
          .order('order_index', { ascending: true });

        if (topicsError) throw topicsError;

        if (topicsData) {
          setTopics(topicsData);
          const firstA1 = topicsData.find(t => t.level === 'A1');
          if (firstA1) setExpandedTopicId(firstA1.id);
        }
      } catch (err) {
        console.error('Помилка:', err);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, [supabase]);

  useEffect(() => {
    async function fetchVocabularyForTopic() {
      if (!expandedTopicId || vocabulary[expandedTopicId]) return;
      
      const { data: vocabData } = await supabase
        .from('vocabulary')
        .select('*')
        .eq('topic_id', expandedTopicId)
        .neq('item_type', 'dialogue_line');

      if (vocabData) {
        setVocabulary(prev => ({ ...prev, [expandedTopicId]: vocabData }));
      }
    }
    fetchVocabularyForTopic();
  }, [expandedTopicId, supabase, vocabulary]);

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50 flex justify-center items-center">
        <div className="w-10 h-10 border-4 border-indigo-200 border-t-indigo-600 rounded-full animate-spin"></div>
      </div>
    );
  }

  const filteredTopics = topics.filter(t => (t.level || 'A1') === activeLevel);
  const theme = levelThemes[activeLevel] || levelThemes['A1'];

  return (
    <div className={`min-h-screen pb-32 font-sans transition-colors duration-500 bg-slate-50 overflow-x-hidden`}>
      
      {/* Стікі-Хедер з ефектом скла (Glassmorphism) */}
      <header className="sticky top-0 z-20 backdrop-blur-2xl bg-white/70 border-b border-slate-200/50 px-6 pt-10 pb-4 shadow-sm flex flex-col gap-4">
        <div className="flex justify-between items-center">
          <h1 className="font-heading text-3xl font-extrabold text-slate-800 tracking-tight">Уроки 📚</h1>
          <Link href="/trainer" className={`bg-gradient-to-r ${theme.gradient} text-white px-5 py-2.5 rounded-full text-sm font-bold shadow-lg shadow-indigo-200 hover:shadow-indigo-300 active:scale-95 transition-all flex items-center gap-2`}>
            Тренажер 
            <span className="bg-white/20 p-1 rounded-full"><svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round" strokeLinejoin="round"><path d="m9 18 6-6-6-6"/></svg></span>
          </Link>
        </div>

        {/* Вкладки рівнів (Tabs) у стилі iOS */}
        <div className="flex gap-2 bg-slate-100/80 p-1.5 rounded-2xl border border-slate-200">
          {['A1', 'A2', 'B1', 'Hitno'].map(level => {
            const isActive = activeLevel === level;
            const tabTheme = levelThemes[level] || levelThemes['A1'];
            return (
              <button
                key={level}
                onClick={() => {
                  setActiveLevel(level);
                  const firstOfLevel = topics.find(t => t.level === level);
                  if (firstOfLevel) setExpandedTopicId(firstOfLevel.id);
                }}
                className={`flex-1 py-2 rounded-xl text-sm font-bold transition-all duration-300 ${
                  isActive 
                    ? tabTheme.activeTab 
                    : 'text-slate-500 hover:text-slate-800'
                }`}
              >
                {level === 'Hitno' ? '🚑 SOS' : level}
              </button>
            );
          })}
        </div>
      </header>

      <main className="px-6 mt-6">
        {/* Вертикальна стежка тем (Vertical Roadmap) */}
        <div className="flex flex-col gap-6">
          <AnimatePresence>
            {filteredTopics.map((topic, index) => {
              const isExpanded = topic.id === expandedTopicId;
              const topicVocab = vocabulary[topic.id] || [];

              return (
                <motion.div 
                  layout
                  initial={{ opacity: 0, y: 20 }}
                  animate={{ opacity: 1, y: 0 }}
                  transition={{ delay: index * 0.05 }}
                  key={topic.id} 
                  className={`relative transition-all duration-300 rounded-[2rem] bg-white border ${
                    isExpanded ? `${theme.border} shadow-xl shadow-slate-200/50` : 'border-slate-100 shadow-sm'
                  }`}
                >
                  {/* Декоративна лінія зліва */}
                  <div className={`absolute left-0 top-6 bottom-6 w-1 rounded-r-full ${isExpanded ? theme.bg : 'bg-transparent'}`}></div>

                  {/* Шапка картки */}
                  <div 
                    onClick={() => setExpandedTopicId(isExpanded ? null : topic.id)}
                    className="p-6 flex items-center gap-4 cursor-pointer select-none"
                  >
                    <div className={`shrink-0 w-16 h-16 rounded-2xl flex items-center justify-center text-3xl shadow-sm ${theme.lightBg}`}>
                      {getTopicIcon(topic.title_hr)}
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className={`text-[10px] font-black uppercase tracking-widest mb-1 ${theme.text}`}>
                        Модуль {index + 1}
                      </div>
                      <h2 className="font-heading text-lg font-extrabold text-slate-800 leading-tight mb-1 truncate">{topic.title_ua}</h2>
                      <h3 className="text-sm font-medium text-slate-400 truncate">{topic.title_hr}</h3>
                    </div>
                    <div className={`shrink-0 w-8 h-8 rounded-full flex items-center justify-center transition-transform duration-300 ${isExpanded ? 'rotate-180 bg-slate-100' : 'bg-slate-50'}`}>
                      <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" className="text-slate-400" strokeLinecap="round" strokeLinejoin="round"><path d="m6 9 6 6 6-6"/></svg>
                    </div>
                  </div>

                  {/* Розгорнутий контент (Accordion Body) */}
                  <AnimatePresence>
                    {isExpanded && (
                      <motion.div 
                        initial={{ height: 0, opacity: 0 }}
                        animate={{ height: 'auto', opacity: 1 }}
                        exit={{ height: 0, opacity: 0 }}
                        className="overflow-hidden"
                      >
                        <div className="px-6 pb-6 border-t border-slate-50 pt-4">
                          
                          {topic.description && (
                            <p className="text-slate-500 text-sm font-medium leading-relaxed mb-6 bg-slate-50 p-4 rounded-2xl border border-slate-100">
                              {topic.description}
                            </p>
                          )}

                          <button 
                            onClick={(e) => {
                              e.stopPropagation();
                              router.push(`/lesson/${topic.id}`);
                            }} 
                            className={`w-full text-white font-bold py-4 rounded-2xl shadow-lg transition-transform active:scale-[0.98] flex items-center justify-center gap-2 mb-6 text-base bg-gradient-to-r ${theme.gradient}`}
                          >
                            Почати урок <span className="text-xl">➔</span>
                          </button>

                          <div className="flex items-center justify-between mb-4">
                            <h4 className="font-heading text-sm font-bold text-slate-400 uppercase tracking-widest">Словник модуля</h4>
                            <span className="text-xs font-bold bg-slate-100 text-slate-500 px-2 py-1 rounded-lg">{topicVocab.length} слів</span>
                          </div>
                          
                          <div className="flex flex-col gap-2 max-h-[300px] overflow-y-auto pr-1">
                            {topicVocab.map((item) => (
                              <div key={item.id} className="flex items-center justify-between p-4 rounded-2xl bg-white border border-slate-100 shadow-sm hover:border-slate-200 transition-colors">
                                <div className="pr-3">
                                  <div className="text-base font-bold text-slate-800">{item.hr_text}</div>
                                  <div className="text-sm text-slate-500">{item.ua_translation}</div>
                                </div>
                                <button 
                                  onClick={(e) => {
                                    e.stopPropagation();
                                    speakCroatian(item.hr_text);
                                  }} 
                                  className={`shrink-0 w-10 h-10 rounded-full flex items-center justify-center transition-all active:scale-90 ${theme.lightBg} ${theme.text}`}
                                >
                                  🔊
                                </button>
                              </div>
                            ))}
                            {topicVocab.length === 0 && (
                              <div className="text-center py-6 text-slate-400 bg-slate-50 rounded-2xl border border-dashed border-slate-200">
                                <p className="text-sm font-medium">Словник формується...</p>
                              </div>
                            )}
                          </div>

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

      {/* Нижня навігація (Та сама, що і всюди) */}
      <div className="fixed bottom-6 left-0 right-0 px-6 z-50">
        <div className="bg-white/80 backdrop-blur-2xl border border-white/50 p-2 rounded-[2rem] shadow-2xl shadow-slate-300/50 flex justify-between items-center">
          <button onClick={() => router.push('/')} className="flex-1 flex flex-col items-center gap-1 py-3 text-slate-400 hover:text-slate-600 transition-colors">
            <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
            <span className="text-[10px] font-bold">Головна</span>
          </button>
          
          <button className="flex-1 flex flex-col items-center gap-1 py-3 text-indigo-600">
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