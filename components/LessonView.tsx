'use client';

import React, { useState } from 'react';
import { useRouter } from 'next/navigation';
import { speakCroatian } from '@/utils/speech';

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
  options: string[]; // масив варіантів (JSON)
}

interface LessonViewProps {
  title: string;
  description?: string;
  lines: DialogueLine[];
  exercises?: Exercise[];
  onComplete: () => void;
}

export default function LessonView({ title, description, lines, exercises = [], onComplete }: LessonViewProps) {
  const router = useRouter(); // Додаємо роутер для кнопки "Назад"
  const [mode, setMode] = useState<'dialogue' | 'practice'>('dialogue');
  
  // Стейти для вправ
  const [currentExIndex, setCurrentExIndex] = useState(0);
  const [selectedAnswer, setSelectedAnswer] = useState<string | null>(null);
  const [builderWords, setBuilderWords] = useState<string[]>([]);
  
  // Стейти для анімацій та гейміфікації
  const [isError, setIsError] = useState(false);
  const [isSuccessDelay, setIsSuccessDelay] = useState(false);
  const [comboCount, setComboCount] = useState(0);

  // --- ЛОГІКА ДІАЛОГУ ---
  if (mode === 'dialogue') {
    return (
      <div className="max-w-md mx-auto p-4 flex flex-col h-full min-h-screen bg-gray-50">
        
        {/* --- НОВИЙ HEADER З КНОПКОЮ ЗАКРИТТЯ --- */}
        <div className="flex items-start justify-between mb-6 mt-2">
          <button 
            onClick={() => router.push('/lessons')} 
            className="text-gray-400 hover:text-gray-600 text-2xl font-bold transition-colors active:scale-90 p-1 -ml-1"
            title="Повернутися до списку тем"
          >
            ✕
          </button>
          <div className="flex-1 text-center px-2">
            <h2 className="text-2xl font-bold text-gray-800 leading-tight">{title}</h2>
            {description && <p className="text-gray-500 text-sm mt-1">{description}</p>}
          </div>
          <div className="w-8"></div> {/* Порожній блок для симетрії заголовка */}
        </div>

        <div className="flex-1 space-y-4 mb-8 overflow-y-auto pb-4">
          {lines.map((line, index) => {
            const isUser = index % 2 === 0;
            return (
              <div key={line.id} className={`flex flex-col ${isUser ? 'items-end' : 'items-start'}`}>
                <span className="text-xs text-gray-400 mb-1 px-2">{line.speaker}</span>
                <div 
                  onClick={() => speakCroatian(line.hr_text)}
                  className={`max-w-[85%] rounded-2xl p-4 shadow-sm cursor-pointer hover:opacity-95 active:scale-[0.98] transition-all flex flex-col ${
                    isUser ? 'bg-blue-500 text-white rounded-tr-none' : 'bg-white text-gray-800 border border-gray-100 rounded-tl-none'
                  }`}
                >
                  <div className="flex items-start justify-between gap-3">
                    <p className="text-lg font-semibold mb-1">{line.hr_text}</p>
                    <span className={`shrink-0 text-lg opacity-70 ${isUser ? 'text-blue-200' : 'text-gray-400'}`}>🔊</span>
                  </div>
                  <p className={`text-sm ${isUser ? 'text-blue-100' : 'text-gray-500'}`}>
                    {line.ua_translation}
                  </p>
                </div>
              </div>
            );
          })}
        </div>

        <button 
          onClick={() => exercises.length > 0 ? setMode('practice') : onComplete()}
          className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 rounded-xl shadow-md transition-colors active:scale-95"
        >
          {exercises.length > 0 ? 'Продовжити до вправ ➔' : 'Завершити урок'}
        </button>
      </div>
    );
  }

  // --- ЛОГІКА ВПРАВ ---
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
      setIsError(false);
      setIsSuccessDelay(true);
      setComboCount(prev => prev + 1);
      speakCroatian(currentEx.correct_answer);
      
      setTimeout(() => {
        setIsSuccessDelay(false);
        if (currentExIndex + 1 < exercises.length) {
          setCurrentExIndex(prev => prev + 1);
          setSelectedAnswer(null);
          setBuilderWords([]);
        } else {
          onComplete(); 
        }
      }, 1000); 
    } else {
      setIsError(true);
      setComboCount(0);
      setTimeout(() => setIsError(false), 800);
    }
  };

  return (
    <div className="max-w-md mx-auto p-4 flex flex-col h-full min-h-screen bg-gray-50">
      
      {/* Прогрес-бар вправ */}
      <div className="flex items-center gap-4 mb-6 mt-2">
        <button 
          onClick={() => setMode('dialogue')} 
          className="text-gray-400 hover:text-gray-600 text-2xl font-bold transition-colors active:scale-90 p-1 -ml-1"
          title="Повернутися до діалогу"
        >
          ✕
        </button>

        <div className="flex-1 bg-gray-200 rounded-full h-3.5 overflow-hidden">
          <div 
            className="bg-green-500 h-full rounded-full transition-all duration-500 ease-out"
            style={{ width: `${progressPercent}%` }}
          ></div>
        </div>

        <span className="text-sm font-bold text-gray-500 min-w-[30px] text-right">
          {currentProgress}/{exercises.length}
        </span>
      </div>

      <div className="flex-1 flex flex-col justify-center mb-8">
        
        <div className="h-8 mb-2 flex justify-center">
          {comboCount > 1 && (
            <span className="animate-bounce bg-orange-100 text-orange-600 text-xs font-bold px-3 py-1.5 rounded-full shadow-sm border border-orange-200">
              🔥 {comboCount} правильних підряд!
            </span>
          )}
        </div>

        <h3 className="text-xl font-bold text-gray-800 text-center mb-8 px-2 leading-relaxed">
          {currentEx.question_text}
        </h3>

        {currentEx.exercise_type === 'fill_in_the_blank' && (
          <div className="grid grid-cols-1 gap-3">
            {currentEx.options.map((opt, i) => (
              <button
                key={i}
                disabled={isSuccessDelay}
                onClick={() => setSelectedAnswer(opt)}
                className={`py-4 px-6 rounded-2xl font-semibold text-lg border-2 transition-all ${
                  selectedAnswer === opt 
                    ? (isSuccessDelay ? 'border-green-500 bg-green-50 text-green-700' : 'border-blue-500 bg-blue-50 text-blue-700')
                    : 'border-gray-200 bg-white text-gray-700 hover:border-blue-300'
                }`}
              >
                {opt}
              </button>
            ))}
          </div>
        )}

        {currentEx.exercise_type === 'sentence_builder' && (
          <div className="flex flex-col gap-6">
            <div className={`min-h-[80px] p-4 rounded-2xl border-2 flex flex-wrap gap-2 items-center transition-colors ${
              isError ? 'border-red-400 bg-red-50' 
              : isSuccessDelay ? 'border-green-400 bg-green-50' 
              : 'border-gray-200 bg-white'
            }`}>
              {builderWords.length === 0 && <span className="text-gray-400 text-sm italic">Натискайте слова нижче...</span>}
              {builderWords.map((word, i) => (
                <button 
                  key={i} 
                  disabled={isSuccessDelay}
                  onClick={() => setBuilderWords(prev => prev.filter((_, index) => index !== i))}
                  className="bg-blue-100 text-blue-800 px-4 py-2 rounded-xl font-medium shadow-sm hover:bg-red-100 hover:text-red-700 transition-colors"
                >
                  {word}
                </button>
              ))}
            </div>

            <div className="flex flex-wrap gap-2 justify-center">
              {currentEx.options.map((word, i) => {
                const isUsed = builderWords.includes(word);
                return (
                  <button
                    key={i}
                    disabled={isUsed || isSuccessDelay}
                    onClick={() => setBuilderWords(prev => [...prev, word])}
                    className={`px-4 py-2 rounded-xl font-medium border-2 transition-all ${
                      isUsed ? 'bg-gray-100 border-gray-100 text-transparent pointer-events-none' : 'bg-white border-gray-200 text-gray-700 hover:border-blue-400 shadow-sm active:scale-95'
                    }`}
                  >
                    {word}
                  </button>
                );
              })}
            </div>
          </div>
        )}
      </div>

      <div className="mt-auto pt-4 border-t border-gray-100">
        <button 
          onClick={checkAnswer}
          disabled={
            (currentEx.exercise_type === 'fill_in_the_blank' && !selectedAnswer) || 
            (currentEx.exercise_type === 'sentence_builder' && builderWords.length === 0) ||
            isSuccessDelay
          }
          className={`w-full font-bold py-4 rounded-2xl shadow-md transition-all active:scale-95 text-lg ${
            isError ? 'bg-red-500 hover:bg-red-600 text-white' 
            : isSuccessDelay ? 'bg-green-500 text-white'
            : 'bg-blue-600 hover:bg-blue-700 text-white disabled:opacity-50 disabled:bg-gray-300 disabled:text-gray-500 disabled:shadow-none'
          }`}
        >
          {isError ? 'Помилка 😢' : isSuccessDelay ? 'Правильно! 🎉' : 'Перевірити'}
        </button>
      </div>
    </div>
  );
}