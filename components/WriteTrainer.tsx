'use client';

import React, { useEffect, useMemo, useRef, useState } from 'react';
import { ArrowRight, Lightbulb } from 'lucide-react';
import { speakCroatian } from '@/utils/speech';
import { checkTypedAnswer, maskExample, type AnswerCheck } from '@/lib/answer';
import type { WordTheme } from '@/lib/word-theme';
import { cn } from '@/lib/ui';
import AudioButton from '@/components/ui/AudioButton';
import Button, { buttonClasses } from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import FeedbackBanner from '@/components/ui/FeedbackBanner';
import Hr from '@/components/ui/Hr';
import LevelBadge from '@/components/ui/LevelBadge';
import ProgressBar from '@/components/ui/ProgressBar';
import WordTile from '@/components/ui/WordTile';
import TrainerSessionDone from '@/components/TrainerSessionDone';

/**
 * VS-001, кроки 5–7: користувач бачить українське слово (і приклад з пропуском),
 * сам вводить хорватське слово і отримує зворотний звʼязок (DESIGN_SYSTEM §9.2).
 */
export interface WriteCard {
  id: string;
  hr_text: string;
  ua_translation: string;
  /** Частина мови українською («іменник») */
  phonetic_note?: string;
  example?: string;
  /** Рівень слова (A0 … B2) — колір плитки й бейджа */
  level?: string;
  /** Тема модуля, де слово трапляється в уроках (емодзі) */
  theme?: WordTheme | null;
}

interface WriteTrainerProps {
  cards: WriteCard[];
  /** correct — чи зараховано відповідь; responseTimeMs — від показу картки до перевірки */
  onAnswer: (card: WriteCard, result: AnswerCheck, responseTimeMs: number) => void;
  onFinishSession: () => void;
  /** «Ще слова» на екрані завершення */
  onRestart?: () => void;
}

const CROATIAN_LETTERS = ['č', 'ć', 'đ', 'š', 'ž'];

export default function WriteTrainer({ cards, onAnswer, onFinishSession, onRestart }: WriteTrainerProps) {
  const [index, setIndex] = useState(0);
  const [value, setValue] = useState('');
  const [result, setResult] = useState<AnswerCheck | null>(null);
  const [gaveUp, setGaveUp] = useState(false);
  const [correctCount, setCorrectCount] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);
  const shownAtRef = useRef(0); // ставимо в ефекті нижче, коли картку показано

  const card = cards[index];
  const masked = useMemo(
    () => (card?.example ? maskExample(card.example, card.hr_text) : null),
    [card]
  );

  // Нова картка: фокус і старт таймера (поле очищає next())
  useEffect(() => {
    shownAtRef.current = Date.now();
    inputRef.current?.focus();
  }, [index]);

  if (!card) {
    return (
      <div className="px-5 pt-2">
        <TrainerSessionDone correct={correctCount} total={cards.length} mode="write" onRestart={onRestart} onFinish={onFinishSession} />
      </div>
    );
  }

  const insertLetter = (letter: string) => {
    const input = inputRef.current;
    if (!input || result) return;
    const start = input.selectionStart ?? value.length;
    const end = input.selectionEnd ?? value.length;
    const next = value.slice(0, start) + letter + value.slice(end);
    setValue(next);
    requestAnimationFrame(() => {
      input.focus();
      input.setSelectionRange(start + 1, start + 1);
    });
  };

  const check = (giveUp = false) => {
    if (result) return;
    const res = giveUp ? { verdict: 'wrong' as const, correct: false, expected: card.hr_text } : checkTypedAnswer(value, card.hr_text);
    if (!giveUp && res.verdict === 'empty') return; // порожнє поле — нічого не робимо
    setResult(res);
    setGaveUp(giveUp);
    if (res.correct) setCorrectCount((c) => c + 1);
    speakCroatian(card.hr_text);
    onAnswer(card, res, Date.now() - shownAtRef.current);
  };

  const next = () => {
    setValue('');
    setResult(null);
    setGaveUp(false);
    setIndex((i) => i + 1);
  };
  const ok = result?.correct;
  const feedbackKind = gaveUp ? 'gave_up' : result && result.verdict !== 'empty' ? result.verdict : null;

  return (
    <div className="mx-auto flex max-w-md flex-col gap-4 px-5 pt-2 pb-6">
      {/* Прогрес сесії */}
      <div className="flex items-center gap-3">
        <ProgressBar value={index} max={cards.length} label="Прогрес тренування" className="flex-1" />
        <span className="font-heading text-label tabular-nums text-ink-muted">
          {index + 1} / {cards.length}
        </span>
      </div>

      <Card hero className="flex flex-col gap-5">
        {/* Тема й рівень слова */}
        <div className="flex items-center gap-3">
          <WordTile lemma={card.hr_text} level={card.level} theme={card.theme} />
          <div className="min-w-0 flex-1">
            <p className="text-label text-ink-muted">Як це хорватською?</p>
            {card.theme && <p className="truncate text-caption text-ink-subtle">{card.theme.title}</p>}
          </div>
          {card.level && <LevelBadge level={card.level} />}
        </div>

        <div className="text-center">
          <h2 className="font-heading text-h1 break-words">{card.ua_translation}</h2>
          {card.phonetic_note && <p className="mt-1 text-label font-normal text-ink-subtle">{card.phonetic_note}</p>}
          {masked?.found && !result && (
            <Hr as="p" className="mt-4 text-body-lg italic text-ink-muted">
              {masked.text}
            </Hr>
          )}
        </div>

        <form
          className="flex flex-col gap-4"
          onSubmit={(e) => {
            e.preventDefault();
            if (result) next();
            else check();
          }}
        >
          <input
            ref={inputRef}
            value={value}
            onChange={(e) => setValue(e.target.value)}
            readOnly={!!result}
            lang="hr"
            autoCapitalize="none"
            autoComplete="off"
            autoCorrect="off"
            spellCheck={false}
            placeholder="Введіть слово…"
            aria-label="Хорватське слово"
            className={cn(
              'min-h-14 w-full rounded-control border-2 px-4 text-center font-heading text-h2 outline-none transition-colors duration-150 placeholder:font-sans placeholder:text-body placeholder:font-normal placeholder:text-ink-subtle',
              result
                ? ok
                  ? 'border-success-line bg-success-soft text-success-ink'
                  : 'border-line bg-surface-muted text-ink'
                : 'border-line bg-surface focus:border-primary',
            )}
          />

          {!result && (
            <div className="flex justify-center gap-2" role="group" aria-label="Хорватські літери">
              {CROATIAN_LETTERS.map((letter) => (
                <button
                  key={letter}
                  type="button"
                  lang="hr"
                  onClick={() => insertLetter(letter)}
                  aria-label={`Вставити літеру ${letter}`}
                  className="flex size-11 items-center justify-center rounded-control border border-line bg-surface-muted font-heading text-h3 text-ink transition-colors duration-150 hover:border-primary hover:bg-primary-soft active:scale-[0.98]"
                >
                  {letter}
                </button>
              ))}
            </div>
          )}

          {/* Зворотний звʼязок (DESIGN_SYSTEM §9.2) */}
          {feedbackKind && (
            <div className="flex flex-col gap-2">
              <FeedbackBanner kind={feedbackKind} expected={result!.expected}>
                <AudioButton text={card.hr_text} className="-m-2 text-current hover:bg-surface/60 hover:text-current" />
              </FeedbackBanner>
              {card.example && (
                <div className="flex items-start gap-1 rounded-card bg-surface-muted px-4 py-2">
                  <Hr as="p" className="min-w-0 flex-1 pt-2.5 text-body italic text-ink-muted">
                    {card.example}
                  </Hr>
                  <AudioButton text={card.example} label="Прослухати приклад" />
                </div>
              )}
            </div>
          )}

          {!result ? (
            <div className="grid grid-cols-2 gap-3">
              <button type="button" onClick={() => check(true)} className={buttonClasses('tertiary', 'md', 'whitespace-nowrap border border-line bg-surface px-3')}>
                <Lightbulb className="size-5" aria-hidden="true" />
                Не знаю
              </button>
              <Button type="submit" disabled={!value.trim()} block>
                Перевірити
              </Button>
            </div>
          ) : (
            <Button type="submit" block>
              Далі
              <ArrowRight className="size-5" aria-hidden="true" />
            </Button>
          )}
        </form>
      </Card>
    </div>
  );
}
