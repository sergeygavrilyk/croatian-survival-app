'use client';

import React, { useState, useEffect } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import { speakCroatian } from '@/utils/speech';

// 1. ДОДАНО: Імпорт функції збереження прогресу
import { markTopicAsCompleted } from '@/app/actions/progress';

// Інтерфейси
interface Topic {
  id: string;
  title_hr: string;
  title_ua: string;
}

interface ConversationLine {
  id: string;
  speaker_name: string;
  hr_text: string;
  ua_translation: string;
  order_index: number;
}

interface WordDefinition {
  id: string;
  hr_text: string;
  ua_translation: string;
}

export default function LessonDialoguePage() {
  const router = useRouter();
  const params = useParams();
  const topicId = params.id as string;
  const supabase = createClient();

  const [topic, setTopic] = useState<Topic | null>(null);
  const [dialogue, setDialogue] = useState<ConversationLine[]>([]);
  const [topicVocabulary, setTopicVocabulary] = useState<WordDefinition[]>([]);
  const [loading, setLoading] = useState(true);
  
  // Стейт для Bottom Sheet (Шторки перекладу)
  const [selectedWord, setSelectedWord] = useState<WordDefinition | null>(null);

  // 2. ДОДАНО: Стейт для індикатора завантаження при збереженні
  const [isCompleting, setIsCompleting] = useState(false);

  useEffect(() => {
    async function fetchData() {
      try {
        const { data: topicData } = await supabase
          .from('topics')
          .select('*')
          .eq('id', topicId)
          .single();
        if (topicData) setTopic(topicData);

        const { data: convData } = await supabase
          .from('conversations')
          .select('*')
          .eq('topic_id', topicId)
          .order('order_index', { ascending: true });
        if (convData) setDialogue(convData);

        const { data: vocabData } = await supabase
          .from('vocabulary')
          .select('id, hr_text, ua_translation, phonetic_note')
          .eq('topic_id', topicId)
          .eq('item_type', 'word');
        if (vocabData) setTopicVocabulary(vocabData);

      } catch (err) {
        console.error('Помилка завантаження даних:', err);
      } finally {
        setLoading(false);
      }
    }
    fetchData();
  }, [topicId, supabase]);

  const handleWordClick = async (wordRaw: string) => {
    const cleanWord = wordRaw.replace(/[.,!?;:"'«»]/g, '').trim().toLowerCase();
    if (!cleanWord) return;

    let foundWord = null;

    foundWord = topicVocabulary.find(
      (v) => v.hr_text.toLowerCase() === cleanWord
    );

    if (!foundWord) {
      const { data: trigramData, error } = await supabase
        .rpc('match_vocabulary_trigram', { search_query: cleanWord });

      if (!error && trigramData && trigramData.length > 0) {
        foundWord = trigramData[0];
      } else {
        const { getOrTranslateWord } = await import('@/app/actions/vocabulary');
        const fallbackWord = await getOrTranslateWord(cleanWord);
        if (fallbackWord) {
          foundWord = fallbackWord;
        }
      }
    }

    if (foundWord) {
      setSelectedWord(foundWord);
      speakCroatian(foundWord.hr_text);
    } else {
      setSelectedWord({
        id: 'error-fallback',
        hr_text: wordRaw,
        ua_translation: 'Не вдалося завантажити переклад',
        phonetic_note: 'Помилка'
      });
    }
  };

  // 3. ДОДАНО: Функція збереження прогресу
  const handleLessonComplete = async () => {
    if (isCompleting) return;
    setIsCompleting(true);
    try {
      await markTopicAsCompleted(topicId); 
    } catch (err) {
      console.error('Помилка збереження:', err);
    } finally {
      router.push('/lessons'); 
    }
  };

  if (loading || isCompleting) {
    return (
      <div className="min-h-screen bg-gray-50 flex flex-col justify-center items-center">
        <div className="w-10 h-10 border-4 border-gray-200 border-t-blue-600 rounded-full animate-spin mb-4"></div>
        {isCompleting && <p className="text-gray-500 font-medium">Зберігаємо прогрес...</p>}
      </div>
    );
  }

  const isUserSpeaker = (speakerName: string) => {
    if (dialogue.length === 0) return false;
    const firstSpeaker = dialogue[0].speaker_name;
    return speakerName !== firstSpeaker;
  };

  return (
    <div className="min-h-screen bg-[#F4F7F9] font-sans pb-32">
      
      {/* Sticky Header */}
      <header className="sticky top-0 z-20 backdrop-blur-xl bg-white/80 border-b border-gray-200/50 px-5 py-4 flex items-center justify-between shadow-sm">
        <button onClick={() => router.push('/lessons')} className="w-10 h-10 bg-white border border-gray-200 rounded-full flex items-center justify-center text-gray-600 hover:text-blue-600 shadow-sm active:scale-95 transition-all">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="m15 18-6-6 6-6"/></svg>
        </button>
        <div className="text-center flex-1 px-4">
          <h1 className="text-lg font-black text-gray-900 truncate">{topic?.title_ua || 'Діалог'}</h1>
          <p className="text-xs font-bold text-gray-400 uppercase tracking-widest">{topic?.title_hr}</p>
        </div>
        <div className="w-10 h-10"></div> {/* Пустий блок для балансу */}
      </header>

      {/* Месенджер (Chat UI) */}
      <div className="max-w-md mx-auto p-5 flex flex-col gap-6 mt-4">
        {dialogue.map((line, index) => {
          const isUser = isUserSpeaker(line.speaker_name);

          return (
            <div key={line.id} className={`flex flex-col ${isUser ? 'items-end' : 'items-start'} animate-fade-in-up`} style={{ animationDelay: `${index * 100}ms` }}>
              <span className="text-[11px] font-bold text-gray-400 mb-1 px-1 uppercase tracking-wider">
                {line.speaker_name}
              </span>
              
              <div className={`relative max-w-[85%] p-4 shadow-sm group ${
                isUser 
                  ? 'bg-blue-600 text-white rounded-2xl rounded-br-sm' 
                  : 'bg-white text-gray-900 border border-gray-100 rounded-2xl rounded-bl-sm'
              }`}>
                {/* Клікабельний Хорватський Текст */}
                <p className="text-base font-medium leading-relaxed mb-2">
                  {line.hr_text.split(' ').map((wordRaw, i) => (
                    <span 
                      key={i} 
                      onClick={() => handleWordClick(wordRaw)}
                      className={`cursor-pointer inline-block mr-1 transition-colors ${isUser ? 'hover:text-blue-200' : 'hover:text-blue-600'}`}
                    >
                      {wordRaw}
                    </span>
                  ))}
                </p>
                
                {/* Переклад репліки */}
                <p className={`text-sm ${isUser ? 'text-blue-100/80' : 'text-gray-500'}`}>
                  {line.ua_translation}
                </p>

                {/* Кнопка озвучки всієї репліки */}
                <button 
                  onClick={() => speakCroatian(line.hr_text)}
                  className={`absolute -bottom-3 ${isUser ? '-left-3 bg-white text-blue-600' : '-right-3 bg-blue-50 text-blue-600'} w-8 h-8 rounded-full shadow-md border border-gray-100 flex items-center justify-center opacity-0 group-hover:opacity-100 transition-all active:scale-90`}
                >
                  <svg width="14" height="14" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/></svg>
                </button>
              </div>
            </div>
          );
        })}

        {dialogue.length === 0 && (
          <div className="text-center py-12 text-gray-400 bg-white rounded-3xl border border-dashed border-gray-200">
            <span className="text-4xl mb-3 block">💬</span>
            <p className="text-sm">Діалог для цієї теми ще не згенеровано.</p>
          </div>
        )}

        {/* 4. ДОДАНО: Кнопка Завершити Урок під чатом */}
        {dialogue.length > 0 && (
          <div className="mt-8">
            <button 
              onClick={handleLessonComplete}
              disabled={isCompleting}
              className="w-full bg-emerald-500 hover:bg-emerald-600 text-white font-bold py-4 rounded-2xl shadow-md shadow-emerald-200 transition-all active:scale-95 flex items-center justify-center gap-2"
            >
              {isCompleting ? 'Збереження...' : '✅ Завершити урок'}
            </button>
          </div>
        )}
      </div>

      {/* Шторка (Bottom Sheet) для перекладу слів */}
      <div className={`fixed inset-x-0 bottom-0 z-50 transform transition-transform duration-300 ease-out ${selectedWord ? 'translate-y-0' : 'translate-y-full'}`}>
        {/* Затемнення фону */}
        {selectedWord && (
          <div className="fixed inset-0 bg-black/20 -z-10 transition-opacity" onClick={() => setSelectedWord(null)}></div>
        )}
        
        <div className="bg-white rounded-t-[2rem] p-6 pb-12 shadow-[0_-10px_40px_rgba(0,0,0,0.1)] border-t border-gray-100 max-w-md mx-auto">
          <div className="w-12 h-1.5 bg-gray-200 rounded-full mx-auto mb-6"></div>
          
          <div className="text-center mb-8">
            <h3 className="text-3xl font-black text-gray-900 mb-2">{selectedWord?.hr_text}</h3>
            <p className="text-lg text-gray-500 font-medium">{selectedWord?.ua_translation}</p>
          </div>

          <div className="flex gap-3">
            <button 
              onClick={() => {
                if(selectedWord) speakCroatian(selectedWord.hr_text);
              }} 
              className="flex-1 bg-gray-100 hover:bg-gray-200 text-gray-800 font-bold py-4 rounded-2xl transition-all active:scale-95 flex items-center justify-center gap-2"
            >
              🔊 Слухати
            </button>
            <button 
              onClick={() => {
                alert(`Слово "${selectedWord?.hr_text}" збережено в тренажер!`);
                setSelectedWord(null);
              }} 
              className="flex-[2] bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 rounded-2xl shadow-md shadow-blue-200 transition-all active:scale-95 flex items-center justify-center gap-2"
            >
              ⭐️ В Тренажер
            </button>
          </div>
        </div>
      </div>

    </div>
  );
}