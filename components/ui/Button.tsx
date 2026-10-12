import Link from 'next/link';
import { cn } from '@/lib/ui';

type Variant = 'primary' | 'secondary' | 'tertiary' | 'success' | 'danger';
type Size = 'md' | 'sm';

const VARIANTS: Record<Variant, string> = {
  primary: 'bg-primary text-white hover:bg-primary-hover active:bg-primary-pressed',
  secondary: 'bg-primary-soft text-primary-ink hover:bg-blue-100',
  tertiary: 'text-ink-muted hover:bg-surface-muted hover:text-ink',
  success: 'bg-success text-white hover:bg-emerald-700',
  danger: 'bg-danger text-white hover:bg-rose-700',
};

const SIZES: Record<Size, string> = {
  md: 'min-h-12 px-5 text-label',
  sm: 'min-h-10 px-4 text-label',
};

/** Класи кнопки — для випадків, коли потрібен не <button>, а інший елемент. */
export function buttonClasses(variant: Variant = 'primary', size: Size = 'md', className?: string): string {
  return cn(
    'inline-flex items-center justify-center gap-2 rounded-control font-heading font-semibold',
    'transition-colors duration-150 ease-out active:scale-[0.98]',
    'disabled:pointer-events-none disabled:opacity-50',
    VARIANTS[variant],
    SIZES[size],
    className,
  );
}

interface CommonProps {
  variant?: Variant;
  size?: Size;
  /** Розтягнути на всю ширину */
  block?: boolean;
  className?: string;
  children: React.ReactNode;
}

type ButtonProps = CommonProps &
  Omit<React.ButtonHTMLAttributes<HTMLButtonElement>, 'className' | 'children'> & {
    href?: undefined;
    loading?: boolean;
  };

type LinkProps = CommonProps & { href: string; loading?: undefined };

/**
 * Кнопка дизайн-системи (docs/DESIGN_SYSTEM.md §8).
 * З `href` — посилання (next/link), без — звичайна <button>.
 */
export default function Button(props: ButtonProps | LinkProps) {
  if (props.href !== undefined) {
    const { href, variant = 'primary', size = 'md', block, className, children } = props;
    return (
      <Link href={href} className={buttonClasses(variant, size, cn(block && 'w-full', className))}>
        {children}
      </Link>
    );
  }

  const { variant = 'primary', size = 'md', block, className, children, loading, disabled, type, ...rest } = props;
  return (
    <button
      type={type ?? 'button'}
      className={buttonClasses(variant, size, cn(block && 'w-full', className))}
      disabled={disabled || loading}
      aria-busy={loading || undefined}
      {...rest}
    >
      {loading && (
        <span className="size-4 rounded-full border-2 border-current border-t-transparent animate-spin" aria-hidden="true" />
      )}
      {children}
    </button>
  );
}
