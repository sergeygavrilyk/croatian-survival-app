'use server';

import { createClient } from '@supabase/supabase-js';

export async function getOrTranslateWord(wordRaw: string) {
  const cleanWord = wordRaw.replace(/[.,!?;:"'«»]/g, '').trim().toLowerCase();
  if (!cleanWord) return null;

  const supabase = createClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.SUPABASE_SERVICE_ROLE_KEY || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!
  );

  // Виносимо Google Translate у зручну функцію для перевикористання
  const fetchGoogleTranslation = async (text: string) => {
    try {
      const res = await fetch(`https://translate.googleapis.com/translate_a/single?client=gtx&sl=hr&tl=uk&dt=t&q=${encodeURIComponent(text)}`);
      const json = await res.json();
      if (json && json[0] && json[0][0] && json[0][0][0]) {
        return json[0][0][0];
      }
    } catch (err) {
      console.error('Помилка Google Translate:', err);
    }
    return null;
  };

  // 1. Шукаємо 100% точний збіг у базі
  const { data: exactMatch } = await supabase
    .from('vocabulary')
    .select('*')
    .eq('item_type', 'word')
    .ilike('hr_text', cleanWord)
    .limit(1)
    .maybeSingle();

  if (exactMatch) {
    // 1.1. САМОЛІКУВАННЯ БАЗИ: Перевіряємо, чи переклад бракований ("лексема_...", "Переклад..." або порожній)
    const isTranslationMissing = !exactMatch.ua_translation || 
                                 exactMatch.ua_translation.includes('лексема') || 
                                 exactMatch.ua_translation.includes('Переклад');
    
    if (isTranslationMissing) {
      const newTranslation = await fetchGoogleTranslation(cleanWord);
      
      if (newTranslation) {
        // Оновлюємо запис у Supabase назавжди
        await supabase
          .from('vocabulary')
          .update({ ua_translation: newTranslation })
          .eq('id', exactMatch.id);
        
        // Віддаємо клієнту вже оновлений та правильний варіант
        exactMatch.ua_translation = newTranslation; 
      }
    }
    return exactMatch;
  }

  // 2. Якщо слова в базі зовсім немає - перекладаємо "на льоту"
  const translatedUA = await fetchGoogleTranslation(cleanWord) || `Переклад: ${cleanWord}`;
  
  let phoneticNote = 'З діалогу';
  if (cleanWord.endsWith('im') || cleanWord.endsWith('eš') || cleanWord.endsWith('mo') || cleanWord.endsWith('te')) {
    phoneticNote = 'Дієслово';
  } else if (cleanWord.endsWith('a') || cleanWord.endsWith('o') || cleanWord.endsWith('e') || cleanWord.endsWith('i')) {
    phoneticNote = 'Іменник / Прикметник';
  }

  // 3. Автоматично додаємо нове слово в базу (кешування назавжди)
  const { data: newEntry, error: insertError } = await supabase
    .from('vocabulary')
    .insert([
      {
        topic_id: null,
        item_type: 'word',
        hr_text: cleanWord,
        ua_translation: translatedUA,
        phonetic_note: phoneticNote,
        level: 'B1',
        frequency_rank: 5000
      }
    ])
    .select()
    .single();

  if (insertError) {
    return {
      id: 'dynamic-word',
      hr_text: cleanWord,
      ua_translation: translatedUA,
      phonetic_note: phoneticNote
    };
  }

  return newEntry;
}