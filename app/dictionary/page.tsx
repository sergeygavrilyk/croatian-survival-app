'use client';

import React, { useEffect, useState, useCallback, useRef } from 'react';
import { Check, Search, X } from 'lucide-react';
import { createClient } from '@/utils/supabase/client';
import PracticeTabs from '@/components/ui/PracticeTabs';
import { dictionarySearchTerm, posLabelUk } from '@/lib/format';
import { LEVEL_CODES, levelStyle } from '@/lib/levels';
import { cn } from '@/lib/ui';
import { WORD_THEME_SELECT, wordThemes, type WordTheme } from '@/lib/word-theme';
import AudioButton from '@/components/ui/AudioButton';
import Button from '@/components/ui/Button';
import EmptyState from '@/components/ui/EmptyState';
import ErrorState from '@/components/ui/ErrorState';
import Hr from '@/components/ui/Hr';
import IconButton from '@/components/ui/IconButton';
import LevelBadge from '@/components/ui/LevelBadge';
import Skeleton from '@/components/ui/Skeleton';
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
}

/**
 * Словник (розділ «Практика»): пошук по всьому словнику, фільтр за рівнем.
 * Біля слова — емодзі теми уроку в кольорі рівня, бейдж рівня, частина мови, «Вчу» (DESIGN_SYSTEM §3.4).
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
  const requestRef = useRef(0); // відповідь старішого запиту (попередній пошук) не перезаписує новішу
  const [page, setPage] = useState(0);
  const [hasMore, setHasMore] = useState(true);
  // Доповнення до слів (не критичні: без них — літера замість емодзі й без позначки «Вчу»)
  const [themes, setThemes] = useState<Map<string, WordTheme>>(new Map());
  const [learning, setLearning] = useState<Set<string>>(new Set());
  const userIdRef = useRef<string | null | undefined>(undefined);

  /** Тема (емодзі модуля) і «Вчу» для нової порції слів. */
  const enrich = useCallback(async (ids: string[]) => {
    if (ids.length === 0) return;
    try {
      if (userIdRef.current === undefined) {
        const { data: { user } } = await supabase.auth.getUser();
        userIdRef.current = user?.id ?? null;
      }
      const userId = userIdRef.current;
      const [links, progress] = await Promise.all([
        supabase
          .from('lesson_items')
          .select(WORD_THEME_SELECT)
          .eq('item_type', 'lexeme')
          .eq('lessons.status', 'PUBLISHED')
          .in('item_id', ids),
        userId
          ? supabase.from('user_progress').select('lexeme_id').eq('user_id', userId).in('lexeme_id', ids)
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
    } catch (err) {
      console.warn('Тема слів / «Вчу» не завантажились:', err);
    }
  }, [supabase]);

  // Порційне завантаження з точковими полями
  const fetchWords = useCallback(async (pageIndex: number, isReset: boolean, search: string | null, lvl: Level) => {
    if (isReset) setLoading(true);
    else setLoadingMore(true);
    setLoadError(false);

    const requestId = ++requestRef.current;
    const from = pageIndex * PAGE_SIZE;
    const to = from + PAGE_SIZE - 1;

    try {
      let request = supabase
        .from('lexemes')
        .select('id, lemma, ukrainian_translation, part_of_speech, cefr')
        .eq('status', 'PUBLISHED')
        .not('lemma', 'like', '%:%'); // без реплік діалогів («Konobar: …»)
      if (search) {
        // лема, лема без діакритики (macka → mačka) або переклад
        request = request.or(`lemma.ilike.%${search}%,normalized.ilike.%${search}%,ukrainian_translation.ilike.%${search}%`);
      }
      if (lvl !== 'ALL') request = request.eq('cefr', lvl);
      const { data, error } = await request
        .order('cefr', { ascending: true, nullsFirst: false }) // спершу A0, потім A1…
        .order('frequency_rank', { ascending: true, nullsFirst: false })
        .order('lemma', { ascending: true })
        .range(from, to); // Пагінація на рівні БД

      if (error) throw error;
      if (requestId !== requestRef.current) return;

      const mapped: Word[] = (data ?? []).map((lex) => ({
        id: lex.id,
        lemma: lex.lemma,
        translation: lex.ukrainian_translation,
        pos: posLabelUk(lex.part_of_speech),
        level: lex.cefr,
      }));
      setHasMore(mapped.length === PAGE_SIZE); // менше за порцію — кінець словника чи результатів
      setWords(prev => (isReset ? mapped : [...prev, ...mapped]));
      void enrich(mapped.map(w => w.id));
    } catch (err) {
      console.error('Помилка завантаження словника:', err);
      if (requestId === requestRef.current) {
        if (isReset) setWords([]); // старі результати іншого пошуку не показуємо
        setLoadError(true);
      }
    } finally {
      if (requestId === requestRef.current) {
        setLoading(false);
        setLoadingMore(false);
      }
    }
  }, [supabase, enrich]);

  // Затримка: шукаємо, коли користувач перестав друкувати
  useEffect(() => {
    const timer = setTimeout(() => setTerm(dictionarySearchTerm(searchQuery)), 300);
    return () => clearTimeout(timer);
  }, [searchQuery]);

  useEffect(() => {
    setPage(0);
    fetchWords(0, true, term, level);
  }, [fetchWords, term, level]);

  const loadMore = () => {
    if (loadingMore || !hasMore) return;
    const nextPage = page + 1;
    setPage(nextPage);
    fetchWords(nextPage, false, term, level);
  };

  const retry = () => (words.length > 0 ? fetchWords(page, false, term, level) : fetchWords(0, true, term, level));

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
                  onClick={() => setLevel(lvl)}
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
        <div className="mb-3 flex items-baseline justify-between gap-3">
          <h2 className="font-heading text-h3">
            {term ? 'Результати пошуку' : level === 'ALL' ? 'Усі слова' : `${level} · ${levelStyle(level).name}`}
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
                <WordRow key={word.id} word={word} theme={themes.get(word.id)} isLearning={learning.has(word.id)} />
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
                {term ? 'Це всі слова за вашим пошуком.' : level === 'ALL' ? 'Ви переглянули весь словник 🎉' : `Це всі слова рівня ${level} 🎉`}
              </p>
            )}
          </>
        ) : (
          <EmptyState
            icon={<Search className="size-6" aria-hidden="true" />}
            title="Слів не знайдено"
            text={
              level !== 'ALL'
                ? `На рівні ${level} такого слова немає. Спробуйте «Усі» рівні.`
                : 'Спробуйте інше написання — можна без хорватських літер (macka → mačka) або українською.'
            }
            action={
              level !== 'ALL' ? (
                <Button variant="secondary" onClick={() => setLevel('ALL')}>
                  Шукати на всіх рівнях
                </Button>
              ) : undefined
            }
          />
        )}
      </main>
    </div>
  );
}

function WordRow({ word, theme, isLearning }: { word: Word; theme?: WordTheme; isLearning: boolean }) {
  return (
    <li className="flex items-center gap-3 rounded-card border border-line bg-surface p-4 shadow-sm">
      <WordTile lemma={word.lemma} level={word.level} theme={theme} />
      <div className="min-w-0 flex-1">
        <Hr as="h3" className="font-heading text-h3 break-words text-ink">
          {word.lemma}
        </Hr>
        <p className="text-body break-words text-ink-muted">{word.translation}</p>
        <div className="mt-1.5 flex flex-wrap items-center gap-x-2 gap-y-1">
          {word.level && <LevelBadge level={word.level} />}
          {word.pos && <span className="text-caption text-ink-subtle">{word.pos}</span>}
          {isLearning && (
            <span className="inline-flex items-center gap-1 rounded-full bg-success-soft px-2 py-0.5 text-caption font-semibold text-success-ink">
              <Check className="size-3.5" strokeWidth={3} aria-hidden="true" />
              Вчу
            </span>
          )}
        </div>
      </div>
      <AudioButton text={word.lemma} label={`Прослухати: ${word.lemma}`} />
    </li>
  );
}
