'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import FlashcardTrainer, { Flashcard } from '@/components/FlashcardTrainer';
import { createClient } from '@/utils/supabase/client';
import { rateFlashcard } from '@/app/actions/srs'; // Наша нова логіка SM-2

export default function TrainerPage() {
  const [cards, setCards] = useState<Flashcard[]>([]);
  const [loading, setLoading] = useState(true);
  
  const supabase = createClient();
  const router = useRouter();

  useEffect(() => {
    async function fetchCardsToReview() {
      try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return; // Middleware і так захищає роут, але робимо перевірку

        const now = new Date().toISOString();

        // 1. Шукаємо картки, які час повторювати на сьогодні
        const { data: progressData, error: progressError } = await supabase
          .from('user_progress')
          .select('vocabulary_id')
          .eq('user_id', user.id)
          .lte('next_review_date', now);

        if (progressError) throw progressError;

        let vocabIds = progressData ? progressData.map(p => p.vocabulary_id) : [];
        let vocabData = null;

        // 2. Якщо є що повторювати — завантажуємо ці слова
        if (vocabIds.length > 0) {
          const { data, error } = await supabase
            .from('vocabulary')
            .select('*')
            .in('id', vocabIds);
            
          if (error) throw error;
          vocabData = data;
        } 
        // 3. Якщо на сьогодні повторень немає — даємо нові слова
        else {
          const { data, error } = await supabase
            .from('vocabulary')
            .select('*')
            .limit(10);
            
          if (error) throw error;
          vocabData = data;
        }

        // 4. Форматуємо отримані дані під інтерфейс компонента Flashcard
        if (vocabData) {
          const formattedCards: Flashcard[] = vocabData.map((item: any) => ({
            id: String(item.id),
            hr_text: item.hr_text || '',
            ua_translation: item.ua_translation || '',
            phonetic_note: item.phonetic_note || '',
          }));
          setCards(formattedCards);
        }
      } catch (err) {
        console.error('Помилка завантаження тренажера:', err);
      } finally {
        setLoading(false);
      }
    }

    fetchCardsToReview();
  }, [supabase]);

  // Викликаємо Server Action для безпечного розрахунку інтервалів
  const handleRateCard = async (cardId: string, rating: number) => {
    try {
      const result = await rateFlashcard(cardId, rating);
      console.log(`Прогрес збережено. Наступний показ через ${result.intervalDays} днів.`);
    } catch (error) {
      console.error('Помилка при збереженні прогресу:', error);
    }
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
      onFinishSession={() => router.push('/lessons')} 
      onRateCard={handleRateCard} 
    />
  );
}