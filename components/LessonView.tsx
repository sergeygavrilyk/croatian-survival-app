'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import { speakCroatian } from '@/utils/speech';
import { createClient } from '@/utils/supabase/client';

export interface DialogueLine {
  id: string;
  speaker: string;
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
  topicWords?: VocabularyItem[]; // Додано пропс
  onComplete: () => void;
}

export default function LessonView({ title, description, lines, exercises = [], topicWords = [], onComplete }: LessonViewProps) {
  const router = useRouter();
  const supabase = createClient();
  
  const [mode, setMode] = useState<'dialogue' | 'roleplay_setup' | 'roleplay' | 'practice'>('dialogue');
  
  // Стейти для рольової гри
  const [selectedRole, setSelectedRole] = useState<string | null>(null);
  const [currentStep, setCurrentStep] = useState(0);
  const chatEndRef = useRef<HTMLDivElement>(null);

  // Стейти для вправ
  const [currentExIndex, setCurrentExIndex] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState<string | null>(null);
  const [builderWords, setBuilderWords] = useState<string[]>([]);
  const [isError, setIsError] = useState(false);
  const [isSuccessDelay, setIsSuccessDelay] = useState(false);
  const [comboCount, setComboCount] = useState(0);

  // --- СТЕЙТИ ДЛЯ CLICK-TO-SAVE ---
  const [selectedWordInfo, setSelectedWordInfo] = useState<VocabularyItem | null>(null);
  const [savedWordIds, setSavedWordIds] = useState<Set<string>>(new Set());
  const [isSavingWord, setIsSavingWord] = useState(false);

  const uniqueSpeakers = Array.from(new Set(lines.map((l) => l.speaker)));

  // --- ЛОГІКА РОЛЬОВОЇ ГРИ ---
  const startRoleplay = (role: string) => {
    setSelectedRole(role);
    setCurrentStep(0);
    setMode('roleplay');
    if (lines[0].speaker !== role) speakCroatian(lines[0].hr_text);
  };

  const nextRoleplayStep = () => {
    const next = currentStep + 1;
    setCurrentStep(next);
    if (next < lines.length && lines[next].speaker !== selectedRole) speakCroatian(lines[next].hr_text);
  };

  useEffect(() => {
    if (mode === 'roleplay') chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [currentStep, mode]);

  // --- ЛОГІКА ЗБЕРЕЖЕННЯ СЛОВА В SRS ---
  const handleSaveWord = async () => {
    if (!selectedWordInfo) return;
    setIsSavingWord(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        // Записуємо слово у тренажер на СЬОГОДНІ, щоб користувач міг одразу його потренувати
        await supabase.from('user_progress').upsert({
          user_id: user.id,
          vocabulary_id: selectedWordInfo.id,
          interval_days: 0, // 0 днів, бо це нове слово
          ease_factor: 2.5,
          next_review_date: new Date().toISOString() // NOW (сьогодні)
        }, { onConflict: 'user_id, vocabulary_id' });
        
        // Оновлюємо стейт, щоб показати зелену галочку
        setSavedWordIds(prev => new Set(prev).add(selectedWordInfo.id));
      }
    } catch (e) {
      console.error(e);
    } finally {
      setIsSavingWord(false);
    }
  };

  // РОЗУМНИЙ ПАРСЕР РЕЧЕНЬ
  const findVocabMatch = (word: string) => {
    const cleanWord = word.replace(/[^\p{L}]/gu, '').toLowerCase();
    if (!cleanWord || cleanWord.length < 2) return null;
    
    return topicWords.find(v => {
      const vText = v.hr_text.toLowerCase();
      if (vText === cleanWord) return true;
      // Враховуємо хорватські закінчення (-a, -u, -om) для слів довших за 3 літери
      if (cleanWord.length > 3 && vText.length > 3) {
        const root = vText.substring(0, vText.length - 1);
        if (cleanWord.startsWith(root)) return true;
      }
      return false;
    });
  };

  const renderInteractiveText = (text: string, isUserBubble: boolean) => {
    // Розбиваємо текст на слова, зберігаючи пробіли та пунктуацію
    const parts = text.split(/(\s+)/);
    
    return parts.map((chunk, i) => {
      if (!chunk.trim()) return <span key={i}>{chunk}</span>; // Це пробіл
      
      const match = findVocabMatch(chunk);
      if (match) {
        return (
          <span 
            key={i} 
            onClick={(e) => { 
              e.stopPropagation(); // Щоб не спрацювало озвучення всієї репліки
              setSelectedWordInfo(match); 
              speakCroatian(match.hr_text); // Озвучуємо саме це слово
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

  if (mode === 'roleplay_setup') {
    return (
      <div className="max-w-md mx-auto p-6 flex flex-col h-full min-h-screen bg-gray-50 text-center justify-center">
        <button onClick={() => setMode('dialogue')} className="absolute top-6 left-6 text-gray-400 hover:text-gray-600 text-2xl font-bold">✕</button>
        <h2 className="text-2xl font-bold text-gray-800 mb-2">Оберіть вашу роль</h2>
        <p className="text-gray-500 mb-8">Симулятор розмови буде автоматично відповідати вам від імені іншого персонажа.</p>
        <div className="flex flex-col gap-4">
          {uniqueSpeakers.map(speaker => (
            <button key={speaker} onClick={() => startRoleplay(speaker)} className="bg-white border-2 border-purple-200 hover:border-purple-500 text-purple-700 font-bold py-5 rounded-2xl shadow-sm transition-all active:scale-95 text-lg">
              Я буду грати за: <span className="text-xl">«{speaker}»</span>
            </button>
          ))}
        </div>
      </div>
    );
  }

  if (mode === 'roleplay') {
    const visibleLines = lines.slice(0, currentStep + 1);
    const isFinished = currentStep >= lines.length;
    const currentLine = lines[currentStep];
    const isUserTurn = currentLine?.speaker === selectedRole;

    return (
      <div className="max-w-md mx-auto flex flex-col h-screen bg-gray-50 relative">
        <div className="bg-white px-4 py-4 shadow-sm z-10 flex items-center justify-between">
          <button onClick={() => setMode('dialogue')} className="text-gray-400 hover:text-gray-600 text-xl font-bold">✕</button>
          <div className="text-center flex-1">
            <h3 className="text-sm font-bold text-gray-800">Симулятор розмови</h3>
            <p className="text-xs text-purple-600 font-medium">Ваша роль: {selectedRole}</p>
          </div>
          <div className="w-6"></div>
        </div>

        <div className="flex-1 overflow-y-auto p-4 space-y-4 pb-24">
          {visibleLines.map((line) => {
            const isUser = line.speaker === selectedRole;
            return (
              <div key={line.id} className={`flex flex-col ${isUser ? 'items-end' : 'items-start'} animate-fade-in-up`}>
                <span className="text-[10px] text-gray-400 mb-1 px-2 uppercase tracking-wider">{line.speaker}</span>
                <div onClick={() => speakCroatian(line.hr_text)} className={`max-w-[85%] rounded-2xl p-4 shadow-sm cursor-pointer transition-all ${isUser ? 'bg-purple-600 text-white rounded-tr-none' : 'bg-white text-gray-800 border border-gray-100 rounded-tl-none'}`}>
                  <p className="text-lg font-semibold mb-1">{line.hr_text}</p>
                  <p className={`text-sm ${isUser ? 'text-purple-200' : 'text-gray-500'}`}>{line.ua_translation}</p>
                </div>
              </div>
            );
          })}
          <div ref={chatEndRef} />
        </div>

        <div className="absolute bottom-0 w-full bg-white border-t border-gray-100 p-4 shadow-[0_-10px_20px_-5px_rgba(0,0,0,0.05)]">
          {isFinished ? (
            <button onClick={() => setMode('dialogue')} className="w-full bg-purple-600 hover:bg-purple-700 text-white font-bold py-4 rounded-xl shadow-md transition-all active:scale-95">Завершити симуляцію 🎉</button>
          ) : isUserTurn ? (
            <div className="flex flex-col gap-3">
              <div className="flex items-center gap-2 text-green-600 font-bold justify-center text-sm"><span className="text-xl animate-pulse">🎙</span> Ваша черга! Прочитайте вголос</div>
              <button onClick={nextRoleplayStep} className="w-full bg-green-500 hover:bg-green-600 text-white font-bold py-3.5 rounded-xl shadow-md transition-all active:scale-95">Продовжити ➔</button>
            </div>
          ) : (
             <div className="flex flex-col gap-3">
              <div className="flex items-center gap-2 text-gray-400 font-medium justify-center text-sm"><span className="animate-pulse">🎧</span> Співрозмовник говорить...</div>
              <button onClick={nextRoleplayStep} className="w-full bg-gray-100 hover:bg-gray-200 text-gray-700 font-bold py-3.5 rounded-xl transition-all active:scale-95">Далі ➔</button>
            </div>
          )}
        </div>
      </div>
    );
  }

  // Звичайний діалог із CLICK-TO-SAVE
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
                <span className="text-[10px] font-bold text-gray-400 mb-1 px-2 uppercase tracking-widest">{line.speaker}</span>
                <div 
                  onClick={() => speakCroatian(line.hr_text)}
                  className={`max-w-[85%] rounded-[1.5rem] p-4 shadow-sm cursor-pointer hover:opacity-95 active:scale-[0.98] transition-all flex flex-col ${
                    isUser ? 'bg-blue-600 text-white rounded-tr-none' : 'bg-white text-gray-800 border border-gray-100 rounded-tl-none'
                  }`}
                >
                  <div className="flex items-start justify-between gap-3">
                    {/* ТУТ ПРАЦЮЄ ІНТЕРАКТИВНИЙ ТЕКСТ */}
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
          <button onClick={() => setMode('roleplay_setup')} className="w-full bg-purple-100 text-purple-700 hover:bg-purple-200 font-bold py-3.5 rounded-2xl shadow-sm transition-colors active:scale-95 flex justify-center items-center gap-2">
            <span>🎭</span> Симулятор розмови
          </button>
          <button onClick={() => exercises.length > 0 ? setMode('practice') : onComplete()} className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 rounded-2xl shadow-md transition-colors active:scale-95">
            {exercises.length > 0 ? 'Перейти до вправ ➔' : 'Завершити урок'}
          </button>
        </div>

        {/* СПЛИВАЮЧЕ ВІКНО СЛОВНИКА (BOTTOM SHEET) */}
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
              <div className="w-full bg-green-50 text-green-600 font-bold py-3.5 rounded-xl flex justify-center items-center gap-2">
                <span>✓</span> Збережено в тренажер
              </div>
            ) : (
              <button 
                onClick={handleSaveWord}
                disabled={isSavingWord}
                className="w-full bg-gray-900 hover:bg-gray-800 text-white font-bold py-3.5 rounded-xl shadow-md transition-all active:scale-95 flex justify-center items-center gap-2 disabled:opacity-70"
              >
                {isSavingWord ? 'Збереження...' : <><span className="text-xl">+</span> Додати в мій словник</>}
              </button>
            )}
          </div>
        )}
        
        {/* Затемнення фону при відкритому словнику */}
        {selectedWordInfo && (
          <div className="absolute inset-0 bg-black/10 z-40" onClick={() => setSelectedWordInfo(null)}></div>
        )}
      </div>
    );
  }

  // --- ЕКРАН ВПРАВ (Залишається без змін) ---
  const currentEx = exercises[currentExIndex];
  const currentProgress = currentExIndex + (isSuccessDelay ? 1 : 0);
  const progressPercent = (currentProgress / exercises.length) * 100;

  const checkAnswer = () => {
    let isCorrect = false;
    if (currentEx.exercise_type === 'fill_in_the_blank') {
      isCorrect = selectedAnswer === currentEx.correct_answer;
    } else if (currentEx.exercise_type === 'sentence_builder') {
      isCorrect = builderWords.join(' ') === currentEx.correct_answer;
    }

    if (isCorrect) {
      setIsError(false); setIsSuccessDelay(true); setComboCount(prev => prev + 1); speakCroatian(currentEx.correct_answer);
      setTimeout(() => {
        setIsSuccessDelay(false);
        if (currentExIndex + 1 < exercises.length) {
          setCurrentExIndex(prev => prev + 1); setSelectedAnswer(null); setBuilderWords([]);
        } else {
          onComplete(); 
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
        <div className="flex-1 bg-gray-200 rounded-full h-3.5 overflow-hidden"><div className="bg-green-500 h-full rounded-full transition-all duration-500 ease-out" style={{ width: `${progressPercent}%` }}></div></div>
        <span className="text-sm font-bold text-gray-500 min-w-[30px] text-right">{currentProgress}/{exercises.length}</span>
      </div>
      <div className="flex-1 flex flex-col justify-center mb-8">
        <div className="h-8 mb-2 flex justify-center">
          {comboCount > 1 && (<span className="animate-bounce bg-orange-100 text-orange-600 text-xs font-bold px-3 py-1.5 rounded-full shadow-sm border border-orange-200">🔥 {comboCount} правильних підряд!</span>)}
        </div>
        <h3 className="text-xl font-bold text-gray-800 text-center mb-8 px-2 leading-relaxed">{currentEx.question_text}</h3>
        {currentEx.exercise_type === 'fill_in_the_blank' && (
          <div className="grid grid-cols-1 gap-3">
            {currentEx.options.map((opt, i) => (
              <button key={i} disabled={isSuccessDelay} onClick={() => setSelectedAnswer(opt)} className={`py-4 px-6 rounded-2xl font-semibold text-lg border-2 transition-all ${selectedAnswer === opt ? (isSuccessDelay ? 'border-green-500 bg-green-50 text-green-700' : 'border-blue-500 bg-blue-50 text-blue-700') : 'border-gray-200 bg-white text-gray-700 hover:border-blue-300'}`}>{opt}</button>
            ))}
          </div>
        )}
        {currentEx.exercise_type === 'sentence_builder' && (
          <div className="flex flex-col gap-6">
            <div className={`min-h-[80px] p-4 rounded-2xl border-2 flex flex-wrap gap-2 items-center transition-colors ${isError ? 'border-red-400 bg-red-50' : isSuccessDelay ? 'border-green-400 bg-green-50' : 'border-gray-200 bg-white'}`}>
              {builderWords.length === 0 && <span className="text-gray-400 text-sm italic">Натискайте слова нижче...</span>}
              {builderWords.map((word, i) => (<button key={i} disabled={isSuccessDelay} onClick={() => setBuilderWords(prev => prev.filter((_, index) => index !== i))} className="bg-blue-100 text-blue-800 px-4 py-2 rounded-xl font-medium shadow-sm hover:bg-red-100 hover:text-red-700">{word}</button>))}
            </div>
            <div className="flex flex-wrap gap-2 justify-center">
              {currentEx.options.map((word, i) => {
                const isUsed = builderWords.includes(word);
                return (<button key={i} disabled={isUsed || isSuccessDelay} onClick={() => setBuilderWords(prev => [...prev, word])} className={`px-4 py-2 rounded-xl font-medium border-2 transition-all ${isUsed ? 'bg-gray-100 border-gray-100 text-transparent pointer-events-none' : 'bg-white border-gray-200 text-gray-700 hover:border-blue-400 shadow-sm active:scale-95'}`}>{word}</button>);
              })}
            </div>
          </div>
        )}
      </div>
      <div className="mt-auto pt-4 border-t border-gray-100">
        <button onClick={checkAnswer} disabled={(currentEx.exercise_type === 'fill_in_the_blank' && !selectedAnswer) || (currentEx.exercise_type === 'sentence_builder' && builderWords.length === 0) || isSuccessDelay} className={`w-full font-bold py-4 rounded-2xl shadow-md transition-all active:scale-95 text-lg ${isError ? 'bg-red-500 hover:bg-red-600 text-white' : isSuccessDelay ? 'bg-green-500 text-white' : 'bg-blue-600 hover:bg-blue-700 text-white disabled:opacity-50 disabled:bg-gray-300 disabled:text-gray-500 disabled:shadow-none'}`}>
          {isError ? 'Помилка 😢' : isSuccessDelay ? 'Правильно! 🎉' : 'Перевірити'}
        </button>
      </div>
    </div>
  );
}