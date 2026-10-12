import { cn } from '@/lib/ui';

type CardProps = React.HTMLAttributes<HTMLDivElement> & {
  /** hero — навчальна картка: більший радіус і відступи */
  hero?: boolean;
};

/** Стандартна картка (docs/DESIGN_SYSTEM.md §5): фон, рамка, легка тінь. */
export default function Card({ hero, className, ...rest }: CardProps) {
  return (
    <div
      className={cn(
        'bg-surface border border-line shadow-sm',
        hero ? 'rounded-hero p-6' : 'rounded-card p-5',
        className,
      )}
      {...rest}
    />
  );
}
