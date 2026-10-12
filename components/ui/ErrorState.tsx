import { CloudOff } from 'lucide-react';
import { cn } from '@/lib/ui';
import Button from './Button';

/** Помилка людською мовою + повтор (docs/DESIGN_SYSTEM.md §11). Ніколи не «500 Internal Server Error». */
export default function ErrorState({
  title = 'Не вдалося завантажити',
  text = 'Ваш прогрес збережено. Перевірте інтернет і спробуйте ще раз.',
  onRetry,
  className,
}: {
  title?: string;
  text?: string;
  onRetry?: () => void;
  className?: string;
}) {
  return (
    <div role="alert" className={cn('flex flex-col items-center px-6 py-12 text-center', className)}>
      <div className="mb-4 flex size-14 items-center justify-center rounded-full bg-danger-soft text-danger-ink">
        <CloudOff className="size-6" aria-hidden="true" />
      </div>
      <h2 className="font-heading text-h3">{title}</h2>
      <p className="mt-2 max-w-sm text-body text-ink-muted">{text}</p>
      {onRetry && (
        <Button variant="secondary" className="mt-6" onClick={onRetry}>
          Спробувати ще раз
        </Button>
      )}
    </div>
  );
}
