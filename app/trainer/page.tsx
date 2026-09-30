'use client';

import React, { useState, useEffect } from 'react';
import { createClient } from '@supabase/supabase-js';
import FlashcardTrainer, { Flashcard } from '@/components/FlashcardTrainer';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

export default function TrainerPage() {
  const [cards, setCards] = useState<Flashcard[]>([]);
  const [loading, setLoading] = useState(true);
  const [userId, setUserId] = useState<string | null>(null);

  useEffect(() => {
    async function initSessionAndFetchCards() {
      try {
        const { data: { session } } = await supabase.auth.getSession();
        
        if (!session?.user?.id) {
          // Завантажуємо всі колонки через зірочку, щоб уникнути помилок неіснуючих полів
          const { data: fallbackVocabulary, error: fallbackError } = await supabase
            .from('vocabulary')
            .select('*')
            .limit(10);
          
          if (fallbackError) {
            console.error('Помилка завантаження словника:', fallbackError.message);
          } else if (fallbackVocabulary) {
            const formattedFallback: Flashcard[] = fallbackVocabulary.map((item: any) => ({
              id: String(item.id || item.vocabulary_id || Math.random()),
              // Шукаємо хорватський текст у різних можливих варіантах назв колонок
              hr_text: item.phrase_hr || item.hr_text || item.word_hr || item.croatian || Object.values(item)[1] || '',
              // Шукаємо український переклад
              ua_translation: item.phrase_uk || item.ua_translation || item.word_uk || item.ukrainian || item.translation || Object.values(item)[2] || '',
              // Приклад або примітка
              phonetic_note: item.context_example || item.phonetic_note || item.example || '',
            }));
            setCards(formattedFallback);
          }
          setLoading(false);
          return;
        }

        const currentUserId = session.user.id;
        setUserId(currentUserId);

        const now = new Date().toISOString();

        const { data: progressData, error: progressError } = await supabase
          .from('user_progress')
          .select('vocabulary_id')
          .eq('user_id', currentUserId)
          .lte('next_review_date', now);

        if (progressError) {
          console.error('Помилка завантаження прогресу:', progressError.message);
          setLoading(false);
          return;
        }

        let vocabIds = progressData ? progressData.map(p => p.vocabulary_id) : [];

        if (vocabIds.length === 0) {
          const { data: fallbackVocabulary, error: fallbackError } = await supabase
            .from('vocabulary')
            .select('*')
            .limit(10);
          
          if (fallbackError) {
            console.error('Помилка завантаження словника:', fallbackError.message);
          } else if (fallbackVocabulary) {
            const formattedFallback: Flashcard[] = fallbackVocabulary.map((item: any) => ({
              id: String(item.id || item.vocabulary_id || Math.random()),
              hr_text: item.phrase_hr || item.hr_text || item.word_hr || item.croatian || Object.values(item)[1] || '',
              ua_translation: item.phrase_uk || item.ua_translation || item.word_uk || item.ukrainian || item.translation || Object.values(item)[2] || '',
              phonetic_note: item.context_example || item.phonetic_note || item.example || '',
            }));
            setCards(formattedFallback);
          }
        } else {
          const { data: vocabData, error: vocabError } = await supabase
            .from('vocabulary')
            .select('*')
            .in('id', vocabIds);

          if (vocabError) {
            console.error('Помилка завантаження слів:', vocabError.message);
          } else if (vocabData) {
            const formattedCards: Flashcard[] = vocabData.map((item: any) => ({
              id: String(item.id || item.vocabulary_id || Math.random()),
              hr_text: item.phrase_hr || item.hr_text || item.word_hr || item.croatian || Object.values(item)[1] || '',
              ua_translation: item.phrase_uk || item.ua_translation || item.word_uk || item.ukrainian || item.translation || Object.values(item)[2] || '',
              phonetic_note: item.context_example || item.phonetic_note || item.example || '',
            }));
            setCards(formattedCards);
          }
        }
      } catch (err) {
        console.error('Помилка ініціалізації:', err);
      } finally {
        setLoading(false);
      }
    }

    initSessionAndFetchCards();
  }, []);

  const handleRateCard = async (cardId: string, rating: number) => {
    if (!userId) return;

    try {
      const { data: currentProgress } = await supabase
        .from('user_progress')
        .select('*')
        .eq('user_id', userId)
        .eq('vocabulary_id', cardId)
        .single();

      let interval = currentProgress?.interval_days || 0;
      let ease = currentProgress?.ease_factor || 2.5;

      if (rating === 1) {
        interval = 0;
        ease = Math.max(1.3, ease - 0.2);
      } else if (rating === 2) {
        interval = interval === 0 ? 1 : Math.round(interval * ease);
      } else if (rating === 3) {
        interval = interval === 0 ? 4 : Math.round(interval * ease * 1.5);
        ease = ease + 0.15;
      }

      const nextReviewDate = new Date();
      nextReviewDate.setDate(nextReviewDate.getDate() + interval);

      await supabase
        .from('user_progress')
        .upsert(
          {
            user_id: userId,
            vocabulary_id: Number(cardId),
            interval_days: interval,
            ease_factor: ease,
            next_review_date: nextReviewDate.toISOString(),
          },
          { onConflict: 'user_id, vocabulary_id' }
        );
    } catch (err) {
      console.error('Помилка оновлення прогресу в БД:', err);
    }
  };

  const handleFinishSession = () => {
    window.location.href = '/';
  };

  if (loading) {
    return (
      <div className="flex justify-center items-center min-h-screen bg-gray-50 text-gray-500">
        Завантаження тренажера...
      </div>
    );
  }

  return (
    <FlashcardTrainer
      cards={cards}
      onFinishSession={handleFinishSession}
      onRateCard={handleRateCard}
    />
  );
}