'use client';

import { useMemo, useRef, useState } from 'react';
import Link from 'next/link';
import { ChevronRight, Eye, EyeOff, ListChecks, Mic, RotateCcw, Sparkles } from 'lucide-react';
import PageHeader from '@/components/ui/PageHeader';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import LevelBadge from '@/components/ui/LevelBadge';
import Button from '@/components/ui/Button';
import ProgressBar from '@/components/ui/ProgressBar';
import EmptyState from '@/components/ui/EmptyState';
import ErrorState from '@/components/ui/ErrorState';
import SpeakingPractice from '@/components/SpeakingPractice';
import { track } from '@/lib/analytics-client';
import { countUk } from '@/lib/format';
import { cn, shuffle } from '@/lib/ui';
import type { SituationInfo } from '@/lib/situations';

export interface SituationPhrase {
  id: string;
  text_hr: string;
  ukrainian_translation: string;
  cefr: string | null;
}

export interface SituationDialogue {
  id: string;
  title_ua: string | null;
  title_hr: string | null;
  level: string | null;
  turns: Array<{ id: string; speaker_name: string; hr_text: string; ua_translation: string }>;
}

type Tab = 'phrases' | 'dialogues';

/** Екран ситуації: фрази (список або «Перевір себе») і діалоги (docs/DESIGN_SYSTEM.md §9.4). */
export default function SituationView({
  situation,
  phrases,
  dialogues,
  loadError,
  roleplay,
}: {
  situation: SituationInfo;
  phrases: SituationPhrase[];
  dialogues: SituationDialogue[];
  loadError?: boolean;
  /** Рольова гра з AI для цієї ситуації (VS-004) */
  roleplay?: { aiRoleUa: string; goalUa: string } | null;
}) {
  const [tab, setTab] = useState<Tab>(phrases.length > 0 ? 'phrases' : 'dialogues');
  const [practice, setPractice] = useState<'recall' | 'speak' | null>(null);

  const tabs: Array<{ key: Tab; label: string; count: number }> = [
    { key: 'phrases', label: 'Фрази', count: phrases.length },
    { key: 'dialogues', label: 'Діалоги', count: dialogues.length },
  ];

  return (
    <div className="min-h-screen pb-28">
      <PageHeader title={`${situation.emoji} ${situation.label}`} backHref="/situations">
        <div role="tablist" aria-label="Розділи ситуації" className="grid grid-cols-2 gap-1 rounded-control bg-surface-muted p-1">
          {tabs.map((t) => (
            <button
              key={t.key}
              type="button"
              role="tab"
              aria-selected={tab === t.key}
              disabled={t.count === 0}
              onClick={() => {
                setTab(t.key);
                setPractice(null);
              }}
              className={cn(
                'min-h-10 rounded-[0.6rem] text-label transition-colors duration-150 disabled:opacity-40',
                tab === t.key ? 'bg-surface text-primary-ink shadow-sm' : 'text-ink-muted hover:text-ink',
              )}
            >
              {t.label} · {t.count}
            </button>
          ))}
        </div>
      </PageHeader>

      <main className="mx-auto max-w-2xl px-5 pt-4">
        {loadError && <ErrorState className="py-6" text="Частину даних не вдалося завантажити. Оновіть сторінку." />}

        {roleplay && !practice && (
          <Link
            href={`/situations/${situation.code}/roleplay`}
            className="mb-4 flex items-center gap-3 rounded-card border border-ai-line bg-ai-soft p-4 transition-colors duration-150 hover:border-ai active:scale-[0.98]"
          >
            <span className="flex size-10 shrink-0 items-center justify-center rounded-full bg-surface text-ai-ink" aria-hidden="true">
              <Sparkles className="size-5" />
            </span>
            <span className="min-w-0 flex-1">
              <span className="block font-heading text-h3">Рольова гра з AI</span>
              <span className="block text-label font-normal text-ink-muted">
                Розмова з: {roleplay.aiRoleUa}. {roleplay.goalUa}
              </span>
            </span>
            <ChevronRight className="size-5 shrink-0 text-ai-ink" aria-hidden="true" />
          </Link>
        )}

        {tab === 'phrases' &&
          (practice === 'recall' ? (
            <PhrasePractice situation={situation.code} phrases={phrases} onExit={() => setPractice(null)} />
          ) : practice === 'speak' ? (
            <SpeakingPractice
              situation={situation.code}
              phrases={phrases}
              onExit={() => setPractice(null)}
              onFallback={() => setPractice('recall')}
            />
          ) : (
            <PhraseList phrases={phrases} onPractice={setPractice} />
          ))}

        {tab === 'dialogues' && <DialogueList dialogues={dialogues} />}
      </main>
    </div>
  );
}

// ---------------------------------------------------------------- Фрази: список
function PhraseList({ phrases, onPractice }: { phrases: SituationPhrase[]; onPractice: (mode: 'recall' | 'speak') => void }) {
  if (phrases.length === 0) {
    return <EmptyState title="Фраз поки немає" text="Перегляньте діалоги цієї ситуації." />;
  }
  return (
    <>
      <div className="mb-4 flex flex-wrap items-center justify-between gap-3">
        <p className="text-label text-ink-muted">{countUk(phrases.length, ['фраза', 'фрази', 'фраз'])}</p>
        <div className="flex gap-2">
          <Button variant="secondary" size="sm" onClick={() => onPractice('recall')}>
            <ListChecks className="size-5" aria-hidden="true" />
            Перевір себе
          </Button>
          <Button size="sm" onClick={() => onPractice('speak')}>
            <Mic className="size-5" aria-hidden="true" />
            Говорити
          </Button>
        </div>
      </div>
      <ul className="flex flex-col gap-3">
        {phrases.map((p) => (
          <li key={p.id}>
            <Card className="flex items-start gap-3 p-4">
              <div className="min-w-0 flex-1">
                <Hr as="p" className="font-heading text-body-lg font-semibold break-words">
                  {p.text_hr}
                </Hr>
                <p className="mt-0.5 text-body text-ink-muted">{p.ukrainian_translation}</p>
              </div>
              <div className="flex shrink-0 flex-col items-end gap-1">
                <AudioButton text={p.text_hr} />
                {p.cefr && <LevelBadge level={p.cefr} />}
              </div>
            </Card>
          </li>
        ))}
      </ul>
    </>
  );
}

// ---------------------------------------------------------------- Фрази: «Перевір себе» (retrieval)
function PhrasePractice({
  situation,
  phrases,
  onExit,
}: {
  situation: string;
  phrases: SituationPhrase[];
  onExit: () => void;
}) {
  const [round, setRound] = useState(0);
  // Порядок перемішується на початку кожного кола (лише в браузері — після натиску кнопки)
  const order = useMemo(() => shuffle(phrases), [phrases, round]); // eslint-disable-line react-hooks/exhaustive-deps
  const [index, setIndex] = useState(0);
  const [revealed, setRevealed] = useState(false);
  const [known, setKnown] = useState(0);
  const shownAt = useRef(Date.now());

  const done = index >= order.length;
  const current = order[index];

  const answer = (success: boolean) => {
    track('exercise_completed', {
      exercise_type: 'phrase_recall',
      source: 'situation',
      situation,
      phrase_id: current.id,
      level: current.cefr ?? undefined,
      success,
      duration_ms: Date.now() - shownAt.current,
    });
    if (success) setKnown((k) => k + 1);
    setRevealed(false);
    setIndex((i) => i + 1);
    shownAt.current = Date.now();
  };

  const restart = () => {
    setRound((r) => r + 1);
    setIndex(0);
    setKnown(0);
    setRevealed(false);
    shownAt.current = Date.now();
  };

  if (done) {
    return (
      <Card hero className="animate-fade-in-up text-center">
        <p className="text-label text-ink-muted">Результат</p>
        <p className="mt-1 font-heading text-display">
          {known} з {order.length}
        </p>
        <p className="mt-2 text-body text-ink-muted">
          {known === order.length ? 'Чудово — усі фрази згадали самі.' : 'Фрази, які не згадали, варто пройти ще раз.'}
        </p>
        <div className="mt-6 flex flex-col gap-2 sm:flex-row sm:justify-center">
          <Button onClick={restart}>
            <RotateCcw className="size-5" aria-hidden="true" />
            Ще раз
          </Button>
          <Button variant="tertiary" onClick={onExit}>
            До списку фраз
          </Button>
        </div>
      </Card>
    );
  }

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center gap-3">
        <ProgressBar value={index} max={order.length} label="Прогрес вправи" />
        <span className="shrink-0 text-label text-ink-muted">
          {index + 1} / {order.length}
        </span>
      </div>

      <Card hero className="flex min-h-64 flex-col">
        <p className="text-label text-ink-muted">Як сказати хорватською?</p>
        <p className="mt-2 font-heading text-h2">{current.ukrainian_translation}</p>

        <div className="mt-6 flex-1" aria-live="polite">
          {revealed && (
            <div className="flex items-start gap-3 rounded-card bg-surface-muted p-4 animate-fade-in-up">
              <Hr as="p" className="min-w-0 flex-1 font-heading text-h2 break-words">
                {current.text_hr}
              </Hr>
              <AudioButton text={current.text_hr} />
            </div>
          )}
        </div>

        <div className="mt-6 grid grid-cols-2 gap-2">
          {revealed ? (
            <>
              <Button variant="secondary" onClick={() => answer(false)}>
                Ще ні
              </Button>
              <Button variant="success" onClick={() => answer(true)}>
                Знав
              </Button>
            </>
          ) : (
            <>
              <Button variant="tertiary" onClick={onExit}>
                Завершити
              </Button>
              <Button onClick={() => setRevealed(true)}>Показати</Button>
            </>
          )}
        </div>
      </Card>
      <p className="text-center text-label font-normal text-ink-muted">
        Спершу скажіть фразу вголос або подумки, потім перевірте себе.
      </p>
    </div>
  );
}

// ---------------------------------------------------------------- Діалоги
function DialogueList({ dialogues }: { dialogues: SituationDialogue[] }) {
  const [showTranslation, setShowTranslation] = useState(true);

  if (dialogues.length === 0) {
    return <EmptyState title="Діалогів поки немає" text="Перегляньте фрази цієї ситуації." />;
  }

  return (
    <>
      <div className="mb-4 flex justify-end">
        <Button variant="tertiary" size="sm" aria-pressed={!showTranslation} onClick={() => setShowTranslation((v) => !v)}>
          {showTranslation ? <EyeOff className="size-5" aria-hidden="true" /> : <Eye className="size-5" aria-hidden="true" />}
          {showTranslation ? 'Сховати переклад' : 'Показати переклад'}
        </Button>
      </div>

      <div className="flex flex-col gap-4">
        {dialogues.map((d) => {
          const speakers = [...new Set(d.turns.map((t) => t.speaker_name))];
          return (
            <Card key={d.id}>
              <div className="mb-4 flex items-start justify-between gap-3">
                <div className="min-w-0">
                  <h2 className="font-heading text-h3">{d.title_ua || d.title_hr}</h2>
                  {d.title_hr && d.title_ua && (
                    <Hr as="p" className="text-label font-normal text-ink-muted">
                      {d.title_hr}
                    </Hr>
                  )}
                </div>
                {d.level && <LevelBadge level={d.level} />}
              </div>

              <ol className="flex flex-col gap-3">
                {d.turns.map((t) => {
                  const right = speakers.indexOf(t.speaker_name) % 2 === 1;
                  return (
                    <li key={t.id} className={cn('flex flex-col', right ? 'items-end' : 'items-start')}>
                      <span className="mb-1 px-1 text-caption text-ink-subtle">{t.speaker_name}</span>
                      <div
                        className={cn(
                          'flex max-w-[90%] items-start gap-2 rounded-card px-4 py-3',
                          right ? 'bg-primary-soft' : 'bg-surface-muted',
                        )}
                      >
                        <div className="min-w-0">
                          <Hr as="p" className="text-body-lg break-words">
                            {t.hr_text}
                          </Hr>
                          {showTranslation && <p className="mt-0.5 text-label font-normal text-ink-muted">{t.ua_translation}</p>}
                        </div>
                        <AudioButton text={t.hr_text} className="-mr-2 -mt-1" />
                      </div>
                    </li>
                  );
                })}
              </ol>
            </Card>
          );
        })}
      </div>
    </>
  );
}
