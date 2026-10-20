import Card from '@/components/ui/Card';

/**
 * Обгортка сторінок входу й нового пароля (радісний дизайн, DESIGN_SYSTEM §3.4):
 * 👋, що махає (з «Зменшити рух» — стоїть), назва застосунку, картка з формою.
 */
export default function AuthShell({ title, subtitle, children }: { title: string; subtitle?: string; children: React.ReactNode }) {
  return (
    <div className="flex min-h-screen flex-col items-center justify-center px-5 py-10">
      <div className="flex w-full max-w-sm animate-fade-in-up flex-col gap-6">
        <div className="flex flex-col items-center gap-3 text-center">
          <span className="flex size-20 items-center justify-center rounded-full bg-level-a0-soft text-5xl leading-none" aria-hidden="true">
            <span className="inline-block origin-[70%_70%] animate-wave">👋</span>
          </span>
          <div>
            <p className="font-heading text-label text-level-a0-ink">Croatian Survival</p>
            <h1 className="font-heading text-h1">{title}</h1>
            {subtitle && <p className="mt-1 text-body text-ink-muted">{subtitle}</p>}
          </div>
        </div>
        <Card hero className="flex flex-col gap-4">
          {children}
        </Card>
      </div>
    </div>
  );
}

/** Поле форми входу: підпис + поле 16 px (iOS не збільшує сторінку) + підказка. */
export function AuthField({
  id,
  label,
  hint,
  ...input
}: React.InputHTMLAttributes<HTMLInputElement> & { id: string; label: string; hint?: string }) {
  return (
    <div className="flex flex-col gap-1.5">
      <label htmlFor={id} className="text-label text-ink">
        {label}
      </label>
      <input
        id={id}
        aria-describedby={hint ? `${id}-hint` : undefined}
        className="min-h-12 w-full rounded-control border border-line bg-surface px-4 text-body placeholder:text-ink-subtle focus:border-primary"
        {...input}
      />
      {hint && (
        <p id={`${id}-hint`} className="text-caption text-ink-subtle">
          {hint}
        </p>
      )}
    </div>
  );
}

/** Повідомлення під формою: помилка (рожеве) або успіх (зелене), з role для читачів екрана. */
export function AuthMessage({ kind, children }: { kind: 'error' | 'ok'; children: React.ReactNode }) {
  return (
    <p
      role={kind === 'error' ? 'alert' : 'status'}
      className={
        kind === 'error'
          ? 'rounded-card border border-danger-line bg-danger-soft px-4 py-3 text-label font-normal text-danger-ink'
          : 'rounded-card border border-success-line bg-success-soft px-4 py-3 text-label font-normal text-success-ink'
      }
    >
      {children}
    </p>
  );
}
