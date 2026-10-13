'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence, useMotionValue, useTransform, type PanInfo } from 'framer-motion';
import { speakCroatian } from '@/utils/speech';

export interface Flashcard {
  id: string;
  hr_text: string;
  ua_translation: string;
  phonetic_note?: string;
  audio_url?: string;
  /** Приклад речення хорватською (показується після перевертання картки) */
  example?: string;
}

interface FlashcardTrainerProps {
  cards: Flashcard[];
  onFinishSession: () => void;
  onRateCard: (cardId: string, rating: number) => void;
}

type SwipeDirection = 'left' | 'right';

/** Поріг свайпу в пікселях, після якого картка зараховується */
const SWIPE_THRESHOLD = 100;

/** Куди відлітає картка, що йде (custom з AnimatePresence — напрямок останнього свайпу) */
const cardVariants = {
  enter: { scale: 0.95, opacity: 0, y: 20, x: 0 },
  center: { scale: 1, opacity: 1, y: 0 },
  exit: (direction: SwipeDirection) => ({
    x: direction === 'right' ? 420 : -420,
    rotate: direction === 'right' ? 15 : -15,
    opacity: 0,
    transition: { duration: 0.25 },
  }),
};

interface SwipeCardProps {
  card: Flashcard;
  isFlipped: boolean;
  onFlip: () => void;
  onSwipe: (direction: SwipeDirection) => void;
}

/**
 * Одна картка зі свайпом. У кожної картки — власна позиція (MotionValue):
 * раніше позиція була спільною для всіх карток, і анімація «відльоту» старої картки
 * зсувала вбік нову (на iPhone картка «западала» вліво й лишалася червоною).
 */
function SwipeCard({ card, isFlipped, onFlip, onSwipe }: SwipeCardProps) {
  const x = useMotionValue(0);
  const rotate = useTransform(x, [-200, 200], [-15, 15]);
  const background = useTransform(
    x,
    [-150, 0, 150],
    ['#fee2e2', '#ffffff', '#dcfce3'] // Червоний (вліво) ← білий → зелений (вправо)
  );
  // Прозорість позначок «Знаю» / «Вчити» під час потягування
  const opacityRight = useTransform(x, [0, SWIPE_THRESHOLD], [0, 1]);
  const opacityLeft = useTransform(x, [0, -SWIPE_THRESHOLD], [0, 1]);

  const handleDragEnd = (_event: MouseEvent | TouchEvent | PointerEvent, info: PanInfo) => {
    if (info.offset.x > SWIPE_THRESHOLD) onSwipe('right');
    else if (info.offset.x < -SWIPE_THRESHOLD) onSwipe('left');
    // інакше картка сама повертається в центр (dragConstraints)
  };

  return (
    <motion.div
      style={{ x, rotate, backgroundColor: background }}
      drag="x"
      dragConstraints={{ left: 0, right: 0 }}
      dragElastic={0.9}
      onDragEnd={handleDragEnd}
      variants={cardVariants}
      initial="enter"
      animate="center"
      exit="exit"
      whileDrag={{ scale: 1.03, cursor: 'grabbing' }}
      onTap={onFlip}
      className="absolute w-full max-w-[340px] aspect-[3/4] rounded-[2rem] shadow-md border border-gray-100 flex flex-col items-center justify-center p-8 cursor-grab touch-pan-y select-none z-20"
    >
      {/* Позначки свайпу (з'являються під час потягування) */}
      <motion.div style={{ opacity: opacityRight }} aria-hidden="true" className="absolute top-8 left-8 border-4 border-green-500 text-green-500 font-black text-2xl uppercase tracking-widest px-4 py-1 rounded-xl rotate-[-15deg]">
        Знаю
      </motion.div>
      <motion.div style={{ opacity: opacityLeft }} aria-hidden="true" className="absolute top-8 right-8 border-4 border-red-500 text-red-500 font-black text-2xl uppercase tracking-widest px-4 py-1 rounded-xl rotate-[15deg]">
        Вчити
      </motion.div>

      {/* Контент картки */}
      <div className="text-center w-full flex flex-col items-center">
        <span className="text-sm font-bold text-gray-400 uppercase tracking-widest mb-4 block">
          {card.phonetic_note || 'Слово'}
        </span>

        <h2 lang="hr" className="text-4xl font-black text-gray-900 mb-6 drop-shadow-sm break-words w-full">
          {card.hr_text}
        </h2>

        {/* Кнопка аудіо */}
        <button
          type="button"
          onPointerDownCapture={(e) => e.stopPropagation()}
          onClick={(e) => {
            e.stopPropagation(); // щоб не перегорталася картка
            speakCroatian(card.hr_text);
          }}
          aria-label="Прослухати слово"
          className={`mb-6 bg-blue-50 text-blue-600 w-12 h-12 rounded-full flex items-center justify-center hover:bg-blue-100 transition shadow-sm ${isFlipped ? 'opacity-0 h-0 mb-0 pointer-events-none' : 'opacity-100'}`}
        >
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" strokeLinecap="round" strokeLinejoin="round"><polygon points="11 5 6 9 2 9 2 15 6 15 11 19 11 5"/><path d="M15.54 8.46a5 5 0 0 1 0 7.07"/><path d="M19.07 4.93a10 10 0 0 1 0 14.14"/></svg>
        </button>

        {/* Переклад з'являється по тапу на картку */}
        <div className={`transition-all duration-300 w-full ${isFlipped ? 'opacity-100 translate-y-0' : 'opacity-0 translate-y-4 pointer-events-none h-0'}`}>
          <div className="w-12 h-1 bg-gray-200 mx-auto rounded-full mb-6"></div>
          <p className="text-2xl font-bold text-blue-600">
            {card.ua_translation}
          </p>
          {card.example && (
            <button
              type="button"
              onPointerDownCapture={(e) => e.stopPropagation()}
              onClick={(e) => {
                e.stopPropagation(); // не перегортати картку
                speakCroatian(card.example!);
              }}
              className="mt-5 mx-auto max-w-full text-left flex items-start gap-2 text-gray-600 text-base leading-snug italic hover:text-blue-700"
              aria-label="Прослухати приклад"
            >
              <span aria-hidden="true" className="not-italic">🔊</span>
              <span lang="hr">{card.example}</span>
            </button>
          )}
        </div>
      </div>

      {/* Підказка знизу картки */}
      <p className="absolute bottom-6 text-gray-400 text-xs font-semibold uppercase tracking-widest flex items-center gap-2">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5" aria-hidden="true"><path d="M15 3h6v6M9 21H3v-6M21 3l-7 7M3 21l7-7"/></svg>
        Тап — переклад, свайп — відповідь
      </p>
    </motion.div>
  );
}

export default function FlashcardTrainer({ cards, onFinishSession, onRateCard }: FlashcardTrainerProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isFlipped, setIsFlipped] = useState(false);
  // Напрямок останнього свайпу — щоб стара картка відлітала в правильний бік
  const [direction, setDirection] = useState<SwipeDirection>('right');

  const totalCards = cards.length;
  const progressPercentage = totalCards === 0 ? 0 : Math.round((currentIndex / totalCards) * 100);

  // Екран завершення
  if (totalCards === 0 || currentIndex >= totalCards) {
    return (
      <div className="max-w-md mx-auto min-h-screen bg-[#F4F7F9] flex flex-col items-center justify-center p-6">
        <motion.div 
          initial={{ opacity: 0, scale: 0.9 }}
          animate={{ opacity: 1, scale: 1 }}
          className="text-center bg-white p-10 rounded-[2rem] shadow-xl border border-gray-100 w-full"
        >
          <div className="text-6xl mb-6">🎉</div>
          <h2 className="text-2xl font-black text-gray-900 mb-2">Тренування завершено!</h2>
          <p className="text-gray-500 font-medium mb-8">Ви пройшли всі картки на сьогодні.</p>
          <button 
            onClick={onFinishSession}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 rounded-2xl shadow-md transition-all active:scale-95"
          >
            Повернутися на головну
          </button>
        </motion.div>
      </div>
    );
  }

  const currentCard = cards[currentIndex];

  const handleSwipe = (swipe: SwipeDirection) => {
    // 1 — «Знаю» (вправо), 0 — «Не знаю» (вліво)
    onRateCard(currentCard.id, swipe === 'right' ? 1 : 0);
    setDirection(swipe);
    setIsFlipped(false);
    setCurrentIndex((prev) => prev + 1);
  };

  return (
    <div className="max-w-md mx-auto min-h-screen bg-[#F4F7F9] flex flex-col overflow-hidden relative">
      
      {/* 1. Header & Товстий Прогрес-бар */}
      <header className="pt-6 pb-4 px-6 z-10 flex flex-col gap-4">
        <div className="flex justify-between items-center">
          <button 
            onClick={onFinishSession} 
            className="w-10 h-10 bg-white border border-gray-200 rounded-full flex items-center justify-center text-gray-600 hover:text-blue-600 shadow-sm active:scale-95 transition-all"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round"><path d="M19 12H5M12 19l-7-7 7-7"/></svg>
          </button>
          
          <span className="text-gray-500 font-bold text-sm tracking-wide bg-white px-4 py-1 rounded-full shadow-sm border border-gray-100">
            {currentIndex + 1} / {totalCards}
          </span>
          <div className="w-10"></div> {/* Пустий блок для балансу flex */}
        </div>

        {/* Прогрес-бар з анімацією ширини */}
        <div className="h-3 w-full bg-gray-200 rounded-full overflow-hidden shadow-inner">
          <div 
            className="h-full bg-blue-600 rounded-full transition-all duration-500 ease-out relative"
            style={{ width: `${progressPercentage}%` }}
          >
            <div className="absolute top-0 left-0 right-0 h-1/2 bg-white/20 rounded-full"></div>
          </div>
        </div>
      </header>

      {/* 2. Зона карток (Tinder Swipe) */}
      <main className="flex-1 relative flex items-center justify-center px-4">
        <AnimatePresence initial={false} custom={direction}>
          <SwipeCard
            key={currentCard.id + ':' + currentIndex}
            card={currentCard}
            isFlipped={isFlipped}
            onFlip={() => setIsFlipped((f) => !f)}
            onSwipe={handleSwipe}
          />
        </AnimatePresence>
      </main>

      {/* 3. Опціональні кнопки управління (для тих, хто не любить або не може свайпати) */}
      <footer className="pb-12 px-8 flex justify-center gap-8 z-10">
        <button 
          type="button"
          aria-label="Не знаю — вчити ще"
          onClick={() => handleSwipe('left')}
          className="w-16 h-16 bg-white border-2 border-red-100 text-red-500 rounded-full shadow-lg flex flex-col items-center justify-center hover:bg-red-50 hover:border-red-200 active:scale-90 transition-all"
        >
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round"><path d="M18 6 6 18M6 6l12 12"/></svg>
        </button>
        <button 
          type="button"
          aria-label="Знаю"
          onClick={() => handleSwipe('right')}
          className="w-16 h-16 bg-white border-2 border-green-100 text-green-500 rounded-full shadow-lg flex flex-col items-center justify-center hover:bg-green-50 hover:border-green-200 active:scale-90 transition-all"
        >
          <svg width="24" height="24" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="3" strokeLinecap="round"><path d="M20 6 9 17l-5-5"/></svg>
        </button>
      </footer>
    </div>
  );
}