import { createClient } from '@/utils/supabase/server';
import ReadingScreen from '@/components/ReadingScreen';
import { READING_TEXT_COLUMNS, readingTextFrom, type ReadingText } from '@/lib/reading';

export const metadata = { title: 'Читання · Croatian Survival App' };
export const dynamic = 'force-dynamic';

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

/**
 * Один текст для читання (§6; з 2026-10-21 — Server Component, §75): сторінка бере текст на сервері,
 * ReadingScreen (client) — показує його, зберігає офлайн-копію (§76), слово в тренажер і результат.
 * Онлайн текст завжди свіжий, тож ручна версія кешу (READING_CACHE_VERSION) більше не потрібна.
 */
export default async function ReadingTextPage({ params }: { params: Promise<{ id: string }> }) {
  const { id } = await params;
  const { text, notFound } = UUID_RE.test(id) ? await loadText(id) : { text: null, notFound: true };
  return <ReadingScreen textId={id} initial={text} notFound={notFound} />;
}

/** null + notFound — тексту немає (або не опублікований); null без notFound — збій бази чи мережі. */
async function loadText(id: string): Promise<{ text: ReadingText | null; notFound: boolean }> {
  try {
    const supabase = await createClient();
    const { data, error } = await supabase
      .from('reading_texts')
      .select(READING_TEXT_COLUMNS)
      .eq('id', id)
      .eq('status', 'PUBLISHED')
      .maybeSingle();
    if (error) throw error;
    return data ? { text: readingTextFrom(data as Record<string, unknown>), notFound: false } : { text: null, notFound: true };
  } catch (err) {
    console.error('Помилка завантаження тексту:', err instanceof Error ? err.message : err);
    return { text: null, notFound: false };
  }
}
