'use client';

import { ArrowRight, RotateCcw } from 'lucide-react';
import { countUk } from '@/lib/format';
import Button from '@/components/ui/Button';
import SessionDone from '@/components/ui/SessionDone';

/** Кінець сесії тренажера (картки й «Написати»): підсумок, підбадьорення, «Ще слова» і «На “Сьогодні”». */
export default function TrainerSessionDone({
  correct,
  total,
  mode,
  onRestart,
  onFinish,
}: {
  correct: number;
  total: number;
  mode: 'recognize' | 'write';
  onRestart?: () => void;
  onFinish: () => void;
}) {
  const verb = mode === 'write' ? 'Написали правильно' : 'Знаєте';
  return (
    <SessionDone
      correct={correct}
      total={total}
      actions={
        <>
          {onRestart && (
            <Button onClick={onRestart} block>
              <RotateCcw className="size-5" aria-hidden="true" />
              Ще слова
            </Button>
          )}
          <Button variant="secondary" onClick={onFinish} block>
            На «Сьогодні»
            <ArrowRight className="size-5" aria-hidden="true" />
          </Button>
        </>
      }
    >
      {verb} {correct} з {countUk(total, ['слова', 'слів', 'слів'])}.
      {correct < total && ' Слова, які ще не запам’ятались, покажемо раніше.'}
    </SessionDone>
  );
}
