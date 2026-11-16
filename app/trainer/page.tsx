'use client';

import { useEffect, useMemo, useRef, useState, useSyncExternalStore } from 'react';
import { useRouter } from 'next/navigation';
import { BookOpen, Layers, PenLine, Repeat, WifiOff } from 'lucide-react';
import FlashcardTrainer, { Flashcard } from '@/components/FlashcardTrainer';
import WriteTrainer, { WriteCard } from '@/components/WriteTrainer';
import { createClient } from '@/utils/supabase/client';
import { rateFlashcard } from '@/app/actions/srs';
import { track } from '@/lib/analytics-client';
import { browserStorage, readOfflineCopy, saveOfflineCopy } from '@/lib/offline-copy';
import { currentUserId, failedForNetwork, isBrowserOffline, queueProgress } from '@/lib/offline-client';
import {
  buildDeck, deckDueCount, deckKey, dueAtFromRow, isDue, isTrainerDeck, pickSession, rateInDeck, srsFromRow,
  DECK_SIZE, type DeckEntry, type ProgressRow, type SessionKind, type TrainerDeck,
} from '@/lib/trainer-deck';
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
 *
 * Без мережі (офлайн, етап 2, 2026-11-16): онлайн кожне відкриття зберігає копію колоди на телефоні
 * (lib/trainer-deck.ts), без мережі сесія — з неї; оцінки — у черзі (srs_rating), відправляє OfflineSync.
 */
type Mode = 'recognize' | 'write';
type Card = Flashcard & WriteCard;
// v2: типовий рівень став «Усі» (старі збережені налаштування з рівнем A1 ігноруємо)
const PREFS_KEY = 'cs_trainer_prefs_v2';
const LEXEME_FIELDS = 'id, lemma, ukrainian_translation, part_of_speech, audio_url, examples, cefr';
const PROGRESS_FIELDS = 'lexeme_id, next_review_date, ease_factor, interval_days, repetition_count, lapses';
/** Скільки слів беремо з бази за раз (найдавніші «на повторення») */
const FETCH_LIMIT = 300;
const THEME_CHUNK = 150;

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
  // Сесія з копії на телефоні (без мережі) / відповіді чекають у черзі
  const [offline, setOffline] = useState(false);
  const [queued, setQueued] = useState(false);
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
  // Копія колоди на телефоні (оновлюється з кожною оцінкою)
  const deckRef = useRef<TrainerDeck | null>(null);

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

    /** Нова сесія: лічильники, подія review_started, картки. */
    function startSession(cards: Card[], kind: SessionKind, learning: number, due: number, fromPhone: boolean) {
      if (cancelled) return;
      setLearningCount(learning);
      setDueCount(due);
      setOffline(fromPhone);
      const now = Date.now();
      sessionRef.current = { startedAt: now, rated: 0, correct: 0, kind };
      cardShownAtRef.current = now;
      if (cards.length > 0) {
        track('review_started', { level: selectedLevel, count: cards.length, source: kind });
      }
      setCards(cards);
      setSessionKey(now);
    }

    /** Без мережі — сесія з копії колоди на телефоні. false — копії немає. */
    function startFromPhone(userId: string | null): boolean {
      if (!userId) return false;
      const copy = readOfflineCopy(browserStorage(), deckKey(userId), isTrainerDeck);
      if (!copy || copy.data.userId !== userId) return false;
      deckRef.current = copy.data;
      const now = Date.now();
      const session = pickSession(copy.data.entries, selectedLevel, mode, now);
      startSession(session.cards as Card[], session.kind, copy.data.learningCount, deckDueCount(copy.data, now), true);
      return true;
    }

    async function fetchCards() {
      setLoading(true);
      setLoadError(false);
      try {
        // Браузер знає, що мережі немає, — одразу з телефона
        if (isBrowserOffline() && startFromPhone(currentUserId())) return;

        const { data: { user }, error: authError } = await supabase.auth.getUser();
        if (!user) {
          if (authError && failedForNetwork(authError)) throw authError; // немає зв'язку — спробуємо копію
          return;
        }

        const nowMs = Date.now();

        // 1. Усі слова, які користувач уже вчить (пройдені в уроках або додані в словник)
        const { data: progressData, error: progressError } = await supabase
          .from('user_progress')
          .select(PROGRESS_FIELDS)
          .eq('user_id', user.id);

        if (progressError) throw progressError;

        // Спершу ті, що чекають повторення найдовше
        const progress = ((progressData ?? []) as ProgressRow[])
          .map(p => ({ id: p.lexeme_id, dueAt: dueAtFromRow(p), srs: srsFromRow(p) }))
          .sort((a, b) => a.dueAt - b.dueAt);
        const dueTotal = progress.filter(p => p.dueAt <= nowMs).length;
        const ordered = progress.slice(0, FETCH_LIMIT);

        // 2. Самі слова (лише чинні; рівень фільтруємо вже тут — копія на телефоні потрібна для всіх рівнів)
        let rows: LexemeRow[] = [];
        if (ordered.length > 0) {
          const { data, error } = await supabase
            .from('lexemes')
            .select(LEXEME_FIELDS)
            .in('id', ordered.map(p => p.id))
            // Лише чинні слова (речення й репліки перенесено в phrases / conversations → DEPRECATED)
            .eq('status', 'PUBLISHED');
          if (error) throw error;
          rows = (data ?? []) as LexemeRow[];
        }
        const byId = new Map(rows.map(row => [row.id, row]));
        const bare: DeckEntry[] = ordered.flatMap(p => {
          const row = byId.get(p.id);
          return row ? [{ card: toCard(row, undefined), cefr: row.cefr, dueAt: p.dueAt, srs: p.srs }] : [];
        });

        // 3. Сесія: спершу слова «на сьогодні», потім — решта вивчених (повторити наперед)
        const session = pickSession(bare, selectedLevel, mode, nowMs);
        const deckIds = bare.slice(0, DECK_SIZE).map(e => e.card.id);

        // 4. Тема слів сесії й копії — емодзі модуля, де слово трапляється в уроках (не критично: без неї — літера)
        const themeIds = Array.from(new Set([...session.cards.map(c => c.id), ...deckIds]));
        let themes = new Map<string, WordTheme>();
        if (themeIds.length > 0) {
          const links: unknown[] = [];
          for (let i = 0; i < themeIds.length; i += THEME_CHUNK) {
            const { data, error: linksError } = await supabase
              .from('lesson_items')
              .select(WORD_THEME_SELECT)
              .eq('item_type', 'lexeme')
              .eq('lessons.status', 'PUBLISHED')
              .in('item_id', themeIds.slice(i, i + THEME_CHUNK));
            if (linksError) {
              console.warn('Тема слів не завантажилась:', linksError.message);
              break;
            }
            links.push(...(data ?? []));
          }
          themes = wordThemes(links);
        }
        const entries: DeckEntry[] = bare.map(e => ({ ...e, card: toCard(byId.get(e.card.id)!, themes.get(e.card.id)) }));
        const themed = new Map(entries.map(e => [e.card.id, e.card as Card]));

        // 5. Копія колоди на телефоні — для тренажера без мережі
        const deck = buildDeck(user.id, entries, progress.length, nowMs);
        deck.dueOutside = Math.max(0, dueTotal - deck.entries.filter(e => isDue(e, nowMs)).length);
        deckRef.current = deck;
        saveOfflineCopy(browserStorage(), deckKey(user.id), deck);

        startSession(session.cards.map(c => themed.get(c.id) ?? (c as Card)), session.kind, progress.length, dueTotal, false);
      } catch (err) {
        if (!cancelled && startFromPhone(currentUserId())) return;
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

    // Копія колоди на телефоні — тим самим розкладом: щойно повторене без мережі не повернеться «на сьогодні»
    if (deckRef.current) {
      deckRef.current = rateInDeck(deckRef.current, cardId, correct, new Date(now));
      saveOfflineCopy(browserStorage(), deckKey(deckRef.current.userId), deckRef.current);
    }

    const rating = correct ? 1 : 0;
    const queue = () => {
      const ok = queueProgress('srs_rating', { target: 'lexeme', lexeme_id: cardId, rating, response_time_ms: responseTimeMs });
      if (ok) {
        setQueued(true);
        setSaveError(false);
      }
      return ok;
    };
    // Сесія з телефона або мережі точно немає — одразу в чергу
    if ((offline || isBrowserOffline()) && queue()) return;
    try {
      await rateFlashcard(cardId, rating, responseTimeMs);
      setSaveError(false);
    } catch (error) {
      if (failedForNetwork(error) && queue()) return;
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

        {(offline || queued) && !saveError && (
          <p role="status" className="flex items-start gap-2 rounded-card border border-warning-line bg-warning-soft px-4 py-3 text-label font-normal text-warning-ink">
            <WifiOff className="mt-0.5 size-4 shrink-0" aria-hidden="true" />
            <span>
              {offline ? 'Без інтернету: картки з телефона. ' : ''}Відповіді збережемо, щойно з’явиться інтернет.
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
