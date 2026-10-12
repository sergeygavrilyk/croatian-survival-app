import { cn } from '@/lib/ui';

/** Рівень CEFR (A0 … B2) — docs/DESIGN_SYSTEM.md §8. */
export default function LevelBadge({ level, className }: { level: string; className?: string }) {
  return (
    <span
      className={cn(
        'inline-flex items-center rounded-full bg-primary-soft px-2.5 py-0.5 text-caption font-semibold text-primary-ink',
        className,
      )}
    >
      {level}
    </span>
  );
}
