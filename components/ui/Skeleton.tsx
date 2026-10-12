import { cn } from '@/lib/ui';

/** Заглушка під час завантаження за формою вмісту (не спінер на весь екран). */
export default function Skeleton({ className }: { className?: string }) {
  return <div aria-hidden="true" className={cn('animate-pulse rounded-card bg-slate-200', className)} />;
}
