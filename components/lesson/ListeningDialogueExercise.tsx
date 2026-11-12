'use client';

import { useEffect, useMemo, useRef, useState, useSyncExternalStore } from 'react';
import { CircleAlert, CircleCheck, Megaphone, Play, Square, Turtle, WifiOff } from 'lucide-react';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import { playCroatian, stopCroatianAudio } from '@/utils/speech';
import { wordInitial } from '@/lib/word-theme';
import {
  allAnswered, answerTurns, PAUSE_MS, playsLeft, scoreListening, type ListeningAnswer, type ListeningScore, type ListeningTask,
} from '@/lib/listening';
import type { PracticeOutcome } from '@/lib/lesson-flow';
import { cn } from '@/lib/ui';

/** Стан мережі для useSyncExternalStore: без звуку вправу можна пропустити. */
function subscribeOnline(onChange: () => void): () => void {
  window.addEventListener('online', onChange);
  window.addEventListener('offline', onChange);
  return () => {
    window.removeEventListener('online', onChange);
    window.removeEventListener('offline', onChange);
  };
}

/** Що піде в подію exercise_completed (§71). */
export interface ListeningDetails {
  count: number;
  correct_count: number;
  plays: number;
  slow_used: boolean;
}

/**
 * «Прослухайте діалог чи оголошення» (listening_dialogue, рішення власника 2026-11-12).
 * Запис звучить репліка за реплікою, тексту не видно; до max_plays прослуховувань, «Повільніше» — довші паузи.
 * Запитання українською (вибір або коротка відповідь); після «Перевірити» — текст із перекладом.
 * Без інтернету (або якщо звук не відтворився) вправу можна пропустити — не рахується як помилка.
 */
export default function ListeningDialogueExercise({
  task,
  onNext,
}: {
  task: ListeningTask;
  onNext: (outcome: PracticeOutcome, details: ListeningDetails) => void;
}) {
  const [plays, setPlays] = useState(0);
  const [line, setLine] = useState<number | null>(null); // репліка, що звучить
  const [slow, setSlow] = useState(false);
  const [slowUsed, setSlowUsed] = useState(false);
  const [audioError, setAudioError] = useState(false);
  const offline = !useSyncExternalStore(subscribeOnline, () => navigator.onLine, () => true);
  const [answers, setAnswers] = useState<ListeningAnswer[]>(() => task.questions.map(() => null));
  const [score, setScore] = useState<ListeningScore | null>(null);
  const timerRef = useRef<ReturnType<typeof setTimeout> | null>(null);
  const runRef = useRef(0); // номер прослуховування: стара черга реплік не продовжується після «Стоп»

  const speakers = useMemo(() => [...new Set(task.script.flatMap((l) => (l.speaker ? [l.speaker] : [])))], [task.script]);
  const highlight = useMemo(() => answerTurns(task), [task]);
  const left = playsLeft(plays, task.max_plays);
  const playing = line !== null;
  const done = score !== null;

  // Пішли з вправи — звук і паузи зупиняємо
  useEffect(
    () => () => {
      runRef.current += 1;
      if (timerRef.current) clearTimeout(timerRef.current);
      stopCroatianAudio();
    },
    [],
  );

  const stop = () => {
    runRef.current += 1;
    if (timerRef.current) clearTimeout(timerRef.current);
    stopCroatianAudio();
    setLine(null);
  };

  const playFrom = (run: number, i: number) => {
    if (run !== runRef.current) return;
    if (i >= task.script.length) {
      setLine(null);
      return;
    }
    setLine(i);
    playCroatian(task.script[i].hr, {
      onEnded: () => {
        if (run !== runRef.current) return;
        timerRef.current = setTimeout(() => playFrom(run, i + 1), slow ? PAUSE_MS.slow : PAUSE_MS.normal);
      },
      onError: () => {
        if (run !== runRef.current) return;
        setAudioError(true);
        setLine(null);
      },
    });
  };

  const play = () => {
    if (playing || left === 0) return;
    setAudioError(false);
    setPlays((p) => p + 1);
    if (slow) setSlowUsed(true);
    const run = ++runRef.current;
    playFrom(run, 0);
  };

  const setAnswer = (i: number, value: ListeningAnswer) => setAnswers((prev) => prev.map((a, j) => (j === i ? value : a)));

  const check = () => {
    if (!allAnswered(task, answers)) return;
    stop();
    setScore(scoreListening(task, answers));
  };

  const finish = (outcome: PracticeOutcome) =>
    onNext(outcome, { count: task.questions.length, correct_count: score?.correct ?? 0, plays, slow_used: slowUsed });

  const cantListen = offline || audioError;

  return (
    <div className="flex flex-col gap-4">
      <p className="text-body-lg">{task.situation_ua}</p>

      {/* Програвач: тексту не видно, лише хто говорить і котра репліка */}
      {!done && (
        <Card className="flex flex-col items-center gap-3 py-5">
          {speakers.length > 0 ? (
            <div className="flex flex-wrap justify-center gap-3" aria-hidden="true">
              {speakers.map((s) => {
                const active = playing && task.script[line!]?.speaker === s;
                return (
                  <div key={s} className="flex flex-col items-center gap-1">
                    <span
                      className={cn(
                        'flex size-12 items-center justify-center rounded-full border-2 font-heading text-h3 transition-colors duration-150',
                        active ? 'border-primary bg-primary text-white' : 'border-line bg-surface-muted text-ink-muted',
                      )}
                    >
                      {wordInitial(s)}
                    </span>
                    <Hr className={cn('text-caption', active ? 'font-semibold text-ink' : 'text-ink-muted')}>{s}</Hr>
                  </div>
                );
              })}
            </div>
          ) : (
            <span className="flex size-12 items-center justify-center rounded-full bg-primary-soft text-primary-ink" aria-hidden="true">
              <Megaphone className="size-6" />
            </span>
          )}
          <p className="text-label font-normal text-ink-muted" aria-live="polite">
            {playing
              ? `Звучить: ${speakers.length > 0 && task.script[line!]?.speaker ? `${task.script[line!].speaker} · ` : ''}репліка ${line! + 1} з ${task.script.length}`
              : left > 0
                ? `Можна прослухати ще ${left} ${left === 1 ? 'раз' : 'рази'}`
                : 'Прослуховування закінчились — відповідайте на запитання'}
          </p>
          <div className="flex items-center gap-3">
            <button
              type="button"
              onClick={playing ? stop : play}
              disabled={!playing && (left === 0 || cantListen)}
              aria-label={playing ? 'Зупинити' : plays === 0 ? 'Слухати' : 'Слухати ще раз'}
              className="flex size-20 items-center justify-center rounded-full bg-primary text-white shadow-md transition-colors duration-150 hover:bg-primary-hover active:scale-[0.98] disabled:bg-surface-muted disabled:text-ink-subtle disabled:shadow-none"
            >
              {playing ? <Square className="size-7" aria-hidden="true" /> : <Play className="size-8 translate-x-0.5" aria-hidden="true" />}
            </button>
            <button
              type="button"
              onClick={() => setSlow((s) => !s)}
              aria-pressed={slow}
              className={cn(
                'flex min-h-11 items-center gap-1.5 rounded-full border-2 px-3 text-label transition-colors duration-150',
                slow ? 'border-primary bg-primary-soft text-primary-ink' : 'border-line bg-surface text-ink-muted hover:border-primary',
              )}
            >
              <Turtle className="size-4" aria-hidden="true" />
              Повільніше
            </button>
          </div>
          <p className="text-caption text-ink-subtle">▶ {Math.min(plays, task.max_plays)} з {task.max_plays}</p>
        </Card>
      )}

      {cantListen && !done && (
        <div role="status" className="flex gap-2 rounded-card border border-warning-line bg-warning-soft p-3 text-warning-ink">
          <WifiOff className="mt-0.5 size-5 shrink-0" aria-hidden="true" />
          <p className="text-label font-normal">
            {offline ? 'Аудіо доступне з інтернетом.' : 'Не вдалося відтворити звук.'} Вправу можна пропустити — це не помилка.
          </p>
        </div>
      )}

      {/* Запитання */}
      <ol className="flex flex-col gap-4">
        {task.questions.map((q, i) => {
          const ok = score?.results[i];
          return (
            <li key={i} className="flex flex-col gap-2">
              <p className="flex items-start gap-2 font-semibold">
                <span className="text-ink-subtle">{i + 1}.</span>
                <span className="min-w-0 flex-1">{q.q_ua}</span>
                {done && (ok
                  ? <CircleCheck className="size-5 shrink-0 text-success-ink" aria-label="Правильно" />
                  : <CircleAlert className="size-5 shrink-0 text-danger-ink" aria-label="Неправильно" />)}
              </p>
              {q.kind === 'choice' ? (
                <div className="flex flex-col gap-2" role="group" aria-label={`Варіанти: ${q.q_ua}`}>
                  {q.options.map((opt, j) => {
                    const picked = answers[i] === j;
                    const state = !done ? (picked ? 'picked' : 'idle') : j === q.correct ? 'right' : picked ? 'wrong' : 'dim';
                    return (
                      <button
                        key={opt}
                        type="button"
                        disabled={done}
                        aria-pressed={picked}
                        onClick={() => setAnswer(i, j)}
                        className={cn(
                          'flex min-h-12 items-center justify-between gap-3 rounded-control border-2 px-4 py-2 text-left text-body transition-colors duration-150',
                          state === 'idle' && 'border-line bg-surface hover:border-primary',
                          state === 'picked' && 'border-primary bg-primary-soft text-primary-ink',
                          state === 'right' && 'border-success-line bg-success-soft text-success-ink',
                          state === 'wrong' && 'border-danger-line bg-danger-soft text-danger-ink',
                          state === 'dim' && 'border-line bg-surface opacity-60',
                        )}
                      >
                        <span>{opt}</span>
                        {state === 'right' && <CircleCheck className="size-5 shrink-0" aria-label="Правильна відповідь" />}
                        {state === 'wrong' && <CircleAlert className="size-5 shrink-0" aria-label="Ваша відповідь" />}
                      </button>
                    );
                  })}
                </div>
              ) : (
                <>
                  <input
                    value={typeof answers[i] === 'string' ? (answers[i] as string) : ''}
                    onChange={(e) => setAnswer(i, e.target.value)}
                    disabled={done}
                    autoComplete="off"
                    spellCheck={false}
                    aria-label={`Відповідь: ${q.q_ua}`}
                    placeholder="Цифра або слово…"
                    className={cn(
                      'min-h-12 w-full rounded-control border-2 bg-surface px-4 text-body-lg focus:border-primary focus:outline-none disabled:opacity-80',
                      done ? (ok ? 'border-success-line' : 'border-danger-line') : 'border-line',
                    )}
                  />
                  {done && !ok && (
                    <p className="text-label font-normal text-ink-muted">
                      Правильно: <span className="font-semibold text-ink">{q.answer_text}</span>
                    </p>
                  )}
                </>
              )}
            </li>
          );
        })}
      </ol>

      {/* Після перевірки — текст запису з перекладом */}
      {done && (
        <>
          <div
            role="status"
            className={cn('rounded-card px-4 py-3 font-semibold', score?.outcome === 'correct' ? 'bg-success-soft text-success-ink' : 'bg-warning-soft text-warning-ink')}
          >
            {score?.outcome === 'correct' ? 'Усе зрозуміли!' : `Правильно ${score?.correct ?? 0} з ${score?.total ?? 0}. Подивіться текст — відповіді підсвічено.`}
          </div>
          <Card className="flex flex-col gap-3">
            <p className="text-label text-ink-muted">Текст запису</p>
            {task.script.map((l, i) => (
              <div key={i} className={cn('flex items-start gap-2 rounded-control p-2', highlight.has(i) && 'bg-warning-soft')}>
                <div className="min-w-0 flex-1">
                  {l.speaker && <Hr as="p" className="text-caption font-semibold text-ink-muted">{l.speaker}</Hr>}
                  <Hr as="p" className="text-body-lg break-words">{l.hr}</Hr>
                  <p className="text-label font-normal break-words text-ink-muted">{l.ua}</p>
                </div>
                <AudioButton text={l.hr} label={`Прослухати: ${l.hr}`} />
              </div>
            ))}
          </Card>
        </>
      )}

      {done ? (
        <Button block autoFocus onClick={() => finish(score?.outcome ?? 'wrong')}>
          Далі
        </Button>
      ) : (
        <div className="flex flex-col gap-2">
          <Button block onClick={check} disabled={!allAnswered(task, answers)}>
            Перевірити
          </Button>
          <Button block variant="tertiary" onClick={() => { stop(); finish('skipped'); }}>
            {cantListen ? 'Пропустити' : 'Не можу слухати зараз — пропустити'}
          </Button>
        </div>
      )}
    </div>
  );
}
