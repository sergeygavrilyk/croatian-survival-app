'use client';

import { useEffect, useState } from 'react';
import { createClient } from '@/utils/supabase/client';
import { MIN_PASSWORD_LENGTH, authErrorUk, newPasswordProblem } from '@/lib/auth';
import AuthShell, { AuthField, AuthMessage } from '@/components/AuthShell';
import Button from '@/components/ui/Button';
import Skeleton from '@/components/ui/Skeleton';

type Stage = 'checking' | 'ready' | 'invalid' | 'done';

/**
 * Новий пароль після переходу за посиланням з листа.
 * Сесію ставить /auth/confirm; якщо посилання старого формату (?code=…) веде сюди напряму —
 * обмінюємо код тут.
 */
export default function ResetPasswordPage() {
  const [supabase] = useState(() => createClient());
  const [stage, setStage] = useState<Stage>('checking');
  const [password, setPassword] = useState('');
  const [confirm, setConfirm] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [saving, setSaving] = useState(false);

  useEffect(() => {
    let cancelled = false;
    async function check() {
      const code = new URLSearchParams(window.location.search).get('code');
      if (code) {
        const { error: exchangeError } = await supabase.auth.exchangeCodeForSession(code);
        if (exchangeError) console.error('reset-password exchangeCode:', exchangeError.message);
        window.history.replaceState(null, '', '/reset-password');
      }
      const { data: { user } } = await supabase.auth.getUser();
      if (!cancelled) setStage(user ? 'ready' : 'invalid');
    }
    check();
    return () => {
      cancelled = true;
    };
  }, [supabase]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    const problem = newPasswordProblem(password, confirm);
    if (problem) {
      setError(problem);
      return;
    }
    setSaving(true);
    const { error: updateError } = await supabase.auth.updateUser({ password });
    setSaving(false);
    if (updateError) {
      setError(authErrorUk(updateError.message));
      return;
    }
    setStage('done');
  };

  return (
    <AuthShell
      title={stage === 'done' ? 'Готово! 🎉' : 'Новий пароль'}
      subtitle={stage === 'ready' ? 'Придумайте новий пароль для свого акаунту.' : undefined}
    >
      {stage === 'checking' && (
        <div className="flex flex-col gap-3" role="status" aria-label="Перевіряємо посилання">
          <Skeleton className="h-12 rounded-control" />
          <Skeleton className="h-12 rounded-control" />
          <p className="text-center text-label font-normal text-ink-muted">Перевіряємо посилання…</p>
        </div>
      )}

      {stage === 'invalid' && (
        <>
          <AuthMessage kind="error">
            Посилання недійсне або застаріле. Надішліть новий лист: «Вхід» → «Забули пароль?». Відкривайте лист на тому ж пристрої,
            де його просили.
          </AuthMessage>
          <Button href="/login" block>
            До входу
          </Button>
        </>
      )}

      {stage === 'ready' && (
        <form onSubmit={handleSubmit} className="flex flex-col gap-4">
          <AuthField
            id="new-password"
            label="Новий пароль"
            type="password"
            autoComplete="new-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            required
            minLength={MIN_PASSWORD_LENGTH}
            hint={`Щонайменше ${MIN_PASSWORD_LENGTH} символів`}
          />
          <AuthField
            id="confirm-password"
            label="Повторіть пароль"
            type="password"
            autoComplete="new-password"
            value={confirm}
            onChange={(e) => setConfirm(e.target.value)}
            required
          />
          {error && <AuthMessage kind="error">{error}</AuthMessage>}
          <Button type="submit" block loading={saving}>
            {saving ? 'Зберігаємо…' : 'Зберегти пароль'}
          </Button>
        </form>
      )}

      {stage === 'done' && (
        <>
          <AuthMessage kind="ok">Пароль змінено. Ви вже увійшли в акаунт.</AuthMessage>
          <Button href="/" block>
            На «Сьогодні»
          </Button>
        </>
      )}
    </AuthShell>
  );
}
