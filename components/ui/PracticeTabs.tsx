'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/ui';

const TABS = [
  { href: '/trainer', label: 'Тренажер' },
  { href: '/mistakes', label: 'Помилки' },
  { href: '/dictionary', label: 'Словник' },
] as const;

/** Вкладки розділу «Практика»: тренажер, помилки з рольової гри, словник (docs/DESIGN_SYSTEM.md §7.1). */
export default function PracticeTabs({ className }: { className?: string }) {
  const pathname = usePathname() ?? '';
  return (
    <nav aria-label="Розділи практики" className={cn('flex gap-6 border-b border-line', className)}>
      {TABS.map(({ href, label }) => {
        const active = pathname.startsWith(href);
        return (
          <Link
            key={href}
            href={href}
            aria-current={active ? 'page' : undefined}
            className={cn(
              '-mb-px flex min-h-11 items-center border-b-2 text-label transition-colors duration-150',
              active ? 'border-primary text-primary-ink' : 'border-transparent text-ink-muted hover:text-ink',
            )}
          >
            {label}
          </Link>
        );
      })}
    </nav>
  );
}
