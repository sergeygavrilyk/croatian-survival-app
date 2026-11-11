import { NextResponse } from 'next/server';
import { createClient } from '@/utils/supabase/server';
import { recordAiUsage } from '@/lib/ai-usage-server';
import { checkTtsText, quotaAllows, secondsUntilUtcMidnight } from '@/lib/tts';

/**
 * Озвучення хорватського тексту (неофіційний Google Translate TTS).
 * Лише для залогінених; текст до 300 символів; до 300 запитів на добу на користувача
 * (рішення власника 2026-11-11, лічильник — public.consume_tts_quota(), міграція M22).
 */
export async function GET(request: Request) {
  const supabase = await createClient();
  const { data: { user } } = await supabase.auth.getUser();
  if (!user) {
    return new NextResponse('Login required', { status: 401 });
  }

  const { searchParams } = new URL(request.url);
  const check = checkTtsText(searchParams.get('text'));
  if (!check.ok) {
    return new NextResponse(check.error, { status: check.status });
  }
  const text = check.text;

  const { data: quota, error: quotaError } = await supabase.rpc('consume_tts_quota');
  if (quotaError) console.warn('consume_tts_quota: лічильник недоступний, пропускаємо', quotaError.message);
  if (!quotaAllows(quota, quotaError)) {
    return new NextResponse('Daily text-to-speech limit reached', {
      status: 429,
      headers: { 'Retry-After': String(secondsUntilUtcMidnight(new Date())) },
    });
  }

  const url = `https://translate.google.com/translate_tts?ie=UTF-8&q=${encodeURIComponent(text)}&tl=hr&client=tw-ob`;
  const startedAt = Date.now();

  try {
    const res = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
      },
    });

    if (!res.ok) {
      await recordAiUsage({
        feature: 'tts', provider: 'google_translate_tts', characters: text.length,
        latencyMs: Date.now() - startedAt, success: false, errorCode: `http_${res.status}`,
      });
      return new NextResponse('Failed to fetch audio', { status: 502 });
    }

    const buffer = await res.arrayBuffer();
    await recordAiUsage({
      feature: 'tts', provider: 'google_translate_tts', characters: text.length,
      latencyMs: Date.now() - startedAt, success: true,
    });

    // Кешує лише браузер користувача (private): повторне 🔊 того ж тексту не витрачає ліміт
    return new NextResponse(buffer, {
      headers: {
        'Content-Type': 'audio/mpeg',
        'Cache-Control': 'private, max-age=31536000, immutable',
      },
    });
  } catch {
    await recordAiUsage({
      feature: 'tts', provider: 'google_translate_tts', characters: text.length,
      latencyMs: Date.now() - startedAt, success: false, errorCode: 'fetch_failed',
    });
    return new NextResponse('Internal Server Error', { status: 500 });
  }
}
