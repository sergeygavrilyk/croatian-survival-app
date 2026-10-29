'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import LessonExercise from '@/components/lesson/LessonExercise';
import ProgressBar from '@/components/ui/ProgressBar';
import SessionDone from '@/components/ui/SessionDone';
import { track } from '@/lib/analytics-client';
import { answerCurrent, isRetry, practiceDone, startPractice, type PracticeOutcome } from '@/lib/lesson-flow';
import { levelStyle } from '@/lib/levels';
import type { PracticeExercise } from '@/lib/grammar';
import { cn } from '@/lib/ui';

/**
 * Серія вправ на граматику («Потренувати тему», «Підсумок граматики» → крок 2).
 * Ті самі вправи, що в уроках (LessonExercise): неправильна повертається один раз у кінці черги.
 * Аналітика (§71): review_started / exercise_completed / review_completed із source = grammar_topic | grammar_review.
 */
export default function GrammarPractice({
  exercises,
  level,
  source,
  topicId,
  doneTitle,
  doneActions,
}: {
  exercises: PracticeExercise[];
  level: string;
  source: 'grammar_topic' | 'grammar_review';
  /** Тема («Потренувати тему») — для аналітики */
  topicId?: string;
  /** Заголовок підсумку */
  doneTitle?: string;
  /** Кнопки після серії: головна дія першою */
  doneActions: React.ReactNode;
}) {
  const lv = levelStyle(level);
  const byId = useMemo(() => new Map(exercises.map((e) => [e.id, e])), [exercises]);
  const [practice, setPractice] = useState(() => startPractice(exercises.map((e) => e.id)));
  const [round, setRound] = useState(0);
  const startRef = useRef(0);
  const sessionStartRef = useRef(0);

  useEffect(() => {
    startRef.current = Date.now();
    sessionStartRef.current = Date.now();
    track('review_started', { source, level, skill: 'grammar', count: exercises.length, grammar_topic_id: topicId });
  }, [source, level, exercises.length, topicId]);

  const currentId = practice.queue[0];
  const current = currentId ? byId.get(currentId) : undefined;

  if (!current) {
    return (
      <SessionDone correct={practice.firstTry.length} total={practice.total} title={doneTitle} actions={doneActions}>
        Правильно з першої спроби: {practice.firstTry.length} з {practice.total}.
      </SessionDone>
    );
  }

  const retry = isRetry(practice);
  const onNext = (outcome: PracticeOutcome, verdict?: string) => {
    const now = Date.now();
    track('exercise_completed', {
      source,
      level,
      skill: 'grammar',
      grammar_topic_id: topicId,
      exercise_id: current.id,
      exercise_type: current.exercise_type,
      success: outcome === 'correct',
      attempt: retry ? 2 : 1,
      duration_ms: now - startRef.current,
      ...(verdict ? { verdict } : {}),
    });
    startRef.current = now;
    const after = answerCurrent(practice, outcome);
    setPractice(after);
    setRound((r) => r + 1);
    if (after.queue.length === 0) {
      track('review_completed', {
        source,
        level,
        skill: 'grammar',
        grammar_topic_id: topicId,
        count: after.total,
        correct_count: after.firstTry.length,
        duration_ms: now - sessionStartRef.current,
      });
    }
    window.scrollTo({ top: 0 });
  };

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center gap-3">
        <p className={cn('shrink-0 rounded-full px-2.5 py-0.5 text-caption font-semibold', lv.soft, lv.ink)}>
          Вправа {Math.min(practiceDone(practice) + 1, practice.total)} з {practice.total}
        </p>
        <ProgressBar value={practiceDone(practice)} max={practice.total} label="Пройдено вправ" barClassName={lv.bar} className="flex-1" />
      </div>
      <LessonExercise key={`${current.id}:${round}`} exercise={current} retry={retry} onNext={onNext} />
    </div>
  );
}
