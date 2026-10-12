'use server';

import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';

export async function getLessonData(lessonId: string) {
  const cookieStore = await cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll: () => cookieStore.getAll(), setAll: () => {} } }
  );

  // 1. Отримуємо дані самого уроку
  const { data: lesson, error: lessonError } = await supabase
    .from('lessons')
    .select('*')
    .eq('id', lessonId)
    .single();

  if (lessonError || !lesson) throw new Error('Урок не знайдено');

  // 2. Отримуємо список елементів уроку (lesson_items)
  const { data: items, error: itemsError } = await supabase
    .from('lesson_items')
    .select('*')
    .eq('lesson_id', lessonId)
    .order('order_index', { ascending: true });

  if (itemsError) throw itemsError;

  const lexemeIds = items?.filter(i => i.item_type === 'lexeme').map(i => i.item_id) || [];
  const exerciseIds = items?.filter(i => i.item_type === 'exercise').map(i => i.item_id) || [];
  const grammarIds = items?.filter(i => i.item_type === 'grammar').map(i => i.item_id) || [];

  // 3. Підтягуємо лексеми
  let topicWords: any[] = [];
  if (lexemeIds.length > 0) {
    const { data: lexemes } = await supabase
      .from('lexemes')
      .select('id, lemma, ukrainian_translation, part_of_speech')
      .in('id', lexemeIds);

    topicWords = (lexemes || []).map(lex => ({
      id: lex.id,
      hr_text: lex.lemma,
      ua_translation: lex.ukrainian_translation,
      phonetic_note: lex.part_of_speech
    }));
  }

  // 4. Підтягуємо вправи
  let exercises: any[] = [];
  if (exerciseIds.length > 0) {
    const { data: ex } = await supabase
      .from('exercises')
      .select('*')
      .in('id', exerciseIds);

    exercises = items
      .filter(i => i.item_type === 'exercise')
      .map(i => ex?.find(e => e.id === i.item_id))
      .filter(Boolean);
  }

  // 5. Підтягуємо діалоги
  let lines: any[] = [];
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
    lines = turns || [];
  }

  // 6. Підтягуємо Граматику
  let grammar: any[] = [];
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
      grammar = topics.map(topic => ({
        ...topic,
        rules: topic.rules?.sort((a: any, b: any) => a.order_index - b.order_index) || []
      }));
    }
  }

  return {
    id: lesson.id,
    title: lesson.title_ua,
    description: lesson.title_hr,
    status: lesson.status,
    lines,
    exercises,
    topicWords,
    grammar
  };
}