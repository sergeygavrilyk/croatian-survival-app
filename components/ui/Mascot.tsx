'use client';

import { useSyncExternalStore } from 'react';
import Image from 'next/image';
import { MASCOT_STORAGE_KEY, mascotInfo, readStoredMascot, type MascotKind } from '@/lib/mascot';
import { cn } from '@/lib/ui';

/**
 * Талісман-далматинець (Pjegica, Šime або Točka — вибір у профілі). Малюнок SVG 200×200 з прозорим фоном.
 * hello — легенько хитає головою двічі (вітання); pop — «вискакує» (святковий екран). Із «Зменшити рух» — стоїть.
 * Без alt — декоративний (поруч є текст); unoptimized — SVG маленький, віддається як є й працює офлайн.
 */
export default function Mascot({
  kind,
  size = 64,
  alt = '',
  hello,
  pop,
  className,
}: {
  kind: MascotKind | null | undefined;
  size?: number;
  alt?: string;
  hello?: boolean;
  pop?: boolean;
  className?: string;
}) {
  const m = mascotInfo(kind);
  return (
    <Image
      src={m.src}
      width={size}
      height={size}
      alt={alt}
      unoptimized
      draggable={false}
      className={cn('shrink-0 select-none', hello && 'origin-bottom animate-hello', pop && 'animate-pop', className)}
    />
  );
}

const subscribe = (onChange: () => void) => {
  const handler = (e: StorageEvent) => {
    if (e.key === MASCOT_STORAGE_KEY) onChange();
  };
  window.addEventListener('storage', handler);
  return () => window.removeEventListener('storage', handler);
};

/** Вибір талісмана, збережений у цьому браузері (для екранів, що працюють офлайн); на сервері — null. */
export function useStoredMascot(): MascotKind | null {
  return useSyncExternalStore(
    subscribe,
    () => readStoredMascot(typeof window === 'undefined' ? null : window.localStorage),
    () => null,
  );
}
