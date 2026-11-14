'use client';

import React, { useEffect, useState, useCallback, useRef } from 'react';
import { BookmarkPlus, Check, CircleCheck, Search, X } from 'lucide-react';
import { createClient } from '@/utils/supabase/client';
import { saveDictionaryWord } from '@/app/actions/dictionary';
import PracticeTabs from '@/components/ui/PracticeTabs';
import { dictionarySearchTerm, posLabelUk } from '@/lib/format';
import { LEVEL_CODES, levelStyle } from '@/lib/levels';
import {
  WORD_CATEGORIES, adultContentFrom, categoryFilter, emptyCategoryText, labelChips, readLabels, type LexemeLabels, type WordCategory,
} from '@/lib/lexeme-labels';
import { cn } from '@/lib/ui';
import { WORD_THEME_SELECT, wordThemes, type WordTheme } from '@/lib/word-theme';
import { wordExamples } from '@/lib/word-save';
import AudioButton from '@/components/ui/AudioButton';
import Button from '@/components/ui/Button';
import EmptyState from '@/components/ui/EmptyState';
import ErrorState from '@/components/ui/ErrorState';
import Hr from '@/components/ui/Hr';
import IconButton from '@/components/ui/IconButton';
import LevelBadge from '@/components/ui/LevelBadge';
import Skeleton from '@/components/ui/Skeleton';
import WordLabels from '@/components/ui/WordLabels';
import WordTile from '@/components/ui/WordTile';

const PAGE_SIZE = 30; // Розмір однієї порції слів
const LEVELS = ['ALL', ...LEVEL_CODES] as const;
type Level = (typeof LEVELS)[number];

interface Word {
  id: string;
  lemma: string;
  translation: string;
  pos: string | null;
  level: string | null;
  explanation: string | null;
  examples: string[];
  /** Мітки живої лексики (M24 / M25): регістр, регіон, ознаки */
  labels: LexemeLabels;
  /** Стандартний відповідник (`standard_lexeme_id`), якщо слово розмовне / регіональне */
  standardId: string | null;
}

/** Стан кнопки «Додати в повторення» в картці слова: текст — помилка. */
type SaveState = 'idle' | 'saving' | 'saved' | string;

/**
 * Словник (розділ «Практика»): пошук по всьому словнику, фільтри за рівнем і категорією (розмовне, сленг, регіональне…).
 * Біля слова — емодзі теми уроку в кольорі рівня, бейдж рівня, частина мови, «Вчу», позначка категорії (DESIGN_SYSTEM §3.4).
 * Натиск на слово — картка знизу: переклад, позначка категорії й «стандартно: …», пояснення, приклади й «Додати в повторення».
 * Слова `vulgar` (модуль «18+») — лише тим, хто ввімкнув «Показувати контент 18+» у профілі (`profiles.adult_content`, M26).
 */
export default function DictionaryPage() {
  const supabase = createClient();

  const [words, setWords] = useState<Word[]>([]);
  const [loading, setLoading] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [loadError, setLoadError] = useState(false);
  const [searchQuery, setSearchQuery] = useState('');
  // Пошук іде в базі по всьому словнику, із затримкою 300 мс
  const [term, setTerm] = useState<string | null>(null);
  const [level, setLevel] = useState<Level>('ALL');
  const [category, setCategory] = useState<WordCategory>('all');
  const requestRef = useRef(0); // відповідь старішого запиту (попередній пошук) не перезаписує новішу
  const [page, setPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);
  // Доповнення до слів (не критичні: без них — літера замість емодзі й без позначки «Вчу»)
  const [themes, setThemes] = useState<Map<string, WordTheme>>(new Map());
  const [learning, setLearning] = useState<Set<string>>(new Set());
  const [standardLemmas, setStandardLemmas] = useState<Map<string, string>>(new Map()); // id відповідника → лема
  const userIdRef = useRef<string | null | undefined>(undefined);
  // «Показувати контент 18+» з профілю: читаємо раз перед першим запитом; немає входу / колонки / збій — вимкнено
  const adultRef = useRef<Promise<boolean> | null>(null);
  const adultContent = useCallback(() => {
    adultRef.current ??= (async () => {
      try {
        const { data: { user } } = await supabase.auth.getUser();
        if (!user) return false;
        const { data, error } = await supabase.from('profiles').select('adult_content').eq('id', user.id).maybeSingle();
        return error ? false : adultContentFrom(data);
      } catch {
        return false;
      }
    })();
    return adultRef.current;
  }, [supabase]);
  // Картка слова (натиск на слово) і стан кнопки «Додати в повторення»
  const [selected, setSelected] = useState<Word | null>(null);
  const [saveState, setSaveState] = useState<SaveState>('idle');

  /** Тема (емодзі модуля), «Вчу» і стандартні відповідники для нової порції слів. */
  const enrich = useCallback(async (batch: Word[]) => {
    if (batch.length === 0) return;
    const ids = batch.map(w => w.id);
    const standardIds = [...new Set(batch.map(w => w.standardId).filter((id): id is string => !!id))];
    try {
      if (userIdRef.current === undefined) {
        const { data: { user } } = await supabase.auth.getUser();
        userIdRef.current = user?.id ?? null;
      }
      const userId = userIdRef.current;
      const [links, progress, standards] = await Promise.all([
        supabase
          .from('lesson_items')
          .select(WORD_THEME_SELECT)
          .eq('item_type', 'lexeme')
          .eq('lessons.status', 'PUBLISHED')
          .in('item_id', ids),
        userId
          ? supabase.from('user_progress').select('lexeme_id').eq('user_id', userId).in('lexeme_id', ids)
          : Promise.resolve({ data: [], error: null }),
        standardIds.length
          ? supabase.from('lexemes').select('id, lemma').eq('status', 'PUBLISHED').in('id', standardIds)
          : Promise.resolve({ data: [], error: null }),
      ]);
      if (!links.error) {
        const found = wordThemes(links.data);
        setThemes(prev => new Map([...prev, ...found]));
      }
      if (!progress.error && progress.data) {
        const mine = (progress.data as { lexeme_id: string }[]).map(p => p.lexeme_id);
        setLearning(prev => new Set([...prev, ...mine]));
      }
      if (!standards.error && standards.data && standards.data.length > 0) {
        const found = (standards.data as { id: string; lemma: string }[]).map(r => [r.id, r.lemma] as const);
        setStandardLemmas(prev => new Map([...prev, ...found]));
      }
    } catch (err) {
      console.warn('Тема слів / «Вчу» / стандартні відповідники не завантажились:', err);
    }
  }, [supabase]);

  /** Початок завантаження: індикатори й номер сторінки. Викликають обробники (зміна пошуку / рівня, «Ще»),
   *  а не ефект — щоб не було синхронного setState в ефекті (react-hooks/set-state-in-effect). */
  const beginLoad = useCallback((pageIndex: number, isReset: boolean) => {
    if (isReset) setLoading(true);
    else setLoadingMore(true);
    setLoadError(false);
    setPage(pageIndex);
  }, []);

  /** Запит однієї порції слів (лише читання з бази, стан не змінює). Помилка бази — виняток. */
  const queryWords = useCallback(async (pageIndex: number, search: string | null, lvl: Level, cat: WordCategory): Promise<Word[]> => {
    const from = pageIndex * PAGE_SIZE;
    const to = from + PAGE_SIZE - 1;
    const adult = await adultContent();
    let request = supabase
      .from('lexemes')
      .select('id, lemma, ukrainian_translation, part_of_speech, cefr, ukrainian_explanation, examples, register, regionality, usage_tags, standard_lexeme_id')
      .eq('status', 'PUBLISHED')
      .not('lemma', 'like', '%:%'); // без реплік діалогів («Konobar: …»)
    if (!adult) request = request.neq('register', 'vulgar'); // контент 18+ — лише з перемикачем у профілі
    if (search) {
      // лема, лема без діакритики (macka → mačka) або переклад
      request = request.or(`lemma.ilike.%${search}%,normalized.ilike.%${search}%,ukrainian_translation.ilike.%${search}%`);
    }
    if (lvl !== 'ALL') request = request.eq('cefr', lvl);
    const filter = categoryFilter(cat);
    if (filter) {
      if (filter.method === 'or') request = request.or(filter.value);
      else if (filter.method === 'eq') request = request.eq(filter.column, filter.value);
      else if (filter.method === 'neq') request = request.neq(filter.column, filter.value);
      else if (filter.method === 'overlaps') request = request.overlaps(filter.column, filter.value);
      else request = request.contains(filter.column, filter.value);
    }
    const { data, error } = await request
      .order('cefr', { ascending: true, nullsFirst: false }) // спершу A0, потім A1…
      .order('frequency_rank', { ascending: true, nullsFirst: false })
      .order('lemma', { ascending: true })
      .range(from, to); // Пагінація на рівні БД
    if (error) throw error;
    return (data ?? []).map((lex) => ({
      id: lex.id,
      lemma: lex.lemma,
      translation: lex.ukrainian_translation,
      pos: posLabelUk(lex.part_of_speech),
      level: lex.cefr,
      explanation: lex.ukrainian_explanation ?? null,
      examples: wordExamples(lex.examples),
      labels: readLabels(lex),
      standardId: typeof lex.standard_lexeme_id === 'string' ? lex.standard_lexeme_id : null,
    }));
  }, [supabase, adultContent]);

  /** Відповідь бази → стан. Відповідь старішого запиту (попередній пошук) ігноруємо. */
  const applyPage = useCallback((requestId: number, isReset: boolean, result: { words: Word[] } | { error: unknown }) => {
    if (requestId !== requestRef.current) return;
    if ('error' in result) {
      console.error('Помилка завантаження словника:', result.error);
      if (isReset) setWords([]); // старі результати іншого пошуку не показуємо
      setLoadError(true);
    } else {
      const mapped = result.words;
      setHasMore(mapped.length === PAGE_SIZE); // менше за порцію — кінець словника чи результатів
      setWords(prev => (isReset ? mapped : [...prev, ...mapped]));
      void enrich(mapped);
    }
    setLoading(false);
    setLoadingMore(false);
  }, [enrich]);

  /** Порція слів для обробників («Ще», «Спробувати ще раз»): індикатор → запит → стан у колбеці. */
  const loadPage = (pageIndex: number, isReset: boolean) => {
    beginLoad(pageIndex, isReset);
    const requestId = ++requestRef.current;
    queryWords(pageIndex, term, level, category).then(
      (found) => applyPage(requestId, isReset, { words: found }),
      (error: unknown) => applyPage(requestId, isReset, { error }),
    );
  };

  // Затримка: шукаємо, коли користувач перестав друкувати
  useEffect(() => {
    const timer = setTimeout(() => {
      const next = dictionarySearchTerm(searchQuery);
      if (next === term) return;
      beginLoad(0, true);
      setTerm(next);
    }, 300);
    return () => clearTimeout(timer);
  }, [searchQuery, term, beginLoad]);

  // Новий пошук або рівень → перша порція. Індикатор уже ввімкнено в обробнику (на старті loading = true),
  // стан змінюємо лише в колбеці відповіді — як радить React для синхронізації із зовнішньою системою.
  useEffect(() => {
    const requestId = ++requestRef.current;
    queryWords(0, term, level, category).then(
      (found) => applyPage(requestId, true, { words: found }),
      (error: unknown) => applyPage(requestId, true, { error }),
    );
  }, [queryWords, applyPage, term, level, category]);

  const selectLevel = (lvl: Level) => {
    if (lvl === level) return;
    beginLoad(0, true);
    setLevel(lvl);
  };

  const selectCategory = (cat: WordCategory) => {
    if (cat === category) return;
    beginLoad(0, true);
    setCategory(cat);
  };

  const loadMore = () => {
    if (loadingMore || !hasMore) return;
    loadPage(page + 1, false);
  };

  const openWord = (word: Word) => {
    setSelected(word);
    setSaveState('idle');
  };

  const closeWord = () => setSelected(null);

  // Escape закриває картку слова
  useEffect(() => {
    if (!selected) return;
    const onKey = (e: KeyboardEvent) => {
      if (e.key === 'Escape') setSelected(null);
    };
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, [selected]);

  const saveWord = async (word: Word) => {
    setSaveState('saving');
    try {
      const res = await saveDictionaryWord(word.id, category);
      if (res.ok) {
        setSaveState('saved');
        setLearning(prev => new Set(prev).add(word.id));
      } else {
        setSaveState(res.error);
      }
    } catch {
      setSaveState('Не вдалося додати слово. Перевірте інтернет.');
    }
  };

  const retry = () => {
    if (words.length > 0) loadPage(page, false);
    else loadPage(0, true);
  };

  return (
    <div className="min-h-screen pb-28">
      <header className="mx-auto max-w-2xl px-5 pt-[calc(2.5rem+env(safe-area-inset-top))]">
        <h1 className="font-heading text-h1">Практика</h1>
        <PracticeTabs className="mt-2" />
      </header>

      {/* Пошук і рівень — лишаються вгорі під час гортання */}
      <div className="sticky top-0 z-20 border-b border-line bg-canvas/95 px-5 pt-4 pb-3">
        <div className="mx-auto flex max-w-2xl flex-col gap-3">
          <div className="relative">
            <label htmlFor="dictionary-search" className="sr-only">
              Пошук слова
            </label>
            <Search className="pointer-events-none absolute top-1/2 left-4 size-5 -translate-y-1/2 text-ink-subtle" aria-hidden="true" />
            <input
              id="dictionary-search"
              type="search"
              placeholder="Слово або переклад…"
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              autoComplete="off"
              className="min-h-12 w-full rounded-control border border-line bg-surface pr-12 pl-12 text-body placeholder:text-ink-subtle focus:border-primary [&::-webkit-search-cancel-button]:hidden"
            />
            {searchQuery && (
              <IconButton label="Очистити пошук" onClick={() => setSearchQuery('')} className="absolute top-1/2 right-1 -translate-y-1/2">
                <X className="size-5" aria-hidden="true" />
              </IconButton>
            )}
          </div>

          <div role="group" aria-label="Рівень слів" className="flex rounded-control bg-surface-muted p-1">
            {LEVELS.map((lvl) => {
              const active = level === lvl;
              return (
                <button
                  key={lvl}
                  type="button"
                  aria-pressed={active}
                  onClick={() => selectLevel(lvl)}
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
        </div>
      </div>

      <main className="mx-auto max-w-2xl px-5 pt-4">
        {/* Категорія: розмовне, сленг, регіональне… (рішення власника 2026-11-13) — гортається вбік */}
        <div className="-mx-5 mb-4 overflow-x-auto px-5 [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
          <div role="group" aria-label="Категорія слів" className="flex w-max gap-2">
            {WORD_CATEGORIES.map((c) => {
              const active = category === c.id;
              return (
                <button
                  key={c.id}
                  type="button"
                  aria-pressed={active}
                  onClick={() => selectCategory(c.id)}
                  className={cn(
                    'flex min-h-11 items-center gap-1 rounded-full border px-4 text-label whitespace-nowrap transition-colors duration-150',
                    active ? 'border-primary bg-primary text-white shadow-sm' : 'border-line bg-surface text-ink-muted hover:text-ink',
                  )}
                >
                  {active && c.id !== 'all' && <Check className="size-4" strokeWidth={3} aria-hidden="true" />}
                  {c.label}
                </button>
              );
            })}
          </div>
        </div>

        <div className="mb-3 flex items-baseline justify-between gap-3">
          <h2 className="font-heading text-h3">
            {term ? 'Результати пошуку' : level === 'ALL' ? 'Усі слова' : `${level} · ${levelStyle(level).name}`}
            {category !== 'all' && <span className="text-ink-muted"> · {categoryName(category)}</span>}
          </h2>
          {!loading && words.length > 0 && <p className="text-caption text-ink-subtle">Показано {words.length}</p>}
        </div>

        {loading ? (
          <div className="grid gap-3 sm:grid-cols-2" aria-busy="true" aria-label="Завантаження словника">
            {Array.from({ length: 6 }, (_, i) => (
              <Skeleton key={i} className="h-24" />
            ))}
          </div>
        ) : loadError && words.length === 0 ? (
          <ErrorState onRetry={retry} />
        ) : words.length > 0 ? (
          <>
            <ul className="grid gap-3 sm:grid-cols-2">
              {words.map((word) => (
                <WordRow key={word.id} word={word} theme={themes.get(word.id)} isLearning={learning.has(word.id)} onOpen={openWord} />
              ))}
            </ul>

            {loadError && (
              <p role="alert" className="mt-4 rounded-card border border-danger-line bg-danger-soft px-4 py-3 text-label font-normal text-danger-ink">
                Не вдалося завантажити ще слова. Перевірте інтернет і натисніть «Показати ще».
              </p>
            )}

            {hasMore ? (
              <Button variant="secondary" block className="mt-4" onClick={loadError ? retry : loadMore} loading={loadingMore}>
                {loadingMore ? 'Завантаження…' : `Показати ще ${PAGE_SIZE} слів`}
              </Button>
            ) : (
              <p className="mt-6 text-center text-label font-normal text-ink-muted">
                {term
                  ? 'Це всі слова за вашим пошуком.'
                  : category !== 'all'
                    ? `Це всі слова категорії «${categoryName(category)}» 🎉`
                    : level === 'ALL' ? 'Ви переглянули весь словник 🎉' : `Це всі слова рівня ${level} 🎉`}
              </p>
            )}
          </>
        ) : (
          <EmptyState
            icon={<Search className="size-6" aria-hidden="true" />}
            title="Слів не знайдено"
            text={
              category !== 'all'
                ? emptyCategoryText(category)
                : level !== 'ALL'
                  ? `На рівні ${level} такого слова немає. Спробуйте «Усі» рівні.`
                  : 'Спробуйте інше написання — можна без хорватських літер (macka → mačka) або українською.'
            }
            action={
              category !== 'all' ? (
                <Button variant="secondary" onClick={() => selectCategory('all')}>
                  Показати всі категорії
                </Button>
              ) : level !== 'ALL' ? (
                <Button variant="secondary" onClick={() => selectLevel('ALL')}>
                  Шукати на всіх рівнях
                </Button>
              ) : undefined
            }
          />
        )}
      </main>

      {selected && (
        <WordSheet
          word={selected}
          theme={themes.get(selected.id)}
          standardLemma={selected.standardId ? standardLemmas.get(selected.standardId) ?? null : null}
          isLearning={learning.has(selected.id)}
          saveState={saveState}
          onSave={() => void saveWord(selected)}
          onClose={closeWord}
        />
      )}
    </div>
  );
}

function categoryName(category: WordCategory): string {
  return WORD_CATEGORIES.find((c) => c.id === category)?.label ?? '';
}

function WordRow({ word, theme, isLearning, onOpen }: { word: Word; theme?: WordTheme; isLearning: boolean; onOpen: (word: Word) => void }) {
  // aria-label кнопки замінює її вміст для читача з екрана — тож категорію називаємо в ньому
  const labelsText = labelChips(word.labels).map((c) => c.text).join(', ');
  return (
    <li className="flex items-center gap-1 rounded-card border border-line bg-surface shadow-sm transition-colors duration-150 hover:border-primary">
      <button
        type="button"
        onClick={() => onOpen(word)}
        aria-label={`${word.lemma} — ${word.translation}${labelsText ? `, ${labelsText}` : ''}${isLearning ? ', вчу' : ''}. Відкрити картку слова`}
        className="flex min-w-0 flex-1 items-center gap-3 rounded-card p-4 text-left"
      >
        <WordTile lemma={word.lemma} level={word.level} theme={theme} />
        <span className="block min-w-0 flex-1">
          <Hr className="block font-heading text-h3 break-words text-ink">{word.lemma}</Hr>
          <span className="block text-body break-words text-ink-muted">{word.translation}</span>
          <span className="mt-1.5 flex flex-wrap items-center gap-x-2 gap-y-1">
            {word.level && <LevelBadge level={word.level} />}
            {word.pos && <span className="text-caption text-ink-subtle">{word.pos}</span>}
            {isLearning && <LearningBadge />}
          </span>
          <WordLabels labels={word.labels} className="mt-1.5" />
        </span>
      </button>
      <AudioButton text={word.lemma} label={`Прослухати: ${word.lemma}`} className="mr-3" />
    </li>
  );
}

function LearningBadge() {
  return (
    <span className="inline-flex items-center gap-1 rounded-full bg-success-soft px-2 py-0.5 text-caption font-semibold text-success-ink">
      <Check className="size-3.5" strokeWidth={3} aria-hidden="true" />
      Вчу
    </span>
  );
}

/** Картка слова знизу: переклад, пояснення, приклади, «Додати в повторення». */
function WordSheet({
  word,
  theme,
  standardLemma,
  isLearning,
  saveState,
  onSave,
  onClose,
}: {
  word: Word;
  theme?: WordTheme;
  standardLemma: string | null;
  isLearning: boolean;
  saveState: SaveState;
  onSave: () => void;
  onClose: () => void;
}) {
  const error = saveState !== 'idle' && saveState !== 'saving' && saveState !== 'saved' ? saveState : null;
  return (
    <div className="fixed inset-0 z-50 flex items-end justify-center">
      <button type="button" aria-label="Закрити картку слова" onClick={onClose} className="absolute inset-0 cursor-default bg-ink/40" />
      <div
        role="dialog"
        aria-modal="true"
        aria-labelledby="word-sheet-title"
        className="relative w-full max-w-2xl rounded-t-hero border border-line bg-surface p-5 pb-[calc(1.25rem+env(safe-area-inset-bottom))] shadow-md animate-fade-in-up"
      >
        <div className="flex items-start gap-3">
          <WordTile lemma={word.lemma} level={word.level} theme={theme} />
          <div className="min-w-0 flex-1">
            <Hr as="h2" id="word-sheet-title" className="font-heading text-word break-words">
              {word.lemma}
            </Hr>
            <div className="mt-0.5 flex flex-wrap items-center gap-x-2 gap-y-1">
              {word.level && <LevelBadge level={word.level} />}
              {word.pos && <span className="text-caption text-ink-muted">{word.pos}</span>}
              {isLearning && <LearningBadge />}
            </div>
          </div>
          <AudioButton text={word.lemma} label={`Прослухати: ${word.lemma}`} />
          <IconButton label="Закрити картку слова" onClick={onClose}>
            <X className="size-5" aria-hidden="true" />
          </IconButton>
        </div>

        <WordLabels labels={word.labels} standardLemma={standardLemma} className="mt-3" />
        <p className="mt-3 text-body-lg break-words">{word.translation}</p>
        {word.explanation && <p className="mt-1 text-label font-normal break-words text-ink-muted">{word.explanation}</p>}

        {word.examples.length > 0 && (
          <ul className="mt-3 flex flex-col gap-1.5" aria-label="Приклади">
            {word.examples.map((ex) => (
              <li key={ex} className="flex items-center gap-2 rounded-control bg-surface-muted py-1 pr-1 pl-3">
                <Hr className="min-w-0 flex-1 text-body">{ex}</Hr>
                <AudioButton text={ex} label={`Прослухати приклад: ${ex}`} />
              </li>
            ))}
          </ul>
        )}

        <div className="mt-4">
          {saveState === 'saved' ? (
            <p className="flex items-center gap-2 text-label text-success-ink" role="status">
              <CircleCheck className="size-5" aria-hidden="true" />
              Додано в повторення — слово з’явиться в «Тренажері» сьогодні
            </p>
          ) : isLearning ? (
            <p className="flex items-center gap-2 text-label text-success-ink" role="status">
              <CircleCheck className="size-5" aria-hidden="true" />
              Ви вже вчите це слово — воно в «Тренажері»
            </p>
          ) : (
            <>
              <Button block onClick={onSave} loading={saveState === 'saving'}>
                <BookmarkPlus className="size-5" aria-hidden="true" />
                Додати в повторення
              </Button>
              {error && (
                <p className="mt-2 text-label text-danger-ink" role="alert">
                  {error}
                </p>
              )}
            </>
          )}
        </div>
      </div>
    </div>
  );
}
