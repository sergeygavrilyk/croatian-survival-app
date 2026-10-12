'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { House, BookOpen, Layers, MessagesSquare, User, type LucideIcon } from 'lucide-react';
import { TABS, activeTab, showsBottomNav, type TabKey } from '@/lib/navigation';
import { cn } from '@/lib/ui';

const ICONS: Record<TabKey, LucideIcon> = {
  today: House,
  lessons: BookOpen,
  practice: Layers,
  situations: MessagesSquare,
  profile: User,
};

/** Єдина нижня навігація застосунку (docs/DESIGN_SYSTEM.md §7.2). Сторінки під нею мають `pb-28`. */
export default function BottomNav() {
  const pathname = usePathname() ?? '/';
  if (!showsBottomNav(pathname)) return null;
  const current = activeTab(pathname);

  return (
    <nav
      aria-label="Головна навігація"
      className="fixed inset-x-0 bottom-0 z-40 border-t border-line bg-surface/95 pb-[env(safe-area-inset-bottom)]"
    >
      <ul className="mx-auto grid max-w-2xl grid-cols-5">
        {TABS.map(({ key, href, label }) => {
          const active = current === key;
          const Icon = ICONS[key];
          return (
            <li key={key}>
              <Link
                href={href}
                aria-current={active ? 'page' : undefined}
                className={cn(
                  'flex min-h-16 flex-col items-center justify-center gap-1 px-1 text-caption transition-colors duration-150',
                  active ? 'font-bold text-primary-ink' : 'text-ink-subtle hover:text-ink',
                )}
              >
                <Icon className="size-6" strokeWidth={active ? 2.5 : 2} aria-hidden="true" />
                <span className="truncate">{label}</span>
              </Link>
            </li>
          );
        })}
      </ul>
    </nav>
  );
}
