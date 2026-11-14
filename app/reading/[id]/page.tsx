import { createClient } from '@/utils/supabase/server';
import ReadingScreen from '@/components/ReadingScreen';
import {
  READING_TEXT_COLUMNS, glossaryLemmas, readingTextFrom, withGlossaryLabels, type GlossaryLexemeRow, type ReadingText,
} from '@/lib/reading';

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
    if (!data) return { text: null, notFound: true };
    const text = readingTextFrom(data as Record<string, unknown>);
    return { text: { ...text, glossary: await labelGlossary(supabase, text.glossary) }, notFound: false };
  } catch (err) {
    console.error('Помилка завантаження тексту:', err instanceof Error ? err.message : err);
    return { text: null, notFound: false };
  }
}

type Supabase = Awaited<ReturnType<typeof createClient>>;

/**
 * Позначка категорії в словничку тексту (DESIGN_SYSTEM.md §3.4): глосарій — JSON без `lexeme_id`, тож мітки беремо
 * з `lexemes` за лемою (частинами по 150). Необов'язково: збій — текст без позначок.
 */
async function labelGlossary(supabase: Supabase, glossary: ReadingText['glossary']): Promise<ReadingText['glossary']> {
  const lemmas = glossaryLemmas(glossary);
  if (lemmas.length === 0) return glossary;
  try {
    const rows: GlossaryLexemeRow[] = [];
    for (let i = 0; i < lemmas.length; i += 150) {
      const { data, error } = await supabase
        .from('lexemes')
        .select('lemma, register, regionality, usage_tags, standard_lexeme_id')
        .in('lemma', lemmas.slice(i, i + 150))
        .eq('status', 'PUBLISHED');
      if (error) throw error;
      rows.push(...((data ?? []) as GlossaryLexemeRow[]));
    }
    const standardIds = [...new Set(rows.map((r) => r.standard_lexeme_id).filter((id): id is string => !!id))];
    let standards: { id: string; lemma: string }[] = [];
    if (standardIds.length) {
      const res = await supabase.from('lexemes').select('id, lemma').in('id', standardIds).eq('status', 'PUBLISHED');
      if (res.error) console.warn('Стандартні відповідники словничка не завантажились:', res.error.message);
      else standards = (res.data ?? []) as { id: string; lemma: string }[];
    }
    return withGlossaryLabels(glossary, rows, standards);
  } catch (err) {
    console.warn('Мітки словничка тексту не завантажились:', err instanceof Error ? err.message : err);
    return glossary;
  }
}
