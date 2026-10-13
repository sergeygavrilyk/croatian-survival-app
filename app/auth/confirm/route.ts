import { NextResponse, type NextRequest } from 'next/server';
import type { EmailOtpType } from '@supabase/supabase-js';
import { createClient } from '@/utils/supabase/server';

const OTP_TYPES: EmailOtpType[] = ['recovery', 'signup', 'invite', 'magiclink', 'email_change', 'email'];

/** Куди можна перенаправити після входу за посиланням: лише внутрішні сторінки застосунку. */
function safeNext(raw: string | null): string {
  if (!raw || !raw.startsWith('/') || raw.startsWith('//')) return '/';
  return raw;
}

/**
 * Посилання з листа Supabase (відновлення пароля, підтвердження пошти).
 * Підтримує обидва формати:
 *   ?token_hash=…&type=recovery — працює в будь-якому браузері (рекомендований шаблон листа);
 *   ?code=…                    — стандартний лист Supabase (PKCE), працює в тому ж браузері,
 *                                 де просили лист.
 * Після успіху — сесія в cookies і перехід на `next` (для пароля — /reset-password).
 */
export async function GET(request: NextRequest) {
  const { searchParams, origin } = request.nextUrl;
  const tokenHash = searchParams.get('token_hash');
  const type = searchParams.get('type') as EmailOtpType | null;
  const code = searchParams.get('code');
  const next = safeNext(searchParams.get('next') ?? (type === 'recovery' ? '/reset-password' : '/'));

  const supabase = await createClient();

  if (tokenHash && type && OTP_TYPES.includes(type)) {
    const { error } = await supabase.auth.verifyOtp({ type, token_hash: tokenHash });
    if (!error) return NextResponse.redirect(new URL(next, origin));
    console.error('auth/confirm verifyOtp:', error.message);
  } else if (code) {
    const { error } = await supabase.auth.exchangeCodeForSession(code);
    if (!error) return NextResponse.redirect(new URL(next, origin));
    console.error('auth/confirm exchangeCode:', error.message);
  }

  // Посилання недійсне, застаріле або відкрите в іншому браузері
  const fail = new URL('/login', origin);
  fail.searchParams.set('error', 'link');
  return NextResponse.redirect(fail);
}
