'use client';

import { Volume2 } from 'lucide-react';
import { speakCroatian } from '@/utils/speech';
import IconButton from './IconButton';
import { cn } from '@/lib/ui';

/** 🔊 Прослухати хорватський текст (docs/DESIGN_SYSTEM.md §8). */
export default function AudioButton({ text, className, label = 'Прослухати' }: { text: string; className?: string; label?: string }) {
  return (
    <IconButton
      label={label}
      onClick={(e) => {
        e.stopPropagation();
        speakCroatian(text);
      }}
      className={cn('text-primary-ink hover:bg-primary-soft hover:text-primary-ink', className)}
    >
      <Volume2 className="size-5" aria-hidden="true" />
    </IconButton>
  );
}
