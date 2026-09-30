'use client';

import React, { useState } from 'react';

export interface Flashcard {
  id: string;
  hr_text: string;
  ua_translation: string;
  phonetic_note?: string;
}

interface FlashcardTrainerProps {
  cards: Flashcard[];
  onFinishSession: () => void;
  // Функція для запису результату в Supabase: 1 - Складно, 2 - Добре, 3 - Легко
  onRateCard: (cardId: string, rating: number) => void; 
}

export default function FlashcardTrainer({ cards, onFinishSession, onRateCard }: FlashcardTrainerProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isFlipped, setIsFlipped] = useState(false);

  if (cards.length === 0 || currentIndex >= cards.length) {
    return (
      <div className="max-w-md mx-auto p-6 flex flex-col items-center justify-center min-h-screen bg-gray-50 text-center">
        <div className="text-5xl mb-4">🎉</div>
        <h2 className="text-2xl font-bold text-gray-800 mb-2">Тренування завершено!</h2>
        <p className="text-gray-500 mb-8">Ви пройшли всі картки на сьогодні.</p>
        <button 
          onClick={onFinishSession}
          className="bg-blue-500 text-white px-6 py-3 rounded-xl font-semibold shadow-md w-full"
        >
          Повернутися на головну
        </button>
      </div>
    );
  }

  const currentCard = cards[currentIndex];

  const handleRate = (rating: number) => {
    onRateCard(currentCard.id, rating);
    setIsFlipped(false);
    setCurrentIndex((prev) => prev + 1);
  };

  return (
    <div className="max-w-md mx-auto p-4 flex flex-col min-h-screen bg-gray-50">
      <div className="flex justify-between items-center mb-6 text-gray-500 text-sm font-medium">
        <span>Тренажер слів</span>
        <span>{currentIndex + 1} / {cards.length}</span>
      </div>

      <div className="flex-1 flex flex-col justify-center mb-8 perspective-1000">
        <div 
          onClick={() => !isFlipped && setIsFlipped(true)}
          className={`relative w-full min-h-[300px] bg-white rounded-3xl shadow-lg border border-gray-100 p-8 flex flex-col items-center justify-center text-center cursor-pointer transition-all duration-300 ${isFlipped ? 'shadow-xl' : 'hover:-translate-y-1'}`}
        >
          {/* Хорватська (Лицьова сторона) */}
          <h3 className="text-3xl font-bold text-gray-800 mb-4">{currentCard.hr_text}</h3>
          
          {/* Підказка вимови */}
          {currentCard.phonetic_note && (
             <p className="text-gray-400 text-sm mb-4">[{currentCard.phonetic_note}]</p>
          )}

          {/* Українська (Зворотна сторона) */}
          {isFlipped ? (
            <div className="mt-6 pt-6 border-t border-gray-100 w-full animate-fade-in">
              <p className="text-xl text-blue-600 font-medium">{currentCard.ua_translation}</p>
            </div>
          ) : (
            <div className="mt-auto pt-8 text-gray-300 text-sm animate-pulse">
              Натисніть, щоб побачити переклад
            </div>
          )}
        </div>
      </div>

      {/* Кнопки оцінки (з'являються тільки після розкриття картки) */}
      <div className={`grid grid-cols-3 gap-3 transition-opacity duration-300 ${isFlipped ? 'opacity-100' : 'opacity-0 pointer-events-none'}`}>
        <button 
          onClick={() => handleRate(1)}
          className="flex flex-col items-center bg-red-100 text-red-700 py-3 rounded-xl active:bg-red-200"
        >
          <span className="font-bold">Складно</span>
          <span className="text-xs opacity-70">Знову</span>
        </button>
        <button 
          onClick={() => handleRate(2)}
          className="flex flex-col items-center bg-yellow-100 text-yellow-700 py-3 rounded-xl active:bg-yellow-200"
        >
          <span className="font-bold">Добре</span>
          <span className="text-xs opacity-70">Завтра</span>
        </button>
        <button 
          onClick={() => handleRate(3)}
          className="flex flex-col items-center bg-green-100 text-green-700 py-3 rounded-xl active:bg-green-200"
        >
          <span className="font-bold">Легко</span>
          <span className="text-xs opacity-70">4 дні</span>
        </button>
      </div>
    </div>
  );
}