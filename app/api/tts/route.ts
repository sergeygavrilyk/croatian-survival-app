import { NextResponse } from 'next/server';

export async function GET(request: Request) {
  const { searchParams } = new URL(request.url);
  const text = searchParams.get('text');

  if (!text) {
    return new NextResponse('Text is required', { status: 400 });
  }

  // Запит до закритого від CORS хмарного ендпоінту
  const url = `https://translate.google.com/translate_tts?ie=UTF-8&q=${encodeURIComponent(text)}&tl=hr&client=tw-ob`;

  try {
    const res = await fetch(url, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)' // Обхід блокувань
      }
    });

    if (!res.ok) {
      return new NextResponse('Failed to fetch audio', { status: res.status });
    }

    const buffer = await res.arrayBuffer();

    // Повертаємо аудіопотік з кешуванням на рік (щоб не робити зайвих запитів)
    return new NextResponse(buffer, {
      headers: {
        'Content-Type': 'audio/mpeg',
        'Cache-Control': 'public, max-age=31536000, immutable',
      },
    });
  } catch (error) {
    return new NextResponse('Internal Server Error', { status: 500 });
  }
}