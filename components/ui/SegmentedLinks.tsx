'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { cn } from '@/lib/ui';

/**
 * Перемикач між двома-трьома сторінками одного розділу (напр. «Мої помилки» / «Типові помилки»).
 * Активна сторінка — точний збіг шляху (або activeHref, коли розрізняє параметр адреси: «/reading?level=A2»);
 * стан передається і кольором, і aria-current.
 */
export default function SegmentedLinks({
  items,
  label,
  className,
  activeHref,
}: {
  items: ReadonlyArray<{ href: string; label: string }>;
  label: string;
  className?: string;
  /** яке посилання активне, якщо шлях у всіх однаковий */
  activeHref?: string;
}) {
  const pathname = (usePathname() ?? '').replace(/\/+$/, '');
  return (
    <nav aria-label={label} className={cn('flex rounded-control bg-surface-muted p-1', className)}>
      {items.map(({ href, label: text }) => {
        const active = activeHref !== undefined ? activeHref === href : pathname === href;
        return (
          <Link
            key={href}
            href={href}
            aria-current={active ? 'page' : undefined}
            className={cn(
              'flex min-h-11 flex-1 items-center justify-center rounded-control px-3 text-center text-label transition-colors duration-150',
              active ? 'bg-surface text-ink shadow-sm' : 'text-ink-muted hover:text-ink',
            )}
          >
            {text}
          </Link>
        );
      })}
    </nav>
  );
}
