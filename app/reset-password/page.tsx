'use client';

import { useEffect, useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';

type Stage = 'checking' | 'ready' | 'invalid' | 'done';

/**
 * Новий пароль після переходу за посиланням з листа.
 * Сесію ставить /auth/confirm; якщо посилання старого формату (?code=…) веде сюди напряму —
 * обмінюємо код тут.
 */
export default function ResetPasswordPage() {
  const router = useRouter();
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
    if (password.length < 6) {
      setError('Пароль має бути не коротший за 6 символів.');
      return;
    }
    if (password !== confirm) {
      setError('Паролі не збігаються.');
      return;
    }
    setSaving(true);
    const { error: updateError } = await supabase.auth.updateUser({ password });
    setSaving(false);
    if (updateError) {
      setError(
        updateError.message.toLowerCase().includes('different')
          ? 'Новий пароль має відрізнятися від старого.'
          : `Не вдалося змінити пароль: ${updateError.message}`
      );
      return;
    }
    setStage('done');
  };

  return (
    <div className="min-h-screen bg-gray-50 flex flex-col justify-center items-center p-4">
      <div className="max-w-sm w-full bg-white rounded-3xl shadow-md p-8">
        <h1 className="text-2xl font-bold text-gray-900 mb-2 text-center">Новий пароль</h1>

        {stage === 'checking' && <p className="text-gray-500 text-center">Перевіряємо посилання…</p>}

        {stage === 'invalid' && (
          <div className="text-center">
            <p role="alert" className="text-gray-600 mb-6">
              Посилання недійсне або застаріле. Надішліть новий лист: «Увійти» → «Забули пароль?».
              Відкривайте лист на тому ж пристрої, де його просили.
            </p>
            <button
              type="button"
              onClick={() => router.push('/login')}
              className="w-full min-h-11 bg-blue-600 text-white font-bold rounded-xl"
            >
              До входу
            </button>
          </div>
        )}

        {stage === 'ready' && (
          <form onSubmit={handleSubmit} className="space-y-4">
            <p className="text-gray-500 text-center mb-2">Придумайте новий пароль для свого акаунту.</p>
            <div>
              <label htmlFor="new-password" className="block text-sm font-medium text-gray-700 mb-1">Новий пароль</label>
              <input
                id="new-password"
                type="password"
                autoComplete="new-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800 text-base"
              />
            </div>
            <div>
              <label htmlFor="confirm-password" className="block text-sm font-medium text-gray-700 mb-1">Повторіть пароль</label>
              <input
                id="confirm-password"
                type="password"
                autoComplete="new-password"
                value={confirm}
                onChange={(e) => setConfirm(e.target.value)}
                required
                className="w-full px-4 py-3 rounded-xl border border-gray-200 focus:outline-none focus:ring-2 focus:ring-blue-500 text-gray-800 text-base"
              />
            </div>
            {error && <p role="alert" className="text-rose-700 text-sm text-center">{error}</p>}
            <button
              type="submit"
              disabled={saving}
              className="w-full min-h-11 bg-blue-600 hover:bg-blue-700 text-white font-bold py-3 rounded-xl disabled:opacity-50"
            >
              {saving ? 'Зберігаємо…' : 'Зберегти пароль'}
            </button>
          </form>
        )}

        {stage === 'done' && (
          <div className="text-center">
            <p role="status" className="text-emerald-700 font-semibold mb-6">Пароль змінено. Ви вже увійшли в акаунт.</p>
            <button
              type="button"
              onClick={() => router.push('/')}
              className="w-full min-h-11 bg-blue-600 text-white font-bold rounded-xl"
            >
              На головну
            </button>
          </div>
        )}
      </div>
    </div>
  );
}
