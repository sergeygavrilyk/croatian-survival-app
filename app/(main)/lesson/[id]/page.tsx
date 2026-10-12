'use client';

import React, { useState, useEffect, useRef } from 'react';
import { useRouter, useParams } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import LessonView, { DialogueLine, Exercise, VocabularyItem, GrammarTopic } from '@/components/LessonView'; // Додали GrammarTopic
import { completeLesson } from '@/app/actions/progress';
import { track, getSessionId } from '@/lib/analytics-client';

// Кеш уроку в браузері: версія змінюється, коли змінюється формат даних
const LESSON_CACHE_VERSION = 'v2';
const LESSON_CACHE_TTL_MS = 12 * 60 * 60 * 1000; // 12 годин

export default function LessonPage() {
  const router = useRouter();
  const params = useParams();
  const lessonId = params.id as string;
  const supabase = createClient();

  const [lesson, setLesson] = useState<any>(null);
  const [dialogue, setDialogue] = useState<DialogueLine[]>([]);
  const [exercises, setExercises] = useState<Exercise[]>([]);
  const [lessonVocabulary, setLessonVocabulary] = useState<VocabularyItem[]>([]);
  const [grammar, setGrammar] = useState<GrammarTopic[]>([]); // <-- ДОДАНО СТЕЙТ
  const [loading, setLoading] = useState(true);
  const startedAtRef = useRef<number>(Date.now());
  const startTrackedRef = useRef(false);

  useEffect(() => {
    async function fetchLessonData() {
      const cacheKey = `cs_lesson_data_${LESSON_CACHE_VERSION}_${lessonId}`;
      let staleCache: any = null;

      const applyLessonData = (data: any) => {
        setLesson(data.lesson);
        setDialogue(data.dialogue || []);
        setExercises(data.exercises || []);
        setLessonVocabulary(data.lessonVocabulary || []);
        setGrammar(data.grammar || []);
      };

      try {
        // 1. ЛОКАЛЬНИЙ КЕШ: свіжий — показуємо одразу; застарілий — лише якщо немає інтернету
        try {
          const cached = localStorage.getItem(cacheKey);
          if (cached) {
            const parsed = JSON.parse(cached);
            if (Date.now() - (parsed.cachedAt ?? 0) < LESSON_CACHE_TTL_MS) {
              applyLessonData(parsed);
              setLoading(false);
              return;
            }
            staleCache = parsed;
          }
        } catch {
          // пошкоджений кеш або недоступне сховище — просто завантажуємо з сервера
        }

        // 2. ЯКЩО В КЕШІ НЕМАЄ — РОБИМО ЗАПИТИ
        const { data: lessonData, error: lessonError } = await supabase
          .from('lessons')
          .select('id, title_ua, title_hr, status, level_code')
          .eq('id', lessonId)
          .single();

        if (lessonError) throw lessonError;

        const { data: items } = await supabase
          .from('lesson_items')
          .select('*')
          .eq('lesson_id', lessonId)
          .order('order_index', { ascending: true });

        const lexemeIds = items?.filter(i => i.item_type === 'lexeme').map(i => i.item_id) || [];
        const exerciseIds = items?.filter(i => i.item_type === 'exercise').map(i => i.item_id) || [];
        const grammarIds = items?.filter(i => i.item_type === 'grammar').map(i => i.item_id) || []; // <-- ДОДАНО

        let vocabData: VocabularyItem[] = [];
        if (lexemeIds.length > 0) {
          const { data: lexemes } = await supabase
            .from('lexemes')
            .select('id, lemma, ukrainian_translation, part_of_speech')
            .in('id', lexemeIds);
          
          vocabData = (lexemes || []).map(lex => ({
            id: lex.id,
            hr_text: lex.lemma, 
            ua_translation: lex.ukrainian_translation,
            phonetic_note: lex.part_of_speech
          }));
        }

        let exData: Exercise[] = [];
        if (exerciseIds.length > 0) {
          const { data: ex } = await supabase
            .from('exercises')
            .select('*')
            .in('id', exerciseIds);
          
          exData = items?.filter(i => i.item_type === 'exercise')
                         .map(i => ex?.find(e => e.id === i.item_id))
                         .filter(Boolean) as Exercise[];
        }

        let convData: DialogueLine[] = [];
        const { data: conversation } = await supabase
          .from('conversations')
          .select('id')
          .eq('lesson_id', lessonId)
          .maybeSingle();

        if (conversation) {
          const { data: turns } = await supabase
            .from('conversation_turns')
            .select('*')
            .eq('conversation_id', conversation.id)
            .order('order_index', { ascending: true });
          convData = (turns || []) as DialogueLine[];
        }

        // --- НОВИЙ БЛОК: ПІДТЯГУЄМО ГРАМАТИКУ ---
        let grammarData: GrammarTopic[] = [];
        if (grammarIds.length > 0) {
          const { data: topics } = await supabase
            .from('grammar_topics')
            .select(`
              id, 
              title_ua, 
              title_hr, 
              description,
              rules:grammar_rules(id, title_ua, explanation_ua, pattern_hr, examples, order_index)
            `)
            .in('id', grammarIds);
            
          if (topics) {
            grammarData = topics.map(topic => ({
              ...topic,
              rules: topic.rules?.sort((a: any, b: any) => a.order_index - b.order_index) || []
            })) as GrammarTopic[];
          }
        }

        // 3. ЗБЕРІГАЄМО В КЕШ
        const fullLessonData = {
          lesson: lessonData,
          dialogue: convData,
          exercises: exData,
          lessonVocabulary: vocabData,
          grammar: grammarData,
          cachedAt: Date.now(),
        };

        try {
          localStorage.setItem(cacheKey, JSON.stringify(fullLessonData));
        } catch {
          // сховище переповнене або недоступне — урок працює і без кешу
        }

        applyLessonData(fullLessonData);

      } catch (err) {
        console.error('Помилка завантаження уроку:', err);
        // Немає інтернету — показуємо останню збережену версію уроку (офлайн, §76)
        if (staleCache) applyLessonData(staleCache);
      } finally {
        setLoading(false);
      }
    }
    
    fetchLessonData();
  }, [lessonId, supabase]);

  // Аналітика: урок відкрито (один раз, коли дані завантажились)
  useEffect(() => {
    if (loading || !lesson || startTrackedRef.current) return;
    startTrackedRef.current = true;
    startedAtRef.current = Date.now();
    track('lesson_started', { lesson_id: lessonId, level: lesson.level_code ?? undefined });
  }, [loading, lesson, lessonId]);

  // Завершення уроку: прогрес уроку + слова уроку в повторення (SRS)
  const handleLessonComplete = async () => {
    try {
      await completeLesson(lessonId, {
        session_id: getSessionId(),
        duration_ms: Date.now() - startedAtRef.current,
        level: lesson?.level_code ?? undefined,
      });
      router.push('/lessons');
    } catch (err) {
      // Прогрес не збережено — лишаємо користувача на уроці, щоб він міг повторити
      console.error('Помилка збереження прогресу уроку:', err);
      alert('Не вдалося зберегти прогрес уроку. Перевірте інтернет і натисніть «Перевірити» ще раз.');
    }
  };

  if (loading) {
    return (
      <div className="min-h-screen bg-slate-50 flex flex-col justify-center items-center">
        <div className="w-10 h-10 border-4 border-indigo-200 border-t-indigo-600 rounded-full animate-spin mb-4"></div>
        <p className="text-slate-500 font-medium">Завантаження уроку...</p>
      </div>
    );
  }

  return (
    <LessonView 
      title={lesson?.title_ua || 'Урок'} 
      description={lesson?.title_hr}
      lines={dialogue}
      exercises={exercises}
      topicWords={lessonVocabulary}
      grammar={grammar} // <-- ОСЬ ЦЕ НАЙГОЛОВНІШЕ
      onComplete={handleLessonComplete}
      lessonId={lessonId}
    />
  );
}