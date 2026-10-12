'use client';

import React, { useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { speakCroatian } from '@/utils/speech';
import { createClient } from '@/utils/supabase/client';
import RoleplaySimulator from '@/components/features/RoleplaySimulator';
import { track } from '@/lib/analytics-client';

// Додайте ці інтерфейси на початку LessonView.tsx
export interface GrammarRule {
  id: string;
  title_ua: string;
  explanation_ua: string;
  pattern_hr?: string;
  examples: Array<{ hr: string; ua: string }>;
}

export interface GrammarTopic {
  id: string;
  title_ua: string;
  title_hr?: string;
  description?: string;
  rules: GrammarRule[];
}

export interface DialogueLine {
  id: string;
  speaker_name: string;
  hr_text: string;
  ua_translation: string;
}

export interface Exercise {
  id: string;
  exercise_type: string;
  question_text: string;
  correct_answer: string;
  options: string[];
}

export interface VocabularyItem {
  id: string;
  hr_text: string;
  ua_translation: string;
  phonetic_note?: string;
}

interface LessonViewProps {
  title: string;
  description?: string;
  lines: DialogueLine[];
  exercises?: Exercise[];
  topicWords?: VocabularyItem[];
  grammar?: GrammarTopic[];
  /** Викликається, коли урок завершено (остання вправа або «Завершити урок»). */
  onComplete?: () => void;
  /** ID уроку — для аналітики */
  lessonId?: string;
}

export default function LessonView({ title, description, lines, exercises = [], topicWords = [], grammar, onComplete, lessonId }: LessonViewProps) {
  const router = useRouter();
  const supabase = createClient();
  
  // Оновіть стейт mode
  const [mode, setMode] = useState<'dialogue' | 'grammar' | 'roleplay' | 'practice'>('dialogue');
  
  // Стейти для вправ
  const [currentExIndex, setCurrentExIndex] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState<string | null>(null);
  const [builderWords, setBuilderWords] = useState<string[]>([]);
  const [isError, setIsError] = useState(false);
  const [isSuccessDelay, setIsSuccessDelay] = useState(false);
  // Аналітика вправ: кількість спроб і час на поточну вправу
  const attemptRef = useRef(0);
  const exerciseStartRef = useRef(Date.now());
  const [comboCount, setComboCount] = useState(0);

  // --- СТЕЙТИ ДЛЯ CLICK-TO-SAVE ---
  const [selectedWordInfo, setSelectedWordInfo] = useState<VocabularyItem | null>(null);
  const [savedWordIds, setSavedWordIds] = useState<Set<string>>(new Set());
  const [isSavingWord, setIsSavingWord] = useState(false);

  const uniqueSpeakers = Array.from(new Set(lines.map((l) => l.speaker_name)));

  // --- ЛОГІКА ЗБЕРЕЖЕННЯ СЛОВА В SRS ---
  const handleSaveWord = async () => {
    if (!selectedWordInfo) return;
    setIsSavingWord(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        await supabase.from('user_progress').upsert({
          user_id: user.id,
          lexeme_id: selectedWordInfo.id,
          interval_days: 0, 
          ease_factor: 2.5,
          next_review_date: new Date().toISOString()
        }, { onConflict: 'user_id,lexeme_id', ignoreDuplicates: true }); // вже збережене слово не скидаємо
        
        setSavedWordIds(prev => new Set(prev).add(selectedWordInfo.id));
        track('word_saved', { lexeme_id: selectedWordInfo.id, lesson_id: lessonId, source: 'lesson' });
      }
    } catch (e) {
      console.error(e);
    } finally {
      setIsSavingWord(false);
    }
  };

  const findVocabMatch = (word: string) => {
    const cleanWord = word.replace(/[^\p{L}]/gu, '').toLowerCase();
    if (!cleanWord || cleanWord.length < 2) return null;
    
    return topicWords.find(v => {
      const vText = v.hr_text.toLowerCase();
      if (vText === cleanWord) return true;
      if (cleanWord.length > 3 && vText.length > 3) {
        const root = vText.substring(0, vText.length - 1);
        if (cleanWord.startsWith(root)) return true;
      }
      return false;
    });
  };

  const renderInteractiveText = (text: string, isUserBubble: boolean) => {
    const parts = text.split(/(\s+)/);
    
    return parts.map((chunk, i) => {
      if (!chunk.trim()) return <span key={i}>{chunk}</span>;
      
      const match = findVocabMatch(chunk);
      if (match) {
        return (
          <span 
            key={i} 
            onClick={(e) => { 
              e.stopPropagation(); 
              setSelectedWordInfo(match); 
              speakCroatian(match.hr_text); 
            }}
            className={`cursor-pointer underline decoration-dashed underline-offset-4 transition-colors ${
              isUserBubble 
                ? 'decoration-blue-300 hover:text-blue-200' 
                : 'decoration-blue-400 text-blue-700 hover:text-blue-500 font-medium'
            }`}
          >
            {chunk}
          </span>
        );
      }
      return <span key={i}>{chunk}</span>;
    });
  };

  // --- ЕКРАНИ ---

  if (mode === 'roleplay') {
    return (
      <RoleplaySimulator 
        lines={lines} 
        uniqueSpeakers={uniqueSpeakers} 
        onExit={() => setMode('dialogue')} 
      />
    );
  }

  if (mode === 'grammar') {
    return (
      <div className="max-w-md mx-auto p-4 flex flex-col h-full min-h-screen bg-[#F4F7F9]">
        <div className="flex items-center gap-4 mb-6 mt-2">
          <button onClick={() => setMode('dialogue')} className="text-gray-400 hover:text-gray-600 font-bold p-1">← Назад</button>
          <h2 className="text-xl font-bold text-gray-900">Граматика</h2>
        </div>
        
        <div className="flex-1 overflow-y-auto space-y-6 pb-8">
          {grammar?.map(topic => (
            <div key={topic.id} className="bg-white p-5 rounded-2xl shadow-sm border border-gray-100">
              <h3 className="text-lg font-black text-slate-800 mb-2">{topic.title_ua}</h3>
              {topic.description && <p className="text-sm text-slate-500 mb-4">{topic.description}</p>}
              
              <div className="space-y-6 mt-4">
                {topic.rules.map(rule => (
                  <div key={rule.id} className="border-t border-slate-100 pt-4">
                    <h4 className="font-bold text-indigo-600 mb-1">{rule.title_ua}</h4>
                    <p className="text-sm text-slate-600 mb-3 leading-relaxed">{rule.explanation_ua}</p>
                    
                    {rule.pattern_hr && (
                      <div className="bg-slate-50 p-3 rounded-xl mb-3 text-center border border-slate-100 font-mono text-sm text-slate-700 font-bold">
                        {rule.pattern_hr}
                      </div>
                    )}
                    
                    {rule.examples.length > 0 && (
                      <div className="space-y-2 bg-indigo-50/50 p-3 rounded-xl">
                        {rule.examples.map((ex, i) => (
                          <div key={i} className="text-sm">
                            <span className="font-bold text-slate-800 block">{ex.hr}</span>
                            <span className="text-slate-500">{ex.ua}</span>
                          </div>
                        ))}
                      </div>
                    )}
                  </div>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    );
  }

  if (mode === 'dialogue') {
    return (
      <div className="max-w-md mx-auto p-4 flex flex-col h-full min-h-screen bg-[#F4F7F9] relative">
        <div className="flex items-start justify-between mb-6 mt-2">
          <button onClick={() => router.push('/lessons')} className="text-gray-400 hover:text-gray-600 text-2xl font-bold p-1 -ml-1">✕</button>
          <div className="flex-1 text-center px-2">
            <h2 className="text-2xl font-extrabold text-gray-900 leading-tight">{title}</h2>
            {description && <p className="text-gray-500 text-sm mt-1 font-medium">{description}</p>}
          </div>
          <div className="w-8"></div>
        </div>

        <div className="flex-1 space-y-4 mb-8 overflow-y-auto pb-4">
          {lines.map((line, index) => {
            const isUser = index % 2 === 0;
            return (
              <div key={line.id} className={`flex flex-col ${isUser ? 'items-end' : 'items-start'}`}>
                <span className="text-[10px] font-bold text-gray-400 mb-1 px-2 uppercase tracking-widest">{line.speaker_name}</span>
                <div 
                  onClick={() => speakCroatian(line.hr_text)}
                  className={`max-w-[85%] rounded-[1.5rem] p-4 shadow-sm cursor-pointer hover:opacity-95 active:scale-[0.98] transition-all flex flex-col ${
                    isUser ? 'bg-blue-600 text-white rounded-tr-none' : 'bg-white text-gray-800 border border-gray-100 rounded-tl-none'
                  }`}
                >
                  <div className="flex items-start justify-between gap-3">
                    <p className="text-lg font-semibold mb-1">
                      {renderInteractiveText(line.hr_text, isUser)}
                    </p>
                    <span className={`shrink-0 text-lg opacity-70 ${isUser ? 'text-blue-200' : 'text-gray-400'}`}>🔊</span>
                  </div>
                  <p className={`text-sm ${isUser ? 'text-blue-100' : 'text-gray-500'}`}>{line.ua_translation}</p>
                </div>
              </div>
            );
          })}
        </div>

        <div className="flex flex-col gap-3">
          {grammar && grammar.length > 0 && (
            <button onClick={() => setMode('grammar')} className="w-full bg-amber-100 text-amber-700 hover:bg-amber-200 font-bold py-3.5 rounded-2xl shadow-sm transition-colors active:scale-[0.98] flex justify-center items-center gap-2">
              <span>💡</span> Пояснення граматики
            </button>
          )}

          <button onClick={() => setMode('roleplay')} className="w-full bg-purple-100 text-purple-700 hover:bg-purple-200 font-bold py-3.5 rounded-2xl shadow-sm transition-colors active:scale-[0.98] flex justify-center items-center gap-2">
            <span>🎭</span> Симулятор розмови
          </button>
          <button onClick={() => {
              if (exercises.length > 0) {
                  exerciseStartRef.current = Date.now();
                  attemptRef.current = 0;
                  setMode('practice');
              } else {
                  onComplete?.();
              }
          }} className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 rounded-2xl shadow-md transition-colors active:scale-[0.98]">
            {exercises.length > 0 ? 'Перейти до вправ ➔' : 'Завершити урок'}
          </button>
        </div>

        {selectedWordInfo && (
          <div className="absolute bottom-0 left-0 right-0 bg-white rounded-t-[2rem] shadow-[0_-20px_40px_-15px_rgba(0,0,0,0.1)] p-6 z-50 animate-fade-in-up border border-gray-100">
            <div className="flex justify-between items-start mb-4">
              <div>
                <h3 className="text-3xl font-black text-gray-900 mb-1">{selectedWordInfo.hr_text}</h3>
                <p className="text-lg text-blue-600 font-medium">{selectedWordInfo.ua_translation}</p>
              </div>
              <button onClick={() => setSelectedWordInfo(null)} className="bg-gray-100 w-8 h-8 rounded-full flex items-center justify-center text-gray-500 font-bold hover:bg-gray-200">✕</button>
            </div>
            
            {savedWordIds.has(selectedWordInfo.id) ? (
              <div className="w-full bg-emerald-50 text-emerald-600 font-bold py-3.5 rounded-xl flex justify-center items-center gap-2">
                <span>✓</span> Збережено в тренажер
              </div>
            ) : (
              <button 
                onClick={handleSaveWord}
                disabled={isSavingWord}
                className="w-full bg-gray-900 hover:bg-gray-800 text-white font-bold py-3.5 rounded-xl shadow-md transition-all active:scale-[0.98] flex justify-center items-center gap-2 disabled:opacity-70"
              >
                {isSavingWord ? 'Збереження...' : <><span className="text-xl">+</span> Додати в мій словник</>}
              </button>
            )}
          </div>
        )}
        
        {selectedWordInfo && (
          <div className="absolute inset-0 bg-black/10 z-40" onClick={() => setSelectedWordInfo(null)}></div>
        )}
      </div>
    );
  }

  const currentEx = exercises[currentExIndex];
  
  if (!currentEx) {
     return <div className="p-4 text-center mt-20">Немає доступних вправ. <button onClick={() => onComplete?.()} className="text-blue-500 mt-4 block mx-auto underline">Завершити</button></div>;
  }

  const currentProgress = currentExIndex + (isSuccessDelay ? 1 : 0);
  const progressPercent = (currentProgress / exercises.length) * 100;

  const checkAnswer = () => {
    let isCorrect = false;
    if (currentEx.exercise_type === 'fill_in_the_blank') {
      isCorrect = selectedAnswer === currentEx.correct_answer;
    } else if (currentEx.exercise_type === 'sentence_builder' || currentEx.exercise_type === 'listening') {
      isCorrect = builderWords.join(' ') === currentEx.correct_answer;
    }

    attemptRef.current += 1;

    if (isCorrect) {
      track('exercise_completed', {
        lesson_id: lessonId,
        exercise_id: currentEx.id,
        exercise_type: currentEx.exercise_type,
        success: true,
        attempt: attemptRef.current,
        duration_ms: Date.now() - exerciseStartRef.current,
      });
      attemptRef.current = 0;
      exerciseStartRef.current = Date.now();
      setIsError(false); setIsSuccessDelay(true); setComboCount(prev => prev + 1); 
      if (currentEx.exercise_type !== 'listening') speakCroatian(currentEx.correct_answer);
      
      setTimeout(() => {
        setIsSuccessDelay(false);
        if (currentExIndex + 1 < exercises.length) {
          setCurrentExIndex(prev => prev + 1); setSelectedAnswer(null); setBuilderWords([]);
        } else {
          onComplete?.(); // остання вправа — завершуємо урок
        }
      }, 1000); 
    } else {
      setIsError(true); setComboCount(0); setTimeout(() => setIsError(false), 800);
    }
  };

  return (
    <div className="max-w-md mx-auto p-4 flex flex-col h-full min-h-screen bg-[#F4F7F9]">
      <div className="flex items-center gap-4 mb-6 mt-2">
        <button onClick={() => setMode('dialogue')} className="text-gray-400 hover:text-gray-600 text-2xl font-bold p-1 -ml-1">✕</button>
        <div className="flex-1 bg-gray-200 rounded-full h-3.5 overflow-hidden"><div className="bg-emerald-500 h-full rounded-full transition-all duration-500 ease-out" style={{ width: `${progressPercent}%` }}></div></div>
        <span className="text-sm font-bold text-gray-500 min-w-[30px] text-right">{currentProgress}/{exercises.length}</span>
      </div>
      
      <div className="flex-1 flex flex-col justify-center mb-8">
        <div className="h-8 mb-2 flex justify-center">
          {comboCount > 1 && (<span className="animate-bounce bg-amber-100 text-amber-600 text-xs font-bold px-3 py-1.5 rounded-full shadow-sm border border-amber-200">🔥 {comboCount} правильних підряд!</span>)}
        </div>
        
        {currentEx.exercise_type === 'listening' ? (
          <div className="flex flex-col items-center justify-center py-8 animate-fade-in-up">
            <div className="relative group">
              <div className="absolute inset-0 bg-blue-400 rounded-full blur-xl opacity-40 group-hover:opacity-60 transition-opacity"></div>
              <button
                onClick={() => speakCroatian(currentEx.correct_answer)}
                className="relative w-28 h-28 bg-gradient-to-br from-blue-500 to-blue-700 rounded-full flex items-center justify-center text-white shadow-2xl hover:scale-105 active:scale-[0.98] transition-all z-10"
              >
                <svg width="48" height="48" viewBox="0 0 24 24" fill="currentColor" className="ml-2">
                  <polygon points="5 3 19 12 5 21 5 3"/>
                </svg>
              </button>
            </div>
            <p className="mt-8 text-slate-500 font-bold text-xs uppercase tracking-widest flex items-center gap-2">
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M12 2a3 3 0 0 0-3 3v7a3 3 0 0 0 6 0V5a3 3 0 0 0-3-3Z"/><path d="M19 10v2a7 7 0 0 1-14 0v-2"/><line x1="12" x2="12" y1="19" y2="22"/></svg>
              Прослухайте фразу
            </p>
          </div>
        ) : (
          <h3 className="text-xl font-bold text-gray-800 text-center mb-8 px-2 leading-relaxed">{currentEx.question_text}</h3>
        )}

        {currentEx.exercise_type === 'fill_in_the_blank' && (
          <div className="grid grid-cols-1 gap-3">
            {currentEx.options.map((opt, i) => (
              <button key={i} disabled={isSuccessDelay} onClick={() => setSelectedAnswer(opt)} className={`py-4 px-6 rounded-2xl font-semibold text-lg border-2 transition-all ${selectedAnswer === opt ? (isSuccessDelay ? 'border-emerald-500 bg-emerald-50 text-emerald-700' : 'border-blue-500 bg-blue-50 text-blue-700') : 'border-gray-200 bg-white text-gray-700 hover:border-blue-300'}`}>{opt}</button>
            ))}
          </div>
        )}

        {(currentEx.exercise_type === 'sentence_builder' || currentEx.exercise_type === 'listening') && (
          <div className="flex flex-col gap-6">
            <div className={`min-h-[80px] p-4 rounded-2xl border-2 flex flex-wrap gap-2 items-center transition-colors ${isError ? 'border-rose-400 bg-rose-50' : isSuccessDelay ? 'border-emerald-400 bg-emerald-50' : 'border-gray-200 bg-white'}`}>
              {builderWords.length === 0 && <span className="text-gray-400 text-sm italic">Натискайте слова нижче...</span>}
              {builderWords.map((word, i) => (<button key={i} disabled={isSuccessDelay} onClick={() => setBuilderWords(prev => prev.filter((_, index) => index !== i))} className="bg-blue-100 text-blue-800 px-4 py-2 rounded-xl font-medium shadow-sm hover:bg-rose-100 hover:text-rose-700">{word}</button>))}
            </div>
            <div className="flex flex-wrap gap-2 justify-center">
              {currentEx.options.map((word, i) => {
                const isUsed = builderWords.includes(word);
                return (<button key={i} disabled={isUsed || isSuccessDelay} onClick={() => setBuilderWords(prev => [...prev, word])} className={`px-4 py-2 rounded-xl font-medium border-2 transition-all ${isUsed ? 'bg-gray-100 border-gray-100 text-transparent pointer-events-none' : 'bg-white border-gray-200 text-gray-700 hover:border-blue-400 shadow-sm active:scale-[0.98]'}`}>{word}</button>);
              })}
            </div>
          </div>
        )}
      </div>

      <div className="mt-auto pt-4 border-t border-gray-100">
        <button onClick={checkAnswer} disabled={(currentEx.exercise_type === 'fill_in_the_blank' && !selectedAnswer) || ((currentEx.exercise_type === 'sentence_builder' || currentEx.exercise_type === 'listening') && builderWords.length === 0) || isSuccessDelay} className={`w-full font-bold py-4 rounded-2xl shadow-md transition-all active:scale-[0.98] text-lg ${isError ? 'bg-rose-500 hover:bg-rose-600 text-white' : isSuccessDelay ? 'bg-emerald-500 text-white' : 'bg-blue-600 hover:bg-blue-700 text-white disabled:opacity-50 disabled:bg-gray-300 disabled:text-gray-500 disabled:shadow-none'}`}>
          {isError ? 'Помилка 😢' : isSuccessDelay ? 'Правильно! 🎉' : 'Перевірити'}
        </button>
      </div>
    </div>
  );
}