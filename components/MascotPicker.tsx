'use client';

import { Check } from 'lucide-react';
import Mascot from '@/components/ui/Mascot';
import { MASCOTS, MASCOT_KINDS, type MascotKind } from '@/lib/mascot';
import { cn } from '@/lib/ui';

/** Вибір талісмана: Pjegica, Šime або Točka (онбординг, профіль). Радіогрупа з малюнками, працює з клавіатури. */
export default function MascotPicker({
  value,
  onChange,
  disabled,
  label = 'Талісман',
}: {
  value: MascotKind | null;
  onChange: (kind: MascotKind) => void;
  disabled?: boolean;
  label?: string;
}) {
  return (
    <div role="radiogroup" aria-label={label} className="grid grid-cols-3 gap-2">
      {MASCOT_KINDS.map((kind) => {
        const m = MASCOTS[kind];
        const selected = value === kind;
        return (
          <button
            key={kind}
            type="button"
            role="radio"
            aria-checked={selected}
            aria-label={`${m.name}, ${m.gloss}: ${m.details}`}
            title={m.details}
            disabled={disabled}
            onClick={() => onChange(kind)}
            className={cn(
              'relative flex min-w-0 flex-col items-center gap-0.5 rounded-card border bg-surface px-1.5 pb-2.5 pt-1.5 text-center transition-colors duration-150 active:scale-[0.98] disabled:opacity-60',
              selected ? 'border-primary bg-primary-soft' : 'border-line hover:border-primary/40',
            )}
          >
            {selected && (
              <span className="absolute right-1.5 top-1.5 flex size-5 items-center justify-center rounded-full bg-primary text-white" aria-hidden="true">
                <Check className="size-3.5" strokeWidth={3} />
              </span>
            )}
            <Mascot kind={kind} size={84} />
            <span lang="hr" className="text-body font-semibold">
              {m.name}
            </span>
            <span className="text-caption text-ink-muted">{m.gloss}</span>
          </button>
        );
      })}
    </div>
  );
}
