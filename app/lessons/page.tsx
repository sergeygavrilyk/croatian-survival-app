'use client';

import React, { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client'; // Використовуємо наш налаштований SSR-клієнт
import { speakCroatian } from '@/utils/speech';

interface Topic {
  id: string;
  title_hr: string;
  title_ua: string;
  description: string;
  order_index: number;
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
  // Усі хуки та ініціалізації мають бути ВНУТРІШНЬОЮ частиною компонента
  const router = useRouter();
  const supabase = createClient();

  const [topics, setTopics] = useState<Topic[]>([]);
  const [vocabulary, setVocabulary] = useState<VocabularyItem[]>([]);
  const [selectedTopicId, setSelectedTopicId] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);

  // Функція виходу
  const handleLogout = async () => {
    await supabase.auth.signOut();
    router.push('/login');
    router.refresh();
  };

  useEffect(() => {
    async function fetchData() {
      try {
        const { data: topicsData, error: topicsError } = await supabase
          .from('topics')
          .select('*')
          .order('order_index', { ascending: true });

        if (topicsError) {
          console.error('Помилка завантаження тем:', topicsError.message);
          return;
        }

        if (topicsData && topicsData.length > 0) {
          setTopics(topicsData);
          setSelectedTopicId(topicsData[0].id);
        }

        const { data: vocabData, error: vocabError } = await supabase
          .from('vocabulary')
          .select('*');

        if (vocabError) {
          console.error('Помилка завантаження словника:', vocabError.message);
          return;
        }

        if (vocabData) {
          setVocabulary(vocabData);
        }
      } catch (err) {
        console.error('Помилка:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchData();
  }, [supabase]);

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen bg-gray-50 text-gray-500">
        Завантаження матеріалів...
      </div>
    );
  }

  const currentTopicVocabulary = vocabulary.filter(
    (item) => item.topic_id === selectedTopicId
  );

  const currentTopic = topics.find((t) => t.id === selectedTopicId);

  return (
    <div className="max-w-4xl mx-auto p-4 min-h-screen bg-gray-50 pb-12">
      {/* Шапка */}
      <div className="flex justify-between items-start mb-6">
        <div>
          <h1 className="text-2xl font-bold text-gray-800">Навчальні модулі</h1>
          <div className="flex items-center gap-3 mt-1">
            <a href="/" className="text-sm text-blue-500 hover:text-blue-600 hover:underline font-medium">
              ← На дашборд
            </a>
            <span className="text-gray-300">|</span>
            <button 
              onClick={handleLogout} 
              className="text-sm text-red-500 hover:text-red-600 hover:underline font-medium"
            >
              Вийти
            </button>
          </div>
        </div>
        <a 
          href="/trainer" 
          className="bg-blue-600 text-white px-4 py-2 rounded-xl text-sm font-semibold shadow hover:bg-blue-700 transition shrink-0"
        >
          Тренажер ➔
        </a>
      </div>

      {/* Список тем (горизонтальний скрол) */}
      <div className="flex gap-2 overflow-x-auto pb-4 mb-6 no-scrollbar">
        {topics.map((topic) => {
          const isSelected = topic.id === selectedTopicId;
          return (
            <button
              key={topic.id}
              onClick={() => setSelectedTopicId(topic.id)}
              className={`px-4 py-3 rounded-2xl text-left whitespace-nowrap transition-all shadow-sm ${
                isSelected
                  ? 'bg-blue-600 text-white font-semibold shadow-md'
                  : 'bg-white text-gray-700 hover:bg-gray-100 border border-gray-100'
              }`}
            >
              <div className="text-xs opacity-80">Тема {topic.order_index}</div>
              <div className="text-sm">{topic.title_ua}</div>
            </button>
          );
        })}
      </div>

      {/* Контент обраної теми */}
      {currentTopic && (
        <div className="bg-white rounded-3xl p-6 shadow-sm border border-gray-100 mb-6">
          <h2 className="text-xl font-bold text-gray-800 mb-1">{currentTopic.title_ua}</h2>
          <p className="text-gray-500 text-sm italic mb-4">{currentTopic.title_hr}</p>
          {currentTopic.description && (
            <p className="text-gray-600 text-sm bg-gray-50 p-3 rounded-xl mb-6">
              {currentTopic.description}
            </p>
          )}

          <h3 className="text-md font-semibold text-gray-700 mb-3">Корисні слова та фрази теми:</h3>
          
          <div className="grid gap-3">
            {currentTopicVocabulary.map((item) => (
              <div 
                key={item.id}
                className="flex flex-col sm:flex-row justify-between items-start sm:items-center p-4 rounded-2xl bg-gray-50 border border-gray-100 gap-2"
              >
                <div>
                  <div className="text-lg font-bold text-gray-800">{item.hr_text}</div>
                  <div className="text-sm text-blue-600 font-medium">{item.ua_translation}</div>
                </div>
                
                <div className="flex items-center gap-3">
                  {item.phonetic_note && (
                    <div className="text-xs text-gray-400 bg-white px-3 py-1.5 rounded-lg border border-gray-100">
                      {item.phonetic_note}
                    </div>
                  )}
                  
                  <button
                    onClick={() => speakCroatian(item.hr_text)}
                    className="p-2.5 bg-white text-blue-600 rounded-xl shadow-sm border border-gray-100 hover:bg-blue-50 transition"
                    title="Прослухати"
                  >
                    🔊
                  </button>
                </div>
              </div>
            ))}

            {currentTopicVocabulary.length === 0 && (
              <p className="text-gray-400 text-sm py-4 text-center">
                Для цієї теми поки немає доданих слів.
              </p>
            )}
          </div>
        </div>
      )}
    </div>
  );
}