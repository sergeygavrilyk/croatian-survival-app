'use client';

import { useState, useTransition } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Check, ChevronRight, Puzzle, Search, Sparkles } from 'lucide-react';
import Button from '@/components/ui/Button';
import EmptyState from '@/components/ui/EmptyState';
import ErrorState from '@/components/ui/ErrorState';
import Hr from '@/components/ui/Hr';
import ProgressBar from '@/components/ui/ProgressBar';
import { lessonsHref } from '@/lib/curriculum';
import {
  grammarLevelHref, grammarReviewHref, grammarTopicHref, matchesSearch, rulesWord, topicsAlphabetical, topicsWord,
  type LevelGrammar, type LevelTopic, type TopicState,
} from '@/lib/grammar';
import { LEVEL_CODES, levelStyle, moduleIcon, type LevelStyle } from '@/lib/levels';
import { moduleCardTitles } from '@/lib/reading';
import { cn } from '@/lib/ui';

type View = 'modules' | 'abc';

const STATE_TEXT: Record<TopicState, string> = { done: 'пройдено', now: 'зараз', next: 'попереду' };

/**
 * «Граматика рівня» (рішення власника 2026-10-27, варіант А; DESIGN_SYSTEM §7.9):
 * теми рівня за модулями або за абеткою, пошук без діакритик, стан теми — іконкою й текстом (§98),
 * унизу — «Підсумок граматики» перед фінальною перевіркою рівня.
 */
export default function GrammarLevelView({ level, grammar }: { level: string; grammar: LevelGrammar | null }) {
  const router = useRouter();
  const [, startRetry] = useTransition();
  const [query, setQuery] = useState('');
  const [view, setView] = useState<View>('modules');
  const lv = levelStyle(level);

  const searching = query.trim() !== '';
  const flat = grammar ? topicsAlphabetical(grammar).filter((t) => matchesSearch(t, query)) : [];

  return (
    <div className="min-h-screen pb-28">
      <header className="mx-auto flex max-w-2xl flex-col gap-4 px-5 pt-[calc(1rem+env(safe-area-inset-top))] pb-4">
        <Link
          href={lessonsHref(level)}
          className="-ml-1 inline-flex min-h-11 w-fit items-center gap-1.5 rounded-control px-1 text-label text-ink-muted hover:text-ink"
        >
          <ArrowLeft className="size-5" aria-hidden="true" />
          Уроки
        </Link>
        <div>
          <p className={cn('text-label', lv.ink)}>
            {level} · {lv.name}
          </p>
          <h1 className="font-heading text-h1">Граматика рівня</h1>
          {grammar && grammar.total > 0 && (
            <p className="mt-1 text-body text-ink-muted">
              {topicsWord(grammar.total)}. Будь-яке правило можна відкрити й повторити — навіть з модуля, до якого ви ще не дійшли.
            </p>
          )}
        </div>

        <nav aria-label="Рівень" className="flex rounded-control bg-surface-muted p-1">
          {LEVEL_CODES.map((code) => {
            const active = code === level;
            return (
              <Link
                key={code}
                href={grammarLevelHref(code)}
                aria-current={active ? 'page' : undefined}
                className={cn(
                  'flex min-h-11 flex-1 items-center justify-center rounded-control px-2 text-label transition-colors duration-150',
                  active ? cn(levelStyle(code).solid, 'shadow-sm') : 'text-ink-muted hover:text-ink',
                )}
              >
                {code}
              </Link>
            );
          })}
        </nav>

        {grammar && grammar.total > 0 && (
          <>
            <div className={cn('flex items-center gap-3 rounded-control px-4 py-3', lv.soft)}>
              <ProgressBar value={grammar.done} max={grammar.total} label={`Пройдено тем граматики ${level}`} barClassName={lv.bar} className="flex-1 bg-surface" />
              <span className={cn('shrink-0 text-label', lv.ink)}>
                Пройдено {grammar.done} з {grammar.total}
              </span>
            </div>

            <label className="flex min-h-12 items-center gap-2 rounded-control border border-line-strong bg-surface px-3 focus-within:outline-2 focus-within:outline-offset-2 focus-within:outline-primary">
              <Search className="size-5 shrink-0 text-ink-subtle" aria-hidden="true" />
              <span className="sr-only">Пошук правила</span>
              <input
                type="search"
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Знайти: родовий, se, ću…"
                className="min-w-0 flex-1 bg-transparent text-body text-ink outline-none placeholder:text-ink-subtle"
              />
            </label>

            {!searching && (
              <div role="group" aria-label="Як показати теми" className="flex rounded-control bg-surface-muted p-1">
                {(
                  [
                    ['modules', 'За модулями'],
                    ['abc', 'Від А до Я'],
                  ] as const
                ).map(([key, label]) => (
                  <button
                    key={key}
                    type="button"
                    aria-pressed={view === key}
                    onClick={() => setView(key)}
                    className={cn(
                      'flex min-h-11 flex-1 items-center justify-center rounded-control px-3 text-label transition-colors duration-150',
                      view === key ? 'bg-surface text-ink shadow-sm' : 'text-ink-muted hover:text-ink',
                    )}
                  >
                    {label}
                  </button>
                ))}
              </div>
            )}
          </>
        )}
      </header>

      <main className="mx-auto flex max-w-2xl flex-col gap-5 px-5">
        {!grammar ? (
          <ErrorState
            text="Не вдалося завантажити граматику. Перевірте інтернет і спробуйте ще раз."
            onRetry={() => startRetry(() => router.refresh())}
          />
        ) : grammar.total === 0 ? (
          <EmptyState
            icon={<Puzzle className="size-6" aria-hidden="true" />}
            title={`Граматика рівня ${level} ще готується`}
            text="Вона з’явиться разом з уроками рівня. Поки що повторюйте граматику A0 і A1."
            action={
              <Button variant="secondary" href={grammarLevelHref('A1')}>
                До граматики A1
              </Button>
            }
          />
        ) : searching || view === 'abc' ? (
          flat.length === 0 ? (
            <p className="py-8 text-center text-body text-ink-muted" role="status">
              Нічого не знайшли. Спробуйте інше слово — українською чи хорватською.
            </p>
          ) : (
            <ul className="flex flex-col gap-2" aria-label={searching ? 'Знайдені теми' : 'Теми за абеткою'}>
              {flat.map((t) => (
                <li key={t.id}>
                  <TopicRow topic={t} lv={lv} showModule={grammar.groups} level={level} />
                </li>
              ))}
            </ul>
          )
        ) : (
          <>
            {grammar.groups.map((g) => {
              const head = moduleCardTitles(g.title_ua, g.title_hr, level, g.order);
              const doneCount = g.topics.filter((t) => t.state === 'done').length;
              return (
                <section key={g.id} aria-labelledby={`grammar-module-${g.id}`} className="flex flex-col gap-2">
                  <div className="flex items-center gap-3">
                    <span aria-hidden="true" className={cn('flex size-10 shrink-0 items-center justify-center rounded-control text-xl leading-none', lv.soft)}>
                      {moduleIcon(level, g.order, g.title_hr ?? g.title_ua)}
                    </span>
                    <div className="min-w-0 flex-1">
                      <p className={cn('text-caption uppercase tracking-wide', lv.ink)}>{head.kicker}</p>
                      <h2 id={`grammar-module-${g.id}`} className="font-heading text-h3 break-words">
                        {head.title}
                      </h2>
                    </div>
                    <span className={cn('shrink-0 text-caption', g.state === 'done' ? 'text-success-ink' : g.state === 'now' ? lv.ink : 'text-ink-subtle')}>
                      {g.state === 'done' ? 'усе пройдено' : g.state === 'now' ? 'ви тут' : `${doneCount} з ${g.topics.length}`}
                    </span>
                  </div>
                  <ul className="flex flex-col gap-2">
                    {g.topics.map((t) => (
                      <li key={t.id}>
                        <TopicRow topic={t} lv={lv} level={level} />
                      </li>
                    ))}
                  </ul>
                </section>
              );
            })}
            {grammar.unlinked.length > 0 && (
              <section aria-labelledby="grammar-unlinked" className="flex flex-col gap-2">
                <h2 id="grammar-unlinked" className="font-heading text-h3">
                  Ще теми рівня
                </h2>
                <ul className="flex flex-col gap-2">
                  {grammar.unlinked.map((t) => (
                    <li key={t.id}>
                      <TopicRow topic={t} lv={lv} level={level} />
                    </li>
                  ))}
                </ul>
              </section>
            )}
          </>
        )}

        {grammar && grammar.total > 0 && !searching && <ReviewCard level={level} lv={lv} />}
      </main>
    </div>
  );
}

function TopicRow({
  topic: t,
  lv,
  level,
  showModule,
}: {
  topic: LevelTopic;
  lv: LevelStyle;
  level: string;
  /** Підписати модуль (у пошуку й за абеткою) */
  showModule?: LevelGrammar['groups'];
}) {
  const mod = showModule?.find((g) => g.id === t.moduleId);
  return (
    <Link
      href={grammarTopicHref(t.id)}
      className={cn(
        'flex min-h-16 items-center gap-3 rounded-control border bg-surface px-4 py-3 transition-colors duration-150 hover:bg-surface-muted active:scale-[0.98]',
        t.state === 'now' ? lv.line : 'border-line',
      )}
    >
      <span
        aria-hidden="true"
        className={cn(
          'flex size-9 shrink-0 items-center justify-center rounded-full text-label',
          t.state === 'done' ? 'bg-success text-white' : t.state === 'now' ? lv.solid : 'bg-surface-muted text-ink-muted',
        )}
      >
        {t.state === 'done' ? <Check className="size-5" strokeWidth={3} /> : <Puzzle className="size-4" />}
      </span>
      <span className="min-w-0 flex-1">
        <span className="block text-body font-semibold text-ink">{t.title_ua}</span>
        <span className="block text-label font-normal text-ink-muted">
          {t.title_hr && <Hr>{t.title_hr}</Hr>}
          {t.title_hr && ' · '}
          {rulesWord(t.ruleCount)}
          {mod && ` · модуль ${level}.${mod.order}`}
        </span>
      </span>
      <span
        className={cn(
          'shrink-0 rounded-full px-2 py-0.5 text-caption',
          t.state === 'done' ? 'bg-success-soft text-success-ink' : t.state === 'now' ? cn(lv.soft, lv.ink) : 'text-ink-subtle',
        )}
      >
        {STATE_TEXT[t.state]}
      </span>
      <ChevronRight className="size-5 shrink-0 text-ink-subtle" aria-hidden="true" />
    </Link>
  );
}

/** «Підсумок граматики» — перед фінальною перевіркою рівня (з варіанта Б). */
function ReviewCard({ level, lv }: { level: string; lv: LevelStyle }) {
  return (
    <Link
      href={grammarReviewHref(level)}
      className={cn(
        'mt-2 flex min-h-16 items-center gap-4 rounded-card border-2 border-dashed p-4 transition-colors duration-150 hover:bg-surface',
        lv.line,
        lv.soft,
      )}
    >
      <span className={cn('flex size-11 shrink-0 items-center justify-center rounded-full bg-surface', lv.ink)} aria-hidden="true">
        <Sparkles className="size-5" />
      </span>
      <span className="min-w-0 flex-1">
        <span className="block font-heading text-h3 text-ink">Підсумок граматики {level}</span>
        <span className="block text-label font-normal text-ink-muted">
          Перед фінальною перевіркою: згадати все, потренувати слабке · ~15 хв
        </span>
      </span>
      <ChevronRight className={cn('size-5 shrink-0', lv.ink)} aria-hidden="true" />
    </Link>
  );
}
