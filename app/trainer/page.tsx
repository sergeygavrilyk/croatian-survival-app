'use client';

import { useState, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import FlashcardTrainer, { Flashcard } from '@/components/FlashcardTrainer';
import { createClient } from '@/utils/supabase/client';
import { rateFlashcard } from '@/app/actions/srs';

export default function TrainerPage() {
  const [cards, setCards] = useState<Flashcard[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedLevel, setSelectedLevel] = useState<'A1' | 'A2' | 'B1'>('A1');
  
  const supabase = createClient();
  const router = useRouter();

  useEffect(() => {
    async function fetchCardsToReview() {
      setLoading(true);
      try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return;

        const now = new Date().toISOString();

        // 1. Спочатку шукаємо словацькі/хорватські картки користувача на повторення, що відповідають обраному рівню
        const { data: progressData, error: progressError } = await supabase
          .from('user_progress')
          .select('vocabulary_id')
          .eq('user_id', user.id)
          .lte('next_review_date', now);

        if (progressError) throw progressError;

        let vocabIds = progressData ? progressData.map(p => p.vocabulary_id) : [];
        let vocabData = null;

        if (vocabIds.length > 0) {
          // Завантажуємо картки на повторення з урахуванням обраного рівня
          const { data, error } = await supabase
            .from('vocabulary')
            .select('*')
            .in('id', vocabIds)
            .eq('level', selectedLevel);
            
          if (error) throw error;
          vocabData = data;
        } 

        // 2. Якщо на повторення нічого немає (або немає слів цього рівня на повторенні), 
        // беремо нові слова з урахуванням принципу Парето (сортування за frequency_rank)
        if (!vocabData || vocabData.length === 0) {
          const { data, error } = await supabase
            .from('vocabulary')
            .select('*')
            .eq('level', selectedLevel)
            .order('frequency_rank', { ascending: true }) // Найважливіші першими!
            .limit(10);
            
          if (error) throw error;
          vocabData = data;
        }

        // 3. Форматуємо для компонентів тренажера
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
  }, [supabase, selectedLevel]);

  const handleRateCard = async (cardId: string, rating: number) => {
    try {
      await rateFlashcard(cardId, rating);
    } catch (error) {
      console.error('Помилка при збереженні прогресу:', error);
    }
  };

  return (
    <div className="min-h-screen bg-gray-50 pb-12">
      {/* Панель вибору рівня для тренування */}
      <div className="max-w-md mx-auto pt-4 px-4 flex justify-center gap-2 mb-2">
        {(['A1', 'A2', 'B1'] as const).map((lvl) => (
          <button
            key={lvl}
            onClick={() => setSelectedLevel(lvl)}
            className={`px-4 py-1.5 rounded-full text-xs font-bold transition-all shadow-sm ${
              selectedLevel === lvl
                ? 'bg-blue-600 text-white shadow-md'
                : 'bg-white text-gray-600 border border-gray-200 hover:bg-gray-100'
            }`}
          >
            Рівень {lvl}
          </button>
        ))}
      </div>

      {loading ? (
        <div className="flex justify-center items-center h-64 text-gray-500">
          Підготовка карток рівня {selectedLevel}...
        </div>
      ) : cards.length === 0 ? (
        <div className="text-center py-20 px-4">
          <p className="text-gray-600 font-medium mb-2">На рівні {selectedLevel} поки немає нових слів.</p>
          <button 
            onClick={() => router.push('/')}
            className="text-blue-600 underline text-sm"
          >
            Повернутися на головну
          </button>
        </div>
      ) : (
        <FlashcardTrainer 
          cards={cards} 
          onFinishSession={() => router.push('/')} 
          onRateCard={handleRateCard} 
        />
      )}
    </div>
  );
}