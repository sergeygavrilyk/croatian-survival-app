'use client';

import { useEffect, useState } from 'react';
import { CONFETTI_COLORS, confettiPieces } from '@/lib/celebration';

/**
 * Конфеті на весь екран один раз (святковий екран після уроку, кінець сесії на 🎉).
 * Не заважає натискати (pointer-events-none), прихований від читачів екрана, із «Зменшити рух» — не показується.
 * Набір шматочків — з lib/celebration.ts (seed), прибирається після падіння.
 */
export default function Confetti({ seed = 'celebrate', count = 48 }: { seed?: string; count?: number }) {
  const [visible, setVisible] = useState(true);
  useEffect(() => {
    const t = window.setTimeout(() => setVisible(false), 4500);
    return () => window.clearTimeout(t);
  }, []);
  if (!visible) return null;
  return (
    <div aria-hidden="true" className="pointer-events-none fixed inset-0 z-50 overflow-hidden motion-reduce:hidden">
      {confettiPieces(seed, count).map((p, i) => (
        <span
          key={i}
          className="absolute top-0 block animate-confetti"
          style={
            {
              left: `${p.left}%`,
              width: p.width,
              height: p.height,
              background: CONFETTI_COLORS[p.color],
              borderRadius: p.round ? '9999px' : '2px',
              animationDelay: `${p.delay}ms`,
              animationDuration: `${p.duration}ms`,
              '--confetti-drift': `${p.drift}px`,
              '--confetti-spin': `${p.spin}deg`,
            } as React.CSSProperties
          }
        />
      ))}
    </div>
  );
}
