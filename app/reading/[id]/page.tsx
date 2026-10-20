'use client';

import { useCallback, useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import ReadingView from '@/components/ReadingView';
import ErrorState from '@/components/ui/ErrorState';
import { completeReading, saveReadingWord } from '@/app/actions/reading';
import { glossaryIndex, questionsFrom, type ReadingText } from '@/lib/reading';

// Кеш тексту в браузері (офлайн, §76): версія змінюється, коли змінюється формат даних
const READING_CACHE_VERSION = 'v9'; // v9: словничок після модуля A0.10; v8: словничок після модуля A0.9; v7: словничок після модулів A0.7–A0.8; v6: словничок після модулів A0.5–A0.6; v5: словничок після модуля A0.4; v4: словничок і частка знайомих слів після уроків A0 за темою; v3: оновлені питання A0 (v2: граматичні підказки)
const READING_CACHE_TTL_MS = 12 * 60 * 60 * 1000; // 12 годин

type CachedText = ReadingText & { cachedAt: number };

/**
 * Екран одного тексту для читання (§6). Як і урок, дані бере в браузері й кешує:
 * відкритий раз текст можна читати офлайн (збереження слова й результату — лише онлайн).
 */
export default function ReadingTextPage() {
  const params = useParams();
  const textId = params.id as string;

  const [text, setText] = useState<ReadingText | null>(null);
  const [loading, setLoading] = useState(true);
  const [failed, setFailed] = useState(false);
  const [attempt, setAttempt] = useState(0);

  useEffect(() => {
    let cancelled = false;
    const supabase = createClient();
    const cacheKey = `cs_reading_${READING_CACHE_VERSION}_${textId}`;

    async function load(): Promise<ReadingText | null> {
      let stale: CachedText | null = null;
      try {
        const cached = localStorage.getItem(cacheKey);
        if (cached) {
          const parsed = JSON.parse(cached) as CachedText;
          if (Date.now() - (parsed.cachedAt ?? 0) < READING_CACHE_TTL_MS) return parsed;
          stale = parsed;
        }
      } catch {
        // пошкоджений кеш або недоступне сховище — завантажуємо з сервера
      }

      try {
        const { data, error } = await supabase
          .from('reading_texts')
          .select(
            'id, code, cefr, text_type, situation, module_order, title_ua, title_hr, body_hr, body_ua, glossary, questions, word_count, known_ratio',
          )
          .eq('id', textId)
          .eq('status', 'PUBLISHED')
          .single();
        if (error) throw error;

        const fresh: CachedText = {
          id: data.id as string,
          code: data.code as string,
          cefr: data.cefr as string,
          text_type: data.text_type as string,
          situation: (data.situation as string | null) ?? null,
          module_order: (data.module_order as number | null) ?? null,
          title_ua: data.title_ua as string,
          title_hr: data.title_hr as string,
          body_hr: data.body_hr as string,
          body_ua: (data.body_ua as string | null) ?? '',
          glossary: [...glossaryIndex(data.glossary).values()],
          questions: questionsFrom(data.questions),
          word_count: (data.word_count as number) ?? 0,
          known_ratio: data.known_ratio === null || data.known_ratio === undefined ? null : Number(data.known_ratio),
          cachedAt: Date.now(),
        };
        try {
          localStorage.setItem(cacheKey, JSON.stringify(fresh));
        } catch {
          // сховище переповнене — текст працює і без кешу
        }
        return fresh;
      } catch (err) {
        console.error('Помилка завантаження тексту:', err);
        return stale; // немає інтернету — остання збережена версія
      }
    }

    void load().then((data) => {
      if (cancelled) return;
      setText(data);
      setFailed(data === null);
      setLoading(false);
    });
    return () => {
      cancelled = true;
    };
  }, [textId, attempt]);

  const handleComplete = useCallback(
    async (correct: number, total: number, durationMs: number) => {
      try {
        return await completeReading({ textId, correct, total, durationMs, level: text?.cefr });
      } catch {
        return { ok: false as const, error: 'Немає інтернету — результат не збережено.' };
      }
    },
    [textId, text?.cefr],
  );

  const handleSaveWord = useCallback(
    async (lemma: string) => {
      try {
        return await saveReadingWord(textId, lemma);
      } catch {
        return { ok: false as const, error: 'Немає інтернету — спробуйте пізніше.' };
      }
    },
    [textId],
  );

  if (loading) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center gap-4" role="status">
        <div className="size-10 rounded-full border-4 border-primary-soft border-t-primary animate-spin" aria-hidden="true" />
        <p className="text-body text-ink-muted">Завантаження тексту…</p>
      </div>
    );
  }

  if (failed || !text) {
    return (
      <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-4">
        <ErrorState
          title="Не вдалося відкрити текст"
          text="Перевірте інтернет і спробуйте ще раз. Тексти, які ви вже відкривали, доступні й офлайн."
          onRetry={() => {
            setLoading(true);
            setAttempt((a) => a + 1);
          }}
        />
      </div>
    );
  }

  return <ReadingView key={text.id} text={text} onComplete={handleComplete} onSaveWord={handleSaveWord} />;
}
