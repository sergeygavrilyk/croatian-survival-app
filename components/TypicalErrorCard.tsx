import { CircleCheck, CircleX, Lightbulb } from 'lucide-react';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import { categoryLabel, isSpoken, type TypicalError } from '@/lib/interference';
import { cn } from '@/lib/ui';

/**
 * Картка типової помилки українців (§19): «неправильно» → «правильно», пояснення й приклади.
 * Використовується в уроці (етап «Граматика») і після відповіді у вправі «Типові помилки».
 * Стан передається іконкою й текстом, не лише кольором (§98).
 */
export default function TypicalErrorCard({
  error,
  heading = 'Українці часто помиляються',
  showWrong = true,
  className,
}: {
  error: Pick<TypicalError, 'code' | 'category' | 'title_ua' | 'incorrect_text' | 'correct_text' | 'explanation_ua' | 'examples'>;
  /** Заголовок над карткою; null — без нього (напр. у вправі, де вже є відповідь) */
  heading?: string | null;
  showWrong?: boolean;
  className?: string;
}) {
  const spoken = isSpoken(error.category);
  // Для вимови й наголосу «неправильно / правильно» — підказка кирилицею, а не хорватське речення
  const text = (value: string, c: string) => (spoken ? <p className={c}>{value}</p> : <Hr as="p" className={c}>{value}</Hr>);

  return (
    <Card className={cn('flex flex-col gap-3 border-warning-line', className)}>
      {heading && (
        <p className="flex items-center gap-2 text-label text-warning-ink">
          <Lightbulb className="size-4 shrink-0" aria-hidden="true" />
          {heading}
          <span className="ml-auto rounded-full bg-warning-soft px-2 py-0.5 text-caption">{categoryLabel(error.category)}</span>
        </p>
      )}
      <h3 className="font-heading text-h3">{error.title_ua}</h3>

      <div className="flex flex-col gap-2">
        {showWrong && (
          <div className="flex items-start gap-2 rounded-control bg-danger-soft px-3 py-2 text-danger-ink">
            <CircleX className="mt-0.5 size-5 shrink-0" aria-hidden="true" />
            <span className="sr-only">Неправильно:</span>
            {text(error.incorrect_text, 'min-w-0 flex-1 text-body line-through decoration-danger-line')}
          </div>
        )}
        <div className="flex items-start gap-2 rounded-control bg-success-soft px-3 py-2 text-success-ink">
          <CircleCheck className="mt-0.5 size-5 shrink-0" aria-hidden="true" />
          <span className="sr-only">Правильно:</span>
          {text(error.correct_text, 'min-w-0 flex-1 text-body font-semibold')}
          {!spoken && <AudioButton text={error.correct_text} label={`Прослухати «${error.correct_text}»`} className="-my-2 -mr-2" />}
        </div>
      </div>

      <p className="text-body">{error.explanation_ua}</p>

      {error.examples.length > 0 && (
        <ul className="flex flex-col gap-1 border-t border-line pt-3">
          {error.examples.map((ex) => (
            <li key={ex.hr} className="flex items-center gap-2">
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
  );
}
