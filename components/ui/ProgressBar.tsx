import { cn } from '@/lib/ui';

/** Смуга прогресу з доступними значеннями (§98). */
export default function ProgressBar({
  value,
  max = 100,
  label,
  className,
  barClassName,
}: {
  value: number;
  max?: number;
  /** Підпис для програм читання з екрана, напр. «Прогрес уроку» */
  label: string;
  className?: string;
  /** Колір заповнення, напр. колір рівня (за замовчуванням bg-primary) */
  barClassName?: string;
}) {
  const safeMax = max > 0 ? max : 1;
  const clamped = Math.min(Math.max(value, 0), safeMax);
  const percent = Math.round((clamped / safeMax) * 100);
  return (
    <div
      role="progressbar"
      aria-label={label}
      aria-valuemin={0}
      aria-valuemax={safeMax}
      aria-valuenow={clamped}
      className={cn('h-2 w-full overflow-hidden rounded-full bg-surface-muted', className)}
    >
      <div className={cn('h-full rounded-full transition-[width] duration-300 ease-out', barClassName ?? 'bg-primary')} style={{ width: `${percent}%` }} />
    </div>
  );
}
