'use client';

import { useEffect, useState, useSyncExternalStore } from 'react';
import { CircleCheck, Hourglass, X } from 'lucide-react';
import { browserStorage } from '@/lib/offline-copy';
import { QUEUE_CHANGED_EVENT, pendingCount, peekExpiredNotice, takeExpiredNotice } from '@/lib/offline-queue';
import { currentUserId, type QueueChangedDetail } from '@/lib/offline-client';
import { countUk } from '@/lib/format';
import { cn } from '@/lib/ui';

function subscribe(onChange: () => void) {
  window.addEventListener(QUEUE_CHANGED_EVENT, onChange);
  window.addEventListener('storage', onChange); // інша вкладка відправила чергу
  return () => {
    window.removeEventListener(QUEUE_CHANGED_EVENT, onChange);
    window.removeEventListener('storage', onChange);
  };
}

const pendingSnapshot = () => pendingCount(browserStorage(), currentUserId());
const expiredSnapshot = () => peekExpiredNotice(browserStorage(), currentUserId());
const zero = () => 0;

/**
 * Значок офлайн-черги на «Сьогодні» й «Уроках» (тексти — план офлайну §6, «Добро» власника 2026-11-16):
 * лише коли є що відправити — «⏳ 2 результати чекають на інтернет»; після відправлення — коротко
 * «✓ Прогрес збережено»; черга старша за 14 днів — одне повідомлення, яке людина закриває.
 */
export default function OfflinePendingNote({ className }: { className?: string }) {
  const pending = useSyncExternalStore(subscribe, pendingSnapshot, zero);
  const expired = useSyncExternalStore(subscribe, expiredSnapshot, zero);
  const [justSynced, setJustSynced] = useState(false);

  useEffect(() => {
    let timer: ReturnType<typeof setTimeout> | undefined;
    const onChange = (e: Event) => {
      const detail = (e as CustomEvent<QueueChangedDetail>).detail;
      if (detail?.reason !== 'synced' || !detail.synced) return;
      setJustSynced(true);
      clearTimeout(timer);
      timer = setTimeout(() => setJustSynced(false), 4_000);
    };
    window.addEventListener(QUEUE_CHANGED_EVENT, onChange);
    return () => {
      clearTimeout(timer);
      window.removeEventListener(QUEUE_CHANGED_EVENT, onChange);
    };
  }, []);

  const dismissExpired = () => {
    takeExpiredNotice(browserStorage(), currentUserId());
    window.dispatchEvent(new CustomEvent(QUEUE_CHANGED_EVENT, { detail: { reason: 'queued' } satisfies QueueChangedDetail }));
  };

  if (pending === 0 && expired === 0 && !justSynced) return null;

  return (
    <div className={cn('flex flex-col gap-2', className)} data-testid="offline-pending">
      {pending > 0 ? (
        <p role="status" className="flex items-center gap-2 rounded-full border border-warning-line bg-warning-soft px-3 py-1.5 text-label text-warning-ink">
          <Hourglass className="size-4 shrink-0" aria-hidden="true" />
          {countUk(pending, ['результат чекає', 'результати чекають', 'результатів чекають'])} на інтернет
        </p>
      ) : justSynced ? (
        <p role="status" className="flex items-center gap-2 rounded-full border border-success-line bg-success-soft px-3 py-1.5 text-label text-success-ink">
          <CircleCheck className="size-4 shrink-0" aria-hidden="true" />
          Прогрес збережено
        </p>
      ) : null}
      {expired > 0 && (
        <p role="alert" className="flex items-start gap-2 rounded-card border border-warning-line bg-warning-soft py-2 pr-1 pl-3 text-label font-normal text-warning-ink">
          <span className="min-w-0 flex-1 py-1">Частину результатів без інтернету старших за 14 днів не вдалося зберегти.</span>
          <button
            type="button"
            onClick={dismissExpired}
            aria-label="Закрити повідомлення"
            className="flex size-11 shrink-0 items-center justify-center rounded-full hover:bg-warning-line/40"
          >
            <X className="size-4" aria-hidden="true" />
          </button>
        </p>
      )}
    </div>
  );
}
