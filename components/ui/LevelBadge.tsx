import { levelStyle } from '@/lib/levels';
import { cn } from '@/lib/ui';

/** Рівень CEFR (A0 … B2) у кольорі рівня — docs/DESIGN_SYSTEM.md §3.4, §8. */
export default function LevelBadge({ level, className }: { level: string; className?: string }) {
  const s = levelStyle(level);
  return (
    <span
      className={cn('inline-flex items-center rounded-full px-2.5 py-0.5 text-caption font-semibold', s.soft, s.ink, className)}
    >
      {level}
    </span>
  );
}
