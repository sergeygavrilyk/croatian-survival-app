'use client';

import { useEffect, useMemo, useRef, useState, useSyncExternalStore } from 'react';
import { useRouter } from 'next/navigation';
import { BookOpen, Layers, PenLine, Repeat } from 'lucide-react';
import FlashcardTrainer, { Flashcard } from '@/components/FlashcardTrainer';
import WriteTrainer, { WriteCard } from '@/components/WriteTrainer';
import { createClient } from '@/utils/supabase/client';
import { rateFlashcard } from '@/app/actions/srs';
import { track } from '@/lib/analytics-client';
import { firstExample, type AnswerCheck } from '@/lib/answer';
import { countUk, posLabelUk } from '@/lib/format';
import { LEVEL_CODES, levelStyle } from '@/lib/levels';
import { cn } from '@/lib/ui';
import { WORD_THEME_SELECT, wordThemes, type WordTheme } from '@/lib/word-theme';
import Button from '@/components/ui/Button';
import EmptyState from '@/components/ui/EmptyState';
import ErrorState from '@/components/ui/ErrorState';
import PracticeTabs from '@/components/ui/PracticeTabs';
import Skeleton from '@/components/ui/Skeleton';

// 'ALL' — усі слова, які користувач уже вчить, незалежно від рівня (типово)
const LEVELS = ['ALL', ...LEVEL_CODES] as const;
type Level = (typeof LEVELS)[number];

/**
 * «Картки» — впізнати слово (свайп); «Написати» — згадати і ввести слово самому (VS-001).
 * В обох режимах — ЛИШЕ слова, які користувач уже вчить (user_progress):
 * слова пройдених уроків і ті, що він сам додав у словник. Нових слів тренажер не підкидає.
 * Вигляд — DESIGN_SYSTEM §3.4, §9.1, §9.2: колір рівня й емодзі теми біля слова.
 */
type Mode = 'recognize' | 'write';
type SessionKind = 'review' | 'practice' | 'write';
type Card = Flashcard & WriteCard;

const SESSION_SIZE = 10;
// v2: типовий рівень став «Усі» (старі збережені налаштування з рівнем A1 ігноруємо)
const PREFS_KEY = 'cs_trainer_prefs_v2';
const LEXEME_FIELDS = 'id, lemma, ukrainian_translation, part_of_speech, audio_url, examples, cefr';

const noSubscribe = () => () => {};
function readPrefsRaw(): string | null {
  try {
    return localStorage.getItem(PREFS_KEY);
  } catch {
    return null; // немає доступу до сховища — типові значення
  }
}
/** Збережені режим і рівень; хибне чи старе значення — null (тоді типове). */
function parsePrefs(raw: string | null | undefined): { mode: Mode | null; level: Level | null } {
  try {
    const saved = JSON.parse(raw ?? '{}') as { mode?: unknown; level?: unknown };
    return {
      mode: saved.mode === 'recognize' || saved.mode === 'write' ? saved.mode : null,
      level: (LEVELS as readonly unknown[]).includes(saved.level) ? (saved.level as Level) : null,
    };
  } catch {
    return { mode: null, level: null };
  }
}

const MODES: ReadonlyArray<{ value: Mode; label: string; Icon: typeof Layers }> = [
  { value: 'recognize', label: 'Картки', Icon: Layers },
  { value: 'write', label: 'Написати', Icon: PenLine },
];

interface LexemeRow {
  id: string;
  lemma: string;
  ukrainian_translation: string;
  part_of_speech: string | null;
  audio_url: string | null;
  examples: unknown;
  cefr: string | null;
}

const toCard = (item: LexemeRow, theme: WordTheme | undefined): Card => ({
  id: item.id,
  hr_text: item.lemma,
  ua_translation: item.ukrainian_translation,
  phonetic_note: posLabelUk(item.part_of_speech) ?? '',
  audio_url: item.audio_url ?? undefined,
  example: firstExample(item.examples),
  level: item.cefr ?? theme?.level,
  theme: theme ?? null,
});

export default function TrainerPage() {
  const [cards, setCards] = useState<Card[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(false);
  const [levelChoice, setSelectedLevel] = useState<Level | null>(null);
  // Скільки всього слів користувач уже вчить і скільки чекають повторення (усі рівні)
  const [learningCount, setLearningCount] = useState(0);
  const [dueCount, setDueCount] = useState(0);
  const [modeChoice, setMode] = useState<Mode | null>(null);
  const [saveError, setSaveError] = useState(false);
  // Ключ сесії: новий набір карток → компонент тренажера починає з першої картки
  const [sessionKey, setSessionKey] = useState(0);
  // «Ще слова» / «Спробувати ще раз» — нове завантаження
  const [reloadKey, setReloadKey] = useState(0);
  // Режим і рівень запамʼятовуються між відвідуваннями (зручність одного користувача).
  // Збережене читаємо лише в браузері (на сервері й під час гідратації — undefined, «ще не готово»).
  const prefsRaw = useSyncExternalStore(noSubscribe, readPrefsRaw, () => undefined);
  const prefsReady = prefsRaw !== undefined;
  const savedPrefs = useMemo(() => parsePrefs(prefsRaw), [prefsRaw]);
  const mode: Mode = modeChoice ?? savedPrefs.mode ?? 'recognize';
  const selectedLevel: Level = levelChoice ?? savedPrefs.level ?? 'ALL';

  // Аналітика сесії тренажера
  const sessionRef = useRef({ startedAt: 0, rated: 0, correct: 0, kind: 'review' as SessionKind });
  const cardShownAtRef = useRef(0);

  const supabase = createClient();
  const router = useRouter();

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
      setLoadError(false);
      try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return;

        const nowMs = Date.now();

        // 1. Усі слова, які користувач уже вчить (пройдені в уроках або додані в словник)
        const { data: progressData, error: progressError } = await supabase
          .from('user_progress')
          .select('lexeme_id, next_review_date')
          .eq('user_id', user.id);

        if (progressError) throw progressError;

        // Спершу ті, що чекають повторення найдовше
        const progress = (progressData ?? [])
          .map(p => ({
            id: p.lexeme_id as string,
            dueAt: p.next_review_date ? new Date(p.next_review_date).getTime() : 0,
          }))
          .sort((a, b) => a.dueAt - b.dueAt);
        const dueIds = new Set(progress.filter(p => p.dueAt <= nowMs).map(p => p.id));
        const ordered = progress.map(p => p.id).slice(0, 300);

        // 2. Самі слова (лише чинні; за потреби — одного рівня)
        let rows: LexemeRow[] = [];
        if (ordered.length > 0) {
          let query = supabase
            .from('lexemes')
            .select(LEXEME_FIELDS)
            .in('id', ordered)
            // Лише чинні слова (речення й репліки перенесено в phrases / conversations → DEPRECATED)
            .eq('status', 'PUBLISHED');
          if (selectedLevel !== 'ALL') query = query.eq('cefr', selectedLevel);
          const { data, error } = await query;
          if (error) throw error;
          const byId = new Map(((data ?? []) as LexemeRow[]).map(row => [row.id, row]));
          rows = ordered.map(id => byId.get(id)).filter((r): r is LexemeRow => !!r);
        }

        // 3. Сесія: спершу слова «на сьогодні», потім — решта вивчених (повторити наперед)
        const lexemeData = rows.slice(0, SESSION_SIZE);
        const hasDue = lexemeData.some(r => dueIds.has(r.id));
        const kind: SessionKind = mode === 'write' ? 'write' : hasDue ? 'review' : 'practice';

        // 4. Тема слів сесії — емодзі модуля, де слово трапляється в уроках (не критично: без неї — літера)
        let themes = new Map<string, WordTheme>();
        if (lexemeData.length > 0) {
          const { data: links, error: linksError } = await supabase
            .from('lesson_items')
            .select(WORD_THEME_SELECT)
            .eq('item_type', 'lexeme')
            .eq('lessons.status', 'PUBLISHED')
            .in('item_id', lexemeData.map(r => r.id));
          if (linksError) console.warn('Тема слів не завантажилась:', linksError.message);
          else themes = wordThemes(links);
        }

        if (cancelled) return;
        setLearningCount(progress.length);
        setDueCount(dueIds.size);

        // Нова сесія: лічильники + подія review_started
        const now = Date.now();
        sessionRef.current = { startedAt: now, rated: 0, correct: 0, kind };
        cardShownAtRef.current = now;
        if (lexemeData.length > 0) {
          track('review_started', { level: selectedLevel, count: lexemeData.length, source: kind });
        }

        setCards(lexemeData.map(row => toCard(row, themes.get(row.id))));
        setSessionKey(now);
      } catch (err) {
        console.error('Помилка завантаження тренажера:', err);
        if (!cancelled) setLoadError(true);
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    fetchCards();
    return () => {
      cancelled = true;
    };
  }, [supabase, selectedLevel, mode, prefsReady, reloadKey]);

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

  const reload = () => setReloadKey(k => k + 1);
  const goToday = () => router.push('/');

  return (
    <div className="min-h-screen pb-28">
      <header className="mx-auto flex max-w-2xl flex-col gap-4 px-5 pt-[calc(2.5rem+env(safe-area-inset-top))] pb-4">
        <div>
          <h1 className="font-heading text-h1">Практика</h1>
          <PracticeTabs className="mt-2" />
        </div>

        {/* Режим тренування */}
        <div role="group" aria-label="Режим тренування" className="grid grid-cols-2 gap-1 rounded-control bg-surface-muted p-1">
          {MODES.map(({ value, label, Icon }) => {
            const active = mode === value;
            return (
              <button
                key={value}
                type="button"
                aria-pressed={active}
                onClick={() => setMode(value)}
                className={cn(
                  'flex min-h-11 items-center justify-center gap-2 rounded-control px-3 font-heading text-label transition-colors duration-150',
                  active ? 'bg-surface text-primary-ink shadow-sm' : 'text-ink-muted hover:text-ink',
                )}
              >
                <Icon className="size-5" aria-hidden="true" />
                {label}
              </button>
            );
          })}
        </div>

        {/* Рівень слів — у кольорі рівня (DESIGN_SYSTEM §3.4) */}
        <div role="group" aria-label="Рівень слів" className="flex rounded-control bg-surface-muted p-1">
          {LEVELS.map((lvl) => {
            const active = selectedLevel === lvl;
            return (
              <button
                key={lvl}
                type="button"
                aria-pressed={active}
                onClick={() => setSelectedLevel(lvl)}
                className={cn(
                  'flex min-h-11 flex-1 items-center justify-center rounded-control px-1 text-label transition-colors duration-150',
                  active
                    ? lvl === 'ALL' ? 'bg-surface text-ink shadow-sm' : cn(levelStyle(lvl).solid, 'shadow-sm')
                    : 'text-ink-muted hover:text-ink',
                )}
              >
                {lvl === 'ALL' ? 'Усі' : lvl}
              </button>
            );
          })}
        </div>

        {learningCount > 0 && (
          <p className="flex items-center gap-2 text-label font-normal text-ink-muted">
            <Repeat className="size-4 shrink-0 text-primary-ink" aria-hidden="true" />
            <span>
              Ви вчите {countUk(learningCount, ['слово', 'слова', 'слів'])}
              {dueCount > 0 ? ` · ${countUk(dueCount, ['чекає', 'чекають', 'чекають'])} повторення` : ' · усе повторено вчасно 🎉'}
            </span>
          </p>
        )}

        {saveError && (
          <p role="alert" className="rounded-card border border-danger-line bg-danger-soft px-4 py-3 text-label font-normal text-danger-ink">
            Не вдалося зберегти відповідь. Перевірте інтернет — наступні відповіді спробуємо зберегти знову.
          </p>
        )}
      </header>

      <main className="mx-auto max-w-2xl">
        {loading ? (
          <div className="mx-auto flex max-w-md flex-col gap-4 px-5 pt-2" aria-busy="true" aria-label="Підготовка карток">
            <Skeleton className="h-2 rounded-full" />
            <Skeleton className="h-[20rem] rounded-hero" />
            <Skeleton className="h-12 rounded-control" />
          </div>
        ) : loadError ? (
          <ErrorState onRetry={reload} />
        ) : cards.length === 0 ? (
          <EmptyState
            icon={<BookOpen className="size-6" aria-hidden="true" />}
            title={learningCount === 0 ? 'Тут з’являться ваші слова' : `На рівні ${selectedLevel} слів поки немає`}
            text={
              learningCount === 0
                ? 'Пройдіть урок — і його слова прийдуть сюди на повторення. Або додайте слова самі, коли читаєте тексти.'
                : 'Оберіть «Усі» або інший рівень — там уже є слова, які ви вчите.'
            }
            action={
              learningCount === 0 ? (
                <div className="flex flex-col gap-2">
                  <Button href="/lessons">До уроків</Button>
                  <Button href="/dictionary" variant="tertiary">
                    Відкрити словник
                  </Button>
                </div>
              ) : (
                <Button variant="secondary" onClick={() => setSelectedLevel('ALL')}>
                  Показати всі рівні
                </Button>
              )
            }
          />
        ) : mode === 'write' ? (
          <WriteTrainer key={sessionKey} cards={cards} onAnswer={handleWriteAnswer} onFinishSession={goToday} onRestart={reload} />
        ) : (
          <FlashcardTrainer key={sessionKey} cards={cards} onFinishSession={goToday} onRateCard={handleRateCard} onRestart={reload} />
        )}
      </main>
    </div>
  );
}
