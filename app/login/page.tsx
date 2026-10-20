'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import { MIN_PASSWORD_LENGTH, authErrorUk, newPasswordProblem } from '@/lib/auth';
import { cn } from '@/lib/ui';
import AuthShell, { AuthField, AuthMessage } from '@/components/AuthShell';
import Button, { buttonClasses } from '@/components/ui/Button';

/** Вхід і реєстрація (DESIGN_SYSTEM §3.4, §8): тексти помилок — українською (lib/auth.ts). */
export default function LoginPage() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isSignUp, setIsSignUp] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [notice, setNotice] = useState<string | null>(null);
  const router = useRouter();
  const [supabase] = useState(() => createClient());

  // Повернення з недійсного посилання з листа (/auth/confirm → /login?error=link)
  useEffect(() => {
    if (new URLSearchParams(window.location.search).get('error') === 'link') {
      setError('Посилання з листа недійсне або застаріле. Надішліть новий лист і відкрийте його на цьому ж пристрої.');
    }
  }, []);

  const switchMode = (signUp: boolean) => {
    setIsSignUp(signUp);
    setError(null);
    setNotice(null);
  };

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setNotice(null);
    if (isSignUp) {
      const problem = newPasswordProblem(password);
      if (problem) {
        setError(problem);
        return;
      }
    }
    setLoading(true);
    try {
      if (isSignUp) {
        const { data, error } = await supabase.auth.signUp({ email, password });
        if (error) throw error;
        // Якщо в Supabase увімкнено підтвердження пошти, сесії ще немає — спершу лист
        if (!data.session) {
          setNotice('Майже готово! Ми надіслали лист — відкрийте посилання з нього, щоб підтвердити пошту.');
          return;
        }
        router.push('/lessons');
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
        router.push('/');
      }
    } catch (err) {
      setError(authErrorUk(err instanceof Error ? err.message : String(err)));
    } finally {
      setLoading(false);
    }
  };

  const handleResetPassword = async () => {
    setNotice(null);
    if (!email) {
      setError('Введіть ваш email — надішлемо на нього лист для нового пароля.');
      return;
    }
    setError(null);
    const { error } = await supabase.auth.resetPasswordForEmail(email, {
      // Посилання з листа веде на /auth/confirm, а звідти — на сторінку нового пароля
      redirectTo: `${window.location.origin}/auth/confirm?next=/reset-password`,
    });
    if (error) setError(authErrorUk(error.message));
    else setNotice('Лист надіслано. Відкрийте посилання з нього на цьому ж пристрої.');
  };

  return (
    <AuthShell
      title={isSignUp ? 'Почнімо!' : 'Раді вас бачити!'}
      subtitle="Хорватська для українців: від першого «Bok!» до розмови з лікарем."
    >
      <div role="group" aria-label="Вхід чи реєстрація" className="grid grid-cols-2 gap-1 rounded-control bg-surface-muted p-1">
        {([
          [false, 'Вхід'],
          [true, 'Реєстрація'],
        ] as const).map(([signUp, label]) => (
          <button
            key={label}
            type="button"
            aria-pressed={isSignUp === signUp}
            onClick={() => switchMode(signUp)}
            className={cn(
              'flex min-h-11 items-center justify-center rounded-control font-heading text-label transition-colors duration-150',
              isSignUp === signUp ? 'bg-surface text-primary-ink shadow-sm' : 'text-ink-muted hover:text-ink',
            )}
          >
            {label}
          </button>
        ))}
      </div>

      <form onSubmit={handleAuth} className="flex flex-col gap-4">
        <AuthField
          id="email"
          label="Email"
          type="email"
          autoComplete="email"
          inputMode="email"
          value={email}
          onChange={(e) => setEmail(e.target.value)}
          required
          placeholder="ваша@пошта.com"
        />

        <div className="flex flex-col gap-1">
          <AuthField
            id="password"
            label="Пароль"
            type="password"
            autoComplete={isSignUp ? 'new-password' : 'current-password'}
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            minLength={isSignUp ? MIN_PASSWORD_LENGTH : undefined}
            hint={isSignUp ? `Щонайменше ${MIN_PASSWORD_LENGTH} символів` : undefined}
          />
          {!isSignUp && (
            <button type="button" onClick={() => void handleResetPassword()} className={buttonClasses('tertiary', 'sm', 'self-end px-2')}>
              Забули пароль?
            </button>
          )}
        </div>

        {error && <AuthMessage kind="error">{error}</AuthMessage>}
        {notice && <AuthMessage kind="ok">{notice}</AuthMessage>}

        <Button type="submit" block loading={loading}>
          {loading ? 'Зачекайте…' : isSignUp ? 'Створити акаунт' : 'Увійти'}
        </Button>
      </form>
    </AuthShell>
  );
}
