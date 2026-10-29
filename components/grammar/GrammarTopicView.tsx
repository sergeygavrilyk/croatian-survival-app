'use client';

import { useState, useTransition } from 'react';
import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { ArrowLeft, Check, ChevronRight, Dumbbell, Play, Puzzle, X } from 'lucide-react';
import AudioButton from '@/components/ui/AudioButton';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import EmptyState from '@/components/ui/EmptyState';
import ErrorState from '@/components/ui/ErrorState';
import Hr from '@/components/ui/Hr';
import IconButton from '@/components/ui/IconButton';
import TypicalErrorCard from '@/components/TypicalErrorCard';
import GrammarPractice from '@/components/grammar/GrammarPractice';
import { exercisesWord, grammarLevelHref, lessonsLocative } from '@/lib/grammar';
import type { TopicPageData } from '@/lib/grammar-repo-supabase';
import { levelStyle } from '@/lib/levels';
import { cn } from '@/lib/ui';

/**
 * Екран теми граматики (DESIGN_SYSTEM §7.9): правила → типові помилки → уроки з темою;
 * знизу — «Потренувати тему» (вправи на речення з уроків теми, ті самі, що в уроках).
 */
export default function GrammarTopicView({ data, failed }: { data: TopicPageData | null; failed: boolean }) {
  const router = useRouter();
  const [, startRetry] = useTransition();
  const [practiceRun, setPracticeRun] = useState(0);
  const [practicing, setPracticing] = useState(false);

  if (!data) {
    return (
      <div className="mx-auto min-h-screen max-w-2xl px-5 pt-[calc(1rem+env(safe-area-inset-top))]">
        <BackLink href="/lessons/grammar" label="Граматика" />
        {failed ? (
          <ErrorState
            text="Не вдалося завантажити тему. Перевірте інтернет і спробуйте ще раз."
            onRetry={() => startRetry(() => router.refresh())}
          />
        ) : (
          <EmptyState
            icon={<Puzzle className="size-6" aria-hidden="true" />}
            title="Тему не знайдено"
            text="Можливо, її ще не опубліковано. Усі теми — у розділі «Граматика рівня»."
            action={<Button href="/lessons/grammar">До граматики</Button>}
          />
        )}
      </div>
    );
  }

  const { topic, lessons, pitfalls, exercises, done } = data;
  const level = topic.cefr || 'A0';
  const lv = levelStyle(level);
  const backHref = grammarLevelHref(level);

  if (practicing) {
    return (
      <div className="mx-auto flex min-h-screen max-w-2xl flex-col gap-4 px-5 pt-[calc(0.75rem+env(safe-area-inset-top))] pb-10">
        <div className="flex items-center gap-2">
          <IconButton label="Закрити тренування" onClick={() => setPracticing(false)} className="-ml-2">
            <X className="size-6" aria-hidden="true" />
          </IconButton>
          <p className="min-w-0 flex-1 truncate font-heading text-h3">{topic.title_ua}</p>
        </div>
        <GrammarPractice
          key={practiceRun}
          exercises={exercises}
          level={level}
          source="grammar_topic"
          topicId={topic.id}
          doneTitle="Тему потреновано!"
          doneActions={
            <>
              <Button block onClick={() => setPracticing(false)}>
                До теми
              </Button>
              <Button block variant="secondary" onClick={() => setPracticeRun((n) => n + 1)}>
                Ще раз
              </Button>
              <Button block variant="tertiary" href={backHref}>
                Усі теми {level}
              </Button>
            </>
          }
        />
      </div>
    );
  }

  const firstModule = lessons.find((l) => l.moduleCode)?.moduleCode ?? null;

  return (
    <div className="min-h-screen pb-40">
      <header className="mx-auto flex max-w-2xl flex-col gap-3 px-5 pt-[calc(1rem+env(safe-area-inset-top))] pb-2">
        <BackLink href={backHref} label={`Граматика ${level}`} />
        <div className="flex flex-wrap gap-2">
          <span className={cn('rounded-full px-2.5 py-0.5 text-caption font-semibold', lv.soft, lv.ink)}>
            {firstModule ? `Модуль ${firstModule}` : level}
            {lessons.length > 0 && ` · у ${lessonsLocative(lessons.length)}`}
          </span>
          {done && (
            <span className="inline-flex items-center gap-1 rounded-full bg-success-soft px-2.5 py-0.5 text-caption font-semibold text-success-ink">
              <Check className="size-3.5" strokeWidth={3} aria-hidden="true" />
              Пройдено
            </span>
          )}
        </div>
        <div>
          <h1 className="font-heading text-h1">{topic.title_ua}</h1>
          {topic.title_hr && (
            <Hr as="p" className={cn('text-body-lg font-semibold', lv.ink)}>
              {topic.title_hr}
            </Hr>
          )}
          {topic.description && <p className="mt-2 text-body text-ink-muted">{topic.description}</p>}
        </div>
        {topic.rules.length > 1 && (
          <nav aria-label="Правила теми" className="flex flex-wrap gap-2">
            {topic.rules.map((r, i) => (
              <a
                key={r.id}
                href={`#rule-${i + 1}`}
                aria-label={`Правило ${i + 1}: ${r.title_ua}`}
                className="flex size-11 items-center justify-center rounded-control border border-line bg-surface font-heading text-label text-ink hover:bg-surface-muted"
              >
                {i + 1}
              </a>
            ))}
          </nav>
        )}
      </header>

      <main className="mx-auto flex max-w-2xl flex-col gap-4 px-5 pt-2">
        {topic.rules.length === 0 && <p className="text-body text-ink-muted">Правила цієї теми ще готуються.</p>}
        {topic.rules.map((rule, i) => (
          <Card key={rule.id} id={`rule-${i + 1}`} className={cn('flex scroll-mt-4 flex-col gap-3 border-t-4', lv.line)}>
            <h2 className={cn('text-label', lv.ink)}>
              {i + 1}. {rule.title_ua}
            </h2>
            <p className="text-body">{rule.explanation_ua}</p>
            {rule.pattern_hr && (
              <Hr as="p" className={cn('rounded-control px-3 py-2 text-center font-heading text-body', lv.soft)}>
                {rule.pattern_hr}
              </Hr>
            )}
            {rule.examples.length > 0 && (
              <ul className="flex flex-col gap-1">
                {rule.examples.map((ex, j) => (
                  <li key={j} className="flex items-center gap-2">
                    <div className="min-w-0 flex-1">
                      <Hr as="p" className="text-body font-semibold">
                        {ex.hr}
                      </Hr>
                      <p className="text-label font-normal text-ink-muted">{ex.ua}</p>
                    </div>
                    <AudioButton text={ex.hr} label={`Прослухати «${ex.hr}»`} />
                  </li>
                ))}
              </ul>
            )}
          </Card>
        ))}

        {pitfalls.map((e) => (
          <TypicalErrorCard key={e.code} error={e} />
        ))}

        {lessons.length > 0 && (
          <section aria-labelledby="topic-lessons" className="flex flex-col gap-2">
            <h2 id="topic-lessons" className="font-heading text-h3">
              Уроки з цією темою
            </h2>
            <ul className="flex flex-col gap-2">
              {lessons.map((l) => (
                <li key={l.id}>
                  <Link
                    href={`/lesson/${l.id}`}
                    aria-label={l.done ? `${l.title_ua} — пройдено` : l.title_ua}
                    className={cn(
                      'flex min-h-14 items-center gap-3 rounded-control border px-4 py-3 transition-colors duration-150 active:scale-[0.98]',
                      l.done ? 'border-success-line bg-success-soft hover:bg-success-soft/70' : 'border-line bg-surface hover:bg-surface-muted',
                    )}
                  >
                    <span
                      aria-hidden="true"
                      className={cn('flex size-9 shrink-0 items-center justify-center rounded-full', l.done ? 'bg-success text-white' : cn(lv.soft, lv.ink))}
                    >
                      {l.done ? <Check className="size-5" strokeWidth={3} /> : <Play className="size-4 translate-x-px fill-current" />}
                    </span>
                    <span className="min-w-0 flex-1">
                      <span className="block text-body font-semibold text-ink">{l.title_ua}</span>
                      <span className="block text-label font-normal text-ink-muted">
                        {l.moduleCode && `Модуль ${l.moduleCode}`}
                        {l.moduleCode && l.title_hr && ' · '}
                        {l.title_hr && <Hr>{l.title_hr}</Hr>}
                      </span>
                    </span>
                    <ChevronRight className="size-5 shrink-0 text-ink-subtle" aria-hidden="true" />
                  </Link>
                </li>
              ))}
            </ul>
          </section>
        )}
      </main>

      <div className="fixed inset-x-0 bottom-0 z-30 border-t border-line bg-surface/95 px-5 pt-3 pb-[calc(1rem+env(safe-area-inset-bottom))]">
        <div className="mx-auto flex max-w-2xl flex-col gap-1">
          {exercises.length > 0 ? (
            <Button block onClick={() => setPracticing(true)}>
              <Dumbbell className="size-5" aria-hidden="true" />
              Потренувати тему · {exercisesWord(exercises.length)}
            </Button>
          ) : (
            <p className="py-2 text-center text-label font-normal text-ink-muted">
              Окремих вправ на цю тему поки немає — тренуйте її в уроках.
            </p>
          )}
        </div>
      </div>
    </div>
  );
}

function BackLink({ href, label }: { href: string; label: string }) {
  return (
    <Link href={href} className="-ml-1 inline-flex min-h-11 w-fit items-center gap-1.5 rounded-control px-1 text-label text-ink-muted hover:text-ink">
      <ArrowLeft className="size-5" aria-hidden="true" />
      {label}
    </Link>
  );
}
