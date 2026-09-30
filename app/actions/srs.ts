'use server'

import { createServerClient } from '@supabase/ssr';
import { cookies } from 'next/headers';

export async function rateFlashcard(vocabularyId: string, rating: number) {
  const cookieStore = await cookies();
  const supabase = createServerClient(
    process.env.NEXT_PUBLIC_SUPABASE_URL!,
    process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY!,
    { cookies: { getAll: () => cookieStore.getAll(), setAll: () => {} } }
  );

  // Отримуємо поточного користувача
  const { data: { user }, error: authError } = await supabase.auth.getUser();
  if (authError || !user) throw new Error('Не авторизовано');

  // 1. Отримуємо поточний прогрес для конкретного слова
  const { data: progress } = await supabase
    .from('user_progress')
    .select('*')
    .eq('user_id', user.id)
    .eq('vocabulary_id', vocabularyId)
    .single();

  // Витягуємо дані або беремо дефолтні значення з вашої схеми
  let easeFactor = progress?.ease_factor ?? 2.5;
  let intervalDays = progress?.interval_days ?? 0;
  let repetitionCount = progress?.repetition_count ?? 0;

  // Мапінг нашої оцінки на якість SM-2 (0-5)
  let quality = 0;
  if (rating === 1) quality = 2; // Складно -> згадав, але важко
  if (rating === 2) quality = 4; // Добре -> згадав нормально
  if (rating === 3) quality = 5; // Легко -> згадав ідеально

  // 2. Розрахунок за алгоритмом SM-2
  if (quality < 3) {
    // Якщо було дуже складно — скидаємо серію успіхів
    repetitionCount = 0;
    intervalDays = 1; // Повторити завтра
  } else {
    // Якщо успішно
    if (repetitionCount === 0) intervalDays = 1;
    else if (repetitionCount === 1) intervalDays = 6;
    else intervalDays = Math.round(intervalDays * easeFactor);
    
    repetitionCount += 1;
  }

  // Оновлюємо Ease Factor (не може бути меншим за 1.3)
  easeFactor = easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
  easeFactor = Math.max(1.3, easeFactor);

  // Розраховуємо наступну дату
  const nextReviewDate = new Date();
  nextReviewDate.setDate(nextReviewDate.getDate() + intervalDays);

  // 3. Зберігаємо в базу (Upsert використовує ваш constraint user_progress_user_id_vocabulary_id_key)
  const { error: upsertError } = await supabase
    .from('user_progress')
    .upsert({
      user_id: user.id,
      vocabulary_id: vocabularyId,
      ease_factor: easeFactor,
      interval_days: intervalDays,
      repetition_count: repetitionCount,
      next_review_date: nextReviewDate.toISOString(),
      last_reviewed_at: new Date().toISOString(), // Фіксуємо час відповіді
    }, {
      onConflict: 'user_id, vocabulary_id' 
    });

  if (upsertError) {
    console.error('Помилка збереження прогресу:', upsertError);
    throw new Error('Не вдалося зберегти прогрес');
  }

  return { success: true, nextReviewDate, intervalDays };
}