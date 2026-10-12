import { Sparkles } from 'lucide-react';
import { cn } from '@/lib/ui';

/**
 * Текст, згенерований AI (docs/DESIGN_SYSTEM.md §9.5, §11). Завжди з міткою:
 * він не пройшов перевірку контенту (§64), тому не змішується з уроками.
 */
export default function AiPanel({
  title = 'AI',
  children,
  className,
}: {
  title?: string;
  children: React.ReactNode;
  className?: string;
}) {
  return (
    <section className={cn('rounded-card border border-ai-line bg-ai-soft p-4 text-ink', className)}>
      <p className="mb-2 flex items-center gap-1.5 text-caption font-semibold text-ai-ink">
        <Sparkles className="size-4" aria-hidden="true" />
        {title}
      </p>
      {children}
      <p className="mt-3 text-caption text-ai-ink">Згенеровано AI — може містити неточності.</p>
    </section>
  );
}
