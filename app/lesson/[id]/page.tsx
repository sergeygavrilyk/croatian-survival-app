'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@supabase/supabase-js';
import { useRouter, useParams } from 'next/navigation';
import LessonView from '@/components/LessonView';

const supabase = createClient(
  process.env.NEXT_PUBLIC_SUPABASE_URL!,
  process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
);

export default function LessonPage() {
  const router = useRouter();
  const params = useParams();
  const topicId = params.id as string;

  const [topic, setTopic] = useState<any>(null);
  const [lines, setLines] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    async function fetchLessonData() {
      // Завантажуємо інформацію про сам модуль
      const { data: topicData } = await supabase
        .from('topics')
        .select('*')
        .eq('id', topicId)
        .single();

      if (topicData) setTopic(topicData);

      // Завантажуємо лише рядки діалогу для цього модуля
      const { data: vocabData } = await supabase
        .from('vocabulary')
        .select('*')
        .eq('topic_id', topicId)
        .eq('item_type', 'dialogue_line')
        .order('created_at', { ascending: true });

      if (vocabData) {
        // Парсимо ім'я спікера та текст (ми зберігали їх у форматі "Speaker: Text")
        const formattedLines = vocabData.map((v) => {
          const splitIndex = v.hr_text.indexOf(':');
          const speaker = splitIndex > -1 ? v.hr_text.substring(0, splitIndex).trim() : 'А';
          const text = splitIndex > -1 ? v.hr_text.substring(splitIndex + 1).trim() : v.hr_text;

          return {
            id: v.id,
            speaker: speaker,
            hr_text: text,
            ua_translation: v.ua_translation,
          };
        });
        setLines(formattedLines);
      }
      setIsLoading(false);
    }

    if (topicId) fetchLessonData();
  }, [topicId]);

  if (isLoading) {
    return <div className="text-center mt-20 text-gray-500 animate-pulse">Завантаження уроку...</div>;
  }

  if (!topic) {
    return <div className="text-center mt-20 text-red-500">Урок не знайдено</div>;
  }

  return (
    <LessonView 
      title={topic.title_hr} 
      description={topic.title_ua} 
      lines={lines} 
      onComplete={() => router.push('/')} 
    />
  );
}