import { cn } from '@/lib/ui';

type IconButtonProps = Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, 'aria-label'> & {
  /** Обов'язковий підпис для програм читання з екрана (§98) */
  label: string;
};

/** Кнопка-іконка 44 × 44 (docs/DESIGN_SYSTEM.md §8). */
export default function IconButton({ label, className, type, children, ...rest }: IconButtonProps) {
  return (
    <button
      type={type ?? 'button'}
      aria-label={label}
      title={label}
      className={cn(
        'inline-flex size-11 shrink-0 items-center justify-center rounded-full text-ink-muted',
        'transition-colors duration-150 hover:bg-surface-muted hover:text-ink active:scale-[0.98]',
        'disabled:pointer-events-none disabled:opacity-50',
        className,
      )}
      {...rest}
    >
      {children}
    </button>
  );
}
