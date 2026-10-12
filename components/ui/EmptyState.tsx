import { cn } from '@/lib/ui';

/** Порожній стан: що тут буде і що зробити зараз (docs/DESIGN_SYSTEM.md §11). */
export default function EmptyState({
  icon,
  title,
  text,
  action,
  className,
}: {
  icon?: React.ReactNode;
  title: string;
  text?: string;
  /** Одна дія, напр. <Button href="/lessons">…</Button> */
  action?: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn('flex flex-col items-center px-6 py-12 text-center', className)}>
      {icon && <div className="mb-4 flex size-14 items-center justify-center rounded-full bg-primary-soft text-primary-ink">{icon}</div>}
      <h2 className="font-heading text-h3">{title}</h2>
      {text && <p className="mt-2 max-w-sm text-body text-ink-muted">{text}</p>}
      {action && <div className="mt-6">{action}</div>}
    </div>
  );
}
