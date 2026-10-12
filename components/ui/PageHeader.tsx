'use client';

import { useRouter } from 'next/navigation';
import { ArrowLeft, X } from 'lucide-react';
import IconButton from './IconButton';
import { cn } from '@/lib/ui';

/**
 * Шапка екрана: ← Назад (або × Закрити) + заголовок + дія справа (docs/DESIGN_SYSTEM.md §7.2).
 * `backHref` — куди повертатися; без нього — крок назад в історії.
 */
export default function PageHeader({
  title,
  backHref,
  closeMode,
  onBack,
  action,
  className,
  children,
}: {
  title: string;
  backHref?: string;
  /** × замість ← (модалки, повноекранні заняття) */
  closeMode?: boolean;
  /** Власна дія для ← (напр. підтвердження виходу) */
  onBack?: () => void;
  action?: React.ReactNode;
  className?: string;
  /** Додатковий вміст під заголовком (вкладки, прогрес) */
  children?: React.ReactNode;
}) {
  const router = useRouter();
  const hasBack = Boolean(backHref || onBack || closeMode);
  const goBack = () => {
    if (onBack) return onBack();
    if (backHref) return router.push(backHref);
    router.back();
  };
  const Icon = closeMode ? X : ArrowLeft;

  return (
    <header className={cn('sticky top-0 z-20 border-b border-line bg-surface/95 px-4 pt-[calc(0.75rem+env(safe-area-inset-top))] pb-3', className)}>
      <div className="mx-auto flex max-w-2xl items-center gap-2">
        {hasBack && (
          <IconButton label={closeMode ? 'Закрити' : 'Назад'} onClick={goBack} className="-ml-2">
            <Icon className="size-6" aria-hidden="true" />
          </IconButton>
        )}
        <h1 className="min-w-0 flex-1 truncate font-heading text-h2">{title}</h1>
        {action}
      </div>
      {children && <div className="mx-auto mt-3 max-w-2xl">{children}</div>}
    </header>
  );
}
