'use client';

import { useState, useEffect, useRef } from 'react';
import { useRouter } from 'next/navigation';
import FlashcardTrainer, { Flashcard } from '@/components/FlashcardTrainer';
import WriteTrainer, { WriteCard } from '@/components/WriteTrainer';
import { createClient } from '@/utils/supabase/client';
import { rateFlashcard } from '@/app/actions/srs';
import { track } from '@/lib/analytics-client';
import { firstExample, type AnswerCheck } from '@/lib/answer';
import PracticeTabs from '@/components/ui/PracticeTabs';

const LEVELS = ['A0', 'A1', 'A2', 'B1'] as const;
type Level = (typeof LEVELS)[number];

/** «Картки» — впізнати слово (свайп); «Написати» — згадати і ввести слово самому (VS-001). */
type Mode = 'recognize' | 'write';
type SessionKind = 'review' | 'new' | 'write';

const SESSION_SIZE = 10;
const PREFS_KEY = 'cs_trainer_prefs';
const LEXEME_FIELDS = 'id, lemma, ukrainian_translation, part_of_speech, audio_url, examples';

interface LexemeRow {
  id: string;
  lemma: string;
  ukrainian_translation: string;
  part_of_speech: string | null;
  audio_url: string | null;
  examples: unknown;
}

const toCard = (item: LexemeRow): Flashcard & WriteCard => ({
  id: item.id,
  hr_text: item.lemma,
  ua_translation: item.ukrainian_translation,
  phonetic_note: item.part_of_speech ?? '',
  audio_url: item.audio_url ?? undefined,
  example: firstExample(item.examples),
});

export default function TrainerPage() {
  const [cards, setCards] = useState<(Flashcard & WriteCard)[]>([]);
  const [loading, setLoading] = useState(true);
  const [selectedLevel, setSelectedLevel] = useState<Level>('A1');
  const [mode, setMode] = useState<Mode>('recognize');
  const [saveError, setSaveError] = useState(false);
  // Ключ сесії: новий набір карток → компонент тренажера починає з першої картки
  const [sessionKey, setSessionKey] = useState(0);
  // Режим і рівень запамʼятовуються між відвідуваннями (зручність одного користувача)
  const [prefsReady, setPrefsReady] = useState(false);

  // Аналітика сесії тренажера
  const sessionRef = useRef({ startedAt: 0, rated: 0, correct: 0, kind: 'review' as SessionKind });
  const cardShownAtRef = useRef(0);

  const supabase = createClient();
  const router = useRouter();

  // Відновлюємо останній режим і рівень
  useEffect(() => {
    try {
      const saved = JSON.parse(localStorage.getItem(PREFS_KEY) ?? '{}');
      if (saved.mode === 'recognize' || saved.mode === 'write') setMode(saved.mode);
      if ((LEVELS as readonly string[]).includes(saved.level)) setSelectedLevel(saved.level);
    } catch {
      // немає доступу до сховища — працюємо з типовими значеннями
    }
    setPrefsReady(true);
  }, []);

  useEffect(() => {
    if (!prefsReady) return;
    try {
      localStorage.setItem(PREFS_KEY, JSON.stringify({ mode, level: selectedLevel }));
    } catch {
      // не критично
    }
  }, [prefsReady, mode, selectedLevel]);

  useEffect(() => {
    if (!prefsReady) return;
    // Якщо рівень/режим змінили (або React у режимі розробки перезапустив ефект) —
    // результат старого завантаження ігноруємо, щоб не було подвійних карток і подій.
    let cancelled = false;

    async function fetchCards() {
      setLoading(true);
      try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return;

        const nowMs = Date.now();

        // 1. Усі слова, які користувач уже вчить
        const { data: progressData, error: progressError } = await supabase
          .from('user_progress')
          .select('lexeme_id, next_review_date')
          .eq('user_id', user.id);

        if (progressError) throw progressError;

        const progress = (progressData ?? []).map(p => ({
          id: p.lexeme_id as string,
          dueAt: new Date(p.next_review_date).getTime(),
        }));
        const knownIds = new Set(progress.map(p => p.id));
        const dueIds = progress.filter(p => p.dueAt <= nowMs).map(p => p.id);

        let lexemeData: LexemeRow[] = [];
        let kind: SessionKind;

        if (mode === 'write') {
          // «Написати»: лише слова, які користувач уже бачив (спочатку ті, що на повторенні),
          // бо згадати слово, якого ще не вчив, неможливо.
          kind = 'write';
          const ordered = [...progress].sort((a, b) => a.dueAt - b.dueAt).map(p => p.id).slice(0, 200);
          if (ordered.length > 0) {
            const { data, error } = await supabase
              .from('lexemes')
              .select(LEXEME_FIELDS)
              .in('id', ordered)
              .eq('cefr', selectedLevel)
              // Лише чинні слова (речення й репліки перенесено в phrases / conversations → DEPRECATED)
              .eq('status', 'PUBLISHED');
            if (error) throw error;
            const byId = new Map(((data ?? []) as LexemeRow[]).map(row => [row.id, row]));
            lexemeData = ordered.map(id => byId.get(id)).filter((r): r is LexemeRow => !!r).slice(0, SESSION_SIZE);
          }
        } else {
          // «Картки»: спочатку повторення на сьогодні, потім нові слова до повної сесії
          if (dueIds.length > 0) {
            const { data, error } = await supabase
              .from('lexemes')
              .select(LEXEME_FIELDS)
              .in('id', dueIds.slice(0, 200))
              .eq('cefr', selectedLevel)
              .eq('status', 'PUBLISHED')
              .limit(SESSION_SIZE);

            if (error) throw error;
            lexemeData = (data ?? []) as LexemeRow[];
          }
          kind = lexemeData.length > 0 ? 'review' : 'new';

          // Нові слова за частотністю (принцип Парето), без тих, що вже в повтореннях
          if (lexemeData.length < SESSION_SIZE) {
            const { data, error } = await supabase
              .from('lexemes')
              .select(LEXEME_FIELDS)
              .eq('cefr', selectedLevel)
              .eq('status', 'PUBLISHED')
              .order('frequency_rank', { ascending: true, nullsFirst: false })
              .limit(Math.min(SESSION_SIZE + knownIds.size, 1000));

            if (error) throw error;
            const fresh = ((data ?? []) as LexemeRow[])
              .filter(item => !knownIds.has(item.id))
              .slice(0, SESSION_SIZE - lexemeData.length);
            lexemeData = [...lexemeData, ...fresh];
          }
        }

        if (cancelled) return;

        // Нова сесія: лічильники + подія review_started
        const now = Date.now();
        sessionRef.current = { startedAt: now, rated: 0, correct: 0, kind };
        cardShownAtRef.current = now;
        if (lexemeData.length > 0) {
          track('review_started', { level: selectedLevel, count: lexemeData.length, source: kind });
        }

        setCards(lexemeData.map(toCard));
        setSessionKey(now);
      } catch (err) {
        console.error('Помилка завантаження тренажера:', err);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    fetchCards();
    return () => {
      cancelled = true;
    };
  }, [supabase, selectedLevel, mode, prefsReady]);

  /** Спільне для обох режимів: підсумок сесії + збереження в SRS. */
  const recordAnswer = async (cardId: string, correct: boolean, responseTimeMs: number) => {
    const now = Date.now();
    const session = sessionRef.current;
    session.rated += 1;
    if (correct) session.correct += 1;
    if (session.rated === cards.length) {
      track('review_completed', {
        level: selectedLevel,
        count: session.rated,
        correct_count: session.correct,
        duration_ms: now - session.startedAt,
        source: session.kind,
        success: true,
      });
    }

    try {
      await rateFlashcard(cardId, correct ? 1 : 0, responseTimeMs);
      setSaveError(false);
    } catch (error) {
      console.error('Помилка при збереженні прогресу:', error);
      setSaveError(true);
    }
  };

  // «Картки»: свайп
  const handleRateCard = (cardId: string, rating: number) => {
    const now = Date.now();
    const responseTimeMs = now - cardShownAtRef.current;
    cardShownAtRef.current = now;
    void recordAnswer(cardId, rating === 1, responseTimeMs);
  };

  // «Написати»: введене слово (VS-001: retrieval + production + feedback)
  const handleWriteAnswer = (card: WriteCard, result: AnswerCheck, responseTimeMs: number) => {
    track('exercise_completed', {
      lexeme_id: card.id,
      level: selectedLevel,
      exercise_type: 'type_word',
      source: 'trainer',
      success: result.correct,
      attempt: 1,
      duration_ms: responseTimeMs,
      verdict: result.verdict,
    });
    void recordAnswer(card.id, result.correct, responseTimeMs);
  };

  const emptyText = mode === 'write'
    ? `На рівні ${selectedLevel} ще немає слів, які ви вчите. Почніть з режиму «Картки» або з уроку.`
    : `На рівні ${selectedLevel} поки немає нових слів.`;

  return (
    <div className="min-h-screen pb-28">
      <header className="max-w-md mx-auto px-4 pt-[calc(2.5rem+env(safe-area-inset-top))] mb-4">
        <h1 className="font-heading text-h1 mb-2">Практика</h1>
        <PracticeTabs />
      </header>

      {/* Режим тренування */}
      <div className="max-w-md mx-auto px-4 mb-2">
        <div className="grid grid-cols-2 gap-1 p-1 bg-gray-200/70 rounded-2xl" role="tablist" aria-label="Режим тренування">
          {([['recognize', '👀 Картки'], ['write', '✍️ Написати']] as const).map(([value, label]) => (
            <button
              key={value}
              role="tab"
              aria-selected={mode === value}
              onClick={() => setMode(value)}
              className={`py-2 rounded-xl text-sm font-bold transition-all ${
                mode === value ? 'bg-white text-blue-700 shadow' : 'text-gray-600 hover:text-gray-900'
              }`}
            >
              {label}
            </button>
          ))}
        </div>
      </div>

      {/* Панель вибору рівня для тренування */}
      <div className="max-w-md mx-auto px-4 flex justify-center gap-2 mb-2">
        {LEVELS.map((lvl) => (
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

      {saveError && (
        <div className="max-w-md mx-auto px-4 mb-2">
          <div role="alert" className="px-4 py-2 rounded-xl bg-rose-50 text-rose-700 text-sm font-medium text-center border border-rose-200">
            Не вдалося зберегти відповідь. Перевірте інтернет — наступні відповіді спробуємо зберегти знову.
          </div>
        </div>
      )}

      {loading ? (
        <div className="flex justify-center items-center h-64 text-gray-500">
          Підготовка карток рівня {selectedLevel}...
        </div>
      ) : cards.length === 0 ? (
        <div className="text-center py-20 px-4">
          <p className="text-gray-600 font-medium mb-2">{emptyText}</p>
          <button
            onClick={() => router.push('/')}
            className="text-blue-600 underline text-sm"
          >
            Повернутися на головну
          </button>
        </div>
      ) : mode === 'write' ? (
        <WriteTrainer
          key={sessionKey}
          cards={cards}
          onAnswer={handleWriteAnswer}
          onFinishSession={() => router.push('/')}
        />
      ) : (
        <FlashcardTrainer
          key={sessionKey}
          cards={cards}
          onFinishSession={() => router.push('/')}
          onRateCard={handleRateCard}
        />
      )}
    </div>
  );
}
