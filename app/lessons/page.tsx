'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import { speakCroatian } from '@/utils/speech';
import Link from 'next/link';

interface Topic {
  id: string;
  title_hr: string;
  title_ua: string;
  description: string;
  order_index: number;
  level: string; // Додано поле рівня
}

interface VocabularyItem {
  id: string;
  topic_id: string;
  item_type: string;
  hr_text: string;
  ua_translation: string;
  phonetic_note?: string;
}

export default function LessonsPage() {
  const router = useRouter();
  const supabase = createClient();

  const [topics, setTopics] = useState<Topic[]>([]);
  const [vocabulary, setVocabulary] = useState<VocabularyItem[]>([]);
  const [selectedTopicId, setSelectedTopicId] = useState<string | null>(null);
  const [activeLevel, setActiveLevel] = useState<string>('A1'); // Стейт для вкладок рівня
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

        if (topicsData && topicsData.length > 0) {
          setTopics(topicsData);
          // Знаходимо першу тему рівня А1 при завантаженні
          const firstA1 = topicsData.find(t => t.level === 'A1');
          if (firstA1) setSelectedTopicId(firstA1.id);
        }
      } catch (err) {
        console.error('Помилка завантаження тем:', err);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, [supabase]);

  useEffect(() => {
    async function fetchVocabulary() {
      if (!selectedTopicId) return;
      const { data: vocabData, error: vocabError } = await supabase
        .from('vocabulary')
        .select('*')
        .eq('topic_id', selectedTopicId)
        .neq('item_type', 'dialogue_line');

      if (vocabError) {
        console.error('Помилка завантаження словника:', vocabError);
        return;
      }
      if (vocabData) setVocabulary(vocabData);
    }
    fetchVocabulary();
  }, [selectedTopicId, supabase]);

  if (loading) {
    return (
      <div className="min-h-screen bg-[#F4F7F9] flex justify-center items-center">
        <div className="w-10 h-10 border-4 border-blue-200 border-t-blue-600 rounded-full animate-spin"></div>
      </div>
    );
  }

  // Фільтруємо теми для поточного обраного рівня
  const filteredTopics = topics.filter(t => (t.level || 'A1') === activeLevel);
  const currentTopic = topics.find((t) => t.id === selectedTopicId);
  const currentTopicVocabulary = vocabulary;

  // Обробник зміни рівня
  const handleLevelChange = (level: string) => {
    setActiveLevel(level);
    const firstTopicOfLevel = topics.find(t => (t.level || 'A1') === level);
    if (firstTopicOfLevel) setSelectedTopicId(firstTopicOfLevel.id);
  };

  return (
    <div className="max-w-md mx-auto p-5 min-h-screen bg-[#F4F7F9] pb-12 font-sans">
      
      <header className="mb-4 mt-2 flex justify-between items-center">
        <div className="flex items-center gap-3">
          <Link href="/" className="w-10 h-10 bg-white border border-gray-200 rounded-full flex items-center justify-center text-gray-500 hover:text-blue-600 shadow-sm active:scale-95 transition-all">←</Link>
          <h1 className="text-2xl font-extrabold text-gray-900 tracking-tight">Уроки</h1>
        </div>
        <Link href="/trainer" className="bg-blue-100 text-blue-700 hover:bg-blue-200 px-4 py-2 rounded-xl text-sm font-bold transition-colors active:scale-95">
          Тренажер ➔
        </Link>
      </header>

      {/* НОВИЙ БЛОК: Вкладки рівнів (Tabs) */}
      <div className="flex gap-2 mb-6 bg-gray-200/50 p-1 rounded-2xl">
        {['A1', 'A2', 'B1', 'Hitno'].map(level => (
          <button
            key={level}
            onClick={() => handleLevelChange(level)}
            className={`flex-1 py-2 rounded-xl text-sm font-bold transition-all ${
              activeLevel === level 
                ? 'bg-white text-blue-600 shadow-sm' 
                : 'text-gray-500 hover:text-gray-700'
            }`}
          >
            {level === 'Hitno' ? '🚑 Екстрені' : `Рівень ${level}`}
          </button>
        ))}
      </div>

      {/* ГОРИЗОНТАЛЬНИЙ СКРОЛ ТЕМ (Тільки для обраного рівня) */}
      <div 
        className="flex gap-3 overflow-x-auto pb-4 mb-4 snap-x [&::-webkit-scrollbar]:hidden [-ms-overflow-style:none] [scrollbar-width:none] cursor-grab active:cursor-grabbing"
        onWheel={(e) => {
          const container = e.currentTarget;
          if (e.deltaY !== 0) { e.preventDefault(); container.scrollLeft += e.deltaY; }
        }}
      >
        {filteredTopics.map((topic, index) => {
          const isSelected = topic.id === selectedTopicId;
          const displayTopicNumber = index + 1; 

          return (
            <button
              key={topic.id}
              onClick={() => setSelectedTopicId(topic.id)}
              className={`snap-center shrink-0 w-[200px] p-4 rounded-[1.5rem] text-left transition-all active:scale-95 border-2 ${
                isSelected ? 'bg-blue-600 text-white border-blue-600 shadow-md shadow-blue-200' : 'bg-white text-gray-700 border-transparent hover:border-blue-200 shadow-sm'
              }`}
            >
              <div className={`text-[10px] font-bold uppercase tracking-widest mb-1 ${isSelected ? 'text-blue-200' : 'text-gray-400'}`}>
                Модуль {displayTopicNumber}
              </div>
              <div className={`font-bold leading-tight ${isSelected ? 'text-white' : 'text-gray-800'}`}>{topic.title_ua}</div>
            </button>
          );
        })}
      </div>

      {/* КОНТЕНТ ОБРАНОЇ ТЕМИ */}
      {currentTopic && (
        <div className="bg-white rounded-[2rem] p-6 shadow-sm border border-gray-100 mb-6 animate-fade-in">
          <div className="mb-6">
            <h2 className="text-2xl font-extrabold text-gray-900 leading-tight mb-1">{currentTopic.title_ua}</h2>
            <p className="text-blue-600 font-medium text-sm mb-4">{currentTopic.title_hr}</p>
            {currentTopic.description && (
              <p className="text-gray-500 text-sm bg-gray-50 p-4 rounded-2xl border border-gray-100 leading-relaxed">{currentTopic.description}</p>
            )}
          </div>

          <button onClick={() => router.push(`/lesson/${currentTopic.id}`)} className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 rounded-2xl shadow-md shadow-blue-200 transition-all active:scale-95 flex items-center justify-center gap-2 mb-8 text-lg">
            <span>💬</span> Пройти діалог теми
          </button>

          <h3 className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-4">Словник модуля</h3>
          
          <div className="flex flex-col gap-3">
            {currentTopicVocabulary.map((item) => (
              <div key={item.id} className="flex items-center justify-between p-4 rounded-2xl bg-gray-50 border border-gray-100 group hover:border-blue-200 transition-colors">
                <div>
                  <div className="text-lg font-bold text-gray-900">{item.hr_text}</div>
                  <div className="text-sm text-gray-500">{item.ua_translation}</div>
                </div>
                <button onClick={() => speakCroatian(item.hr_text)} className="w-10 h-10 bg-white text-blue-600 rounded-full shadow-sm border border-gray-100 hover:bg-blue-50 flex items-center justify-center transition-all active:scale-90">🔊</button>
              </div>
            ))}
            {currentTopicVocabulary.length === 0 && (
              <div className="text-center py-8 text-gray-400 bg-gray-50 rounded-2xl border border-dashed border-gray-200">
                <span className="text-2xl mb-2 block">📭</span>
                <p className="text-sm">Слова для цієї теми ще не згенеровані.</p>
              </div>
            )}
          </div>
        </div>
      )}
    </div>
  );
}