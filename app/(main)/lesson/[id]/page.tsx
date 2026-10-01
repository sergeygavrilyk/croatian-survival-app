'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { useRouter, useParams } from 'next/navigation';
import LessonView from '@/components/LessonView';

const supabase = createClient();

export default function LessonPage() {
  const router = useRouter();
  const params = useParams();
  const topicId = params.id as string;

  const [topic, setTopic] = useState<any>(null);
  const [lines, setLines] = useState<any[]>([]);
  const [exercises, setExercises] = useState<any[]>([]); // Додано стейт для вправ
  const [isLoading, setIsLoading] = useState(true);
  const [isCompleting, setIsCompleting] = useState(false);

  useEffect(() => {
    async function fetchLessonData() {
      // 1. Завантажуємо тему
      const { data: topicData } = await supabase
        .from('topics')
        .select('*')
        .eq('id', topicId)
        .single();

      if (topicData) setTopic(topicData);

      // 2. Завантажуємо діалоги
      // СТАЛО: Завантажуємо діалоги з правильної таблиці conversations
      const { data: convData, error: convError } = await supabase
        .from('conversations')
        .select('*')
        .eq('topic_id', topicId)
        .order('order_index', { ascending: true });

      if (convError) console.error("Помилка завантаження діалогів:", convError);

      if (convData) {
        const formattedLines = convData.map((v) => ({
            id: v.id,
            speaker: v.speaker_name, // Беремо готове ім'я спікера
            hr_text: v.hr_text,
            ua_translation: v.ua_translation,
        }));
        setLines(formattedLines);
      }

      // 3. Завантажуємо вправи (НОВЕ)
      const { data: exercisesData } = await supabase
        .from('exercises')
        .select('*')
        .eq('topic_id', topicId)
        .order('order_index', { ascending: true });
        
      if (exercisesData) setExercises(exercisesData);

      setIsLoading(false);
    }

    if (topicId) fetchLessonData();
  }, [topicId]);

  const handleCompleteLesson = async () => {
    setIsCompleting(true);
    try {
      const { data: { user } } = await supabase.auth.getUser();
      if (user) {
        const { error } = await supabase.rpc('complete_lesson_and_start_srs', {
          p_user_id: user.id,
          p_topic_id: topicId
        });
        if (error) console.error("Помилка збереження прогресу:", error);
      }
    } catch (err) {
      console.error(err);
    } finally {
      router.push('/'); 
    }
  };

  if (isLoading) return <div className="text-center mt-20 text-gray-500 animate-pulse">Завантаження уроку...</div>;
  if (!topic) return <div className="text-center mt-20 text-red-500">Урок не знайдено</div>;

  return (
    <div className="relative">
      {isCompleting && (
        <div className="absolute inset-0 z-50 flex items-center justify-center bg-white/70 backdrop-blur-sm">
          <div className="bg-blue-600 text-white px-6 py-3 rounded-2xl shadow-lg animate-pulse font-bold">
            Зберігаємо прогрес... 🎉
          </div>
        </div>
      )}
      
      {/* Передаємо вправи у компонент */}
      <LessonView 
        title={topic.title_hr} 
        description={topic.title_ua} 
        lines={lines} 
        exercises={exercises} 
        onComplete={handleCompleteLesson} 
      />
    </div>
  );
}