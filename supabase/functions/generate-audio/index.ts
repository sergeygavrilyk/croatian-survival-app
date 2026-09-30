import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  try {
    const { text, recordId } = await req.json()

    if (!text || !recordId) {
      return new Response(JSON.stringify({ error: 'Missing text or recordId' }), { status: 400 })
    }

    // 1. Отримуємо аудіопотік із хмарного TTS (серверний запит обходить CORS)
    const encodedText = encodeURIComponent(text)
    const ttsUrl = `https://translate.google.com/translate_tts?ie=UTF-8&q=${encodedText}&tl=hr&client=tw-ob`

    const ttsResponse = await fetch(ttsUrl, {
      headers: {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)'
      }
    })

    if (!ttsResponse.ok) {
      throw new Error(`Failed to fetch TTS: ${ttsResponse.statusText}`)
    }

    const audioBuffer = await ttsResponse.arrayBuffer()

    // 2. Ініціалізуємо Supabase клієнт з правами адміністратора (Service Role)
    const supabaseAdmin = createClient(
      Deno.env.get('SUPABASE_URL') ?? '',
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
    )

    const fileName = `${recordId}.mp3`

    // 3. Завантажуємо файл у Supabase Storage (бакет 'audio')
    const { error: uploadError } = await supabaseAdmin.storage
      .from('audio')
      .upload(fileName, audioBuffer, {
        contentType: 'audio/mpeg',
        upsert: true
      })

    if (uploadError) {
      throw uploadError
    }

    // 4. Отримуємо публічне посилання на файл
    const { data: publicUrlData } = supabaseAdmin.storage
      .from('audio')
      .getPublicUrl(fileName)

    const audioUrl = publicUrlData.publicUrl

    // 5. Зберігаємо посилання в таблицю vocabulary
    const { error: updateError } = await supabaseAdmin
      .from('vocabulary')
      .update({ audio_url: audioUrl })
      .eq('id', recordId)

    if (updateError) {
      throw updateError
    }

    return new Response(JSON.stringify({ success: true, audio_url: audioUrl }), {
      headers: { 'Content-Type': 'application/json' },
      status: 200,
    })

  } catch (err: any) {
    return new Response(JSON.stringify({ error: err.message }), {
      headers: { 'Content-Type': 'application/json' },
      status: 500,
    })
  }
})