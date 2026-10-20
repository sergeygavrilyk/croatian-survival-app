'use client';

import React, { useState } from 'react';
import { motion, AnimatePresence, useMotionValue, useTransform, type PanInfo } from 'framer-motion';
import { Check, Eye, MoveHorizontal, RotateCcw } from 'lucide-react';
import type { WordTheme } from '@/lib/word-theme';
import AudioButton from '@/components/ui/AudioButton';
import Button, { buttonClasses } from '@/components/ui/Button';
import Hr from '@/components/ui/Hr';
import LevelBadge from '@/components/ui/LevelBadge';
import ProgressBar from '@/components/ui/ProgressBar';
import WordTile from '@/components/ui/WordTile';
import TrainerSessionDone from '@/components/TrainerSessionDone';

export interface Flashcard {
  id: string;
  hr_text: string;
  ua_translation: string;
  /** Частина мови українською («іменник») */
  phonetic_note?: string;
  audio_url?: string;
  /** Приклад речення хорватською (показується після перевертання картки) */
  example?: string;
  /** Рівень слова (A0 … B2) — колір плитки й бейджа */
  level?: string;
  /** Тема модуля, де слово трапляється в уроках (емодзі) */
  theme?: WordTheme | null;
}

interface FlashcardTrainerProps {
  cards: Flashcard[];
  onFinishSession: () => void;
  onRateCard: (cardId: string, rating: number) => void;
  /** «Ще слова» на екрані завершення */
  onRestart?: () => void;
}

type SwipeDirection = 'left' | 'right';

/** Поріг свайпу в пікселях, після якого картка зараховується */
const SWIPE_THRESHOLD = 100;

/** Куди відлітає картка, що йде (custom з AnimatePresence — напрямок останнього свайпу) */
const cardVariants = {
  enter: { scale: 0.96, opacity: 0, y: 16, x: 0 },
  center: { scale: 1, opacity: 1, y: 0 },
  exit: (direction: SwipeDirection) => ({
    x: direction === 'right' ? 420 : -420,
    rotate: direction === 'right' ? 12 : -12,
    opacity: 0,
    transition: { duration: 0.25 },
  }),
};

/** Не давати кнопкам усередині картки починати свайп чи перевертати картку */
const stop = {
  onPointerDownCapture: (e: React.PointerEvent) => e.stopPropagation(),
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
  const rotate = useTransform(x, [-200, 200], [-12, 12]);
  // «Не знаю» — нейтральний сірий (чесна відповідь, не помилка, DESIGN_SYSTEM §9.1), «Знаю» — зелений
  const background = useTransform(x, [-150, 0, 150], ['#f1f5f9', '#ffffff', '#ecfdf5']);
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
      whileDrag={{ scale: 1.02, cursor: 'grabbing' }}
      onTap={onFlip}
      className="relative flex min-h-[20rem] w-full max-w-sm cursor-grab touch-pan-y select-none flex-col rounded-hero border border-line p-6 shadow-sm [grid-area:1/1]"
    >
      {/* Позначки свайпу (з'являються під час потягування) */}
      <motion.span
        style={{ opacity: opacityRight }}
        aria-hidden="true"
        className="absolute top-6 left-6 z-10 -rotate-12 rounded-control border-2 border-success bg-surface px-3 py-1 font-heading text-h3 uppercase text-success-ink"
      >
        Знаю
      </motion.span>
      <motion.span
        style={{ opacity: opacityLeft }}
        aria-hidden="true"
        className="absolute top-6 right-6 z-10 rotate-12 rounded-control border-2 border-ink-subtle bg-surface px-3 py-1 font-heading text-h3 uppercase text-ink-muted"
      >
        Ще вчу
      </motion.span>

      {/* Тема й рівень слова */}
      <div className="flex items-center gap-3">
        <WordTile lemma={card.hr_text} level={card.level} theme={card.theme} />
        <div className="min-w-0 flex-1">
          {card.theme && <p className="truncate text-caption text-ink-subtle">{card.theme.title}</p>}
          {card.phonetic_note && <p className="truncate text-label font-normal text-ink-muted">{card.phonetic_note}</p>}
        </div>
        {card.level && <LevelBadge level={card.level} />}
      </div>

      {/* Слово */}
      <div className="flex flex-1 flex-col items-center justify-center gap-3 py-4 text-center">
        <Hr as="h2" className="w-full font-heading text-word break-words text-ink">
          {card.hr_text}
        </Hr>
        <span {...stop}>
          <AudioButton text={card.hr_text} label="Прослухати слово" className="size-12 bg-primary-soft" />
        </span>

        {isFlipped ? (
          <div className="mt-2 flex w-full animate-fade-in-up flex-col items-center gap-3 border-t border-line pt-5">
            <p className="font-heading text-h2 break-words text-primary-ink">{card.ua_translation}</p>
            {card.example && (
              <div className="flex max-w-full items-start gap-1 text-left" {...stop}>
                <Hr as="p" className="min-w-0 flex-1 pt-2.5 text-body italic text-ink-muted">
                  {card.example}
                </Hr>
                <AudioButton text={card.example} label="Прослухати приклад" />
              </div>
            )}
          </div>
        ) : (
          <button
            type="button"
            {...stop}
            onClick={(e) => {
              e.stopPropagation();
              onFlip();
            }}
            className={buttonClasses('tertiary', 'sm', 'mt-2')}
          >
            <Eye className="size-4" aria-hidden="true" />
            Показати переклад
          </button>
        )}
      </div>

      <p className="flex items-center justify-center gap-2 text-caption text-ink-subtle">
        <MoveHorizontal className="size-4" aria-hidden="true" />
        Свайп вправо — знаю, вліво — ще вчу
      </p>
    </motion.div>
  );
}

export default function FlashcardTrainer({ cards, onFinishSession, onRateCard, onRestart }: FlashcardTrainerProps) {
  const [currentIndex, setCurrentIndex] = useState(0);
  const [isFlipped, setIsFlipped] = useState(false);
  const [known, setKnown] = useState(0);
  // Напрямок останнього свайпу — щоб стара картка відлітала в правильний бік
  const [direction, setDirection] = useState<SwipeDirection>('right');

  const totalCards = cards.length;

  // Екран завершення
  if (totalCards === 0 || currentIndex >= totalCards) {
    return (
      <div className="px-5 pt-2">
        <TrainerSessionDone correct={known} total={totalCards} mode="recognize" onRestart={onRestart} onFinish={onFinishSession} />
      </div>
    );
  }

  const currentCard = cards[currentIndex];

  const handleSwipe = (swipe: SwipeDirection) => {
    // 1 — «Знаю» (вправо), 0 — «Не знаю» (вліво)
    onRateCard(currentCard.id, swipe === 'right' ? 1 : 0);
    if (swipe === 'right') setKnown((k) => k + 1);
    setDirection(swipe);
    setIsFlipped(false);
    setCurrentIndex((prev) => prev + 1);
  };

  return (
    <div className="mx-auto flex max-w-md flex-col gap-4 overflow-x-hidden px-5 pt-2 pb-6">
      {/* Прогрес сесії */}
      <div className="flex items-center gap-3">
        <ProgressBar value={currentIndex} max={totalCards} label="Прогрес тренування" className="flex-1" />
        <span className="font-heading text-label tabular-nums text-ink-muted">
          {currentIndex + 1} / {totalCards}
        </span>
      </div>

      {/* Зона карток: обидві картки (нова й та, що відлітає) — в одній клітинці сітки */}
      <div className="grid place-items-center">
        <AnimatePresence initial={false} custom={direction}>
          <SwipeCard
            key={currentCard.id + ':' + currentIndex}
            card={currentCard}
            isFlipped={isFlipped}
            onFlip={() => setIsFlipped((f) => !f)}
            onSwipe={handleSwipe}
          />
        </AnimatePresence>
      </div>

      {/* Кнопки — для тих, хто не любить або не може свайпати (DESIGN_SYSTEM §9.1) */}
      <div className="grid grid-cols-2 gap-3">
        <button
          type="button"
          onClick={() => handleSwipe('left')}
          className={buttonClasses('tertiary', 'md', 'border border-line bg-surface')}
        >
          <RotateCcw className="size-5" aria-hidden="true" />
          Не знаю
        </button>
        <Button variant="success" onClick={() => handleSwipe('right')} block>
          <Check className="size-5" aria-hidden="true" />
          Знаю
        </Button>
      </div>
    </div>
  );
}
