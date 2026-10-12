/**
 * Реалізація SpeechProvider у браузері: розпізнавання — Web Speech API (hr-HR),
 * озвучення — наш /api/tts. Лише для клієнта.
 *
 * Важливо (приватність): у Chrome / Edge розпізнавання виконують сервери Google,
 * у Safari — Apple. Ми не записуємо і не зберігаємо аудіо — лише розпізнаний текст.
 */
import { speakCroatian } from '@/utils/speech';
import { SpeechError, type ListeningSession, type SpeechErrorCode, type SpeechProvider, type TranscribeOptions } from '@/lib/speech-provider';

/* eslint-disable @typescript-eslint/no-explicit-any */
type AnyRecognition = any;

function recognitionCtor(): (new () => AnyRecognition) | null {
  if (typeof window === 'undefined') return null;
  const w = window as any;
  return w.SpeechRecognition ?? w.webkitSpeechRecognition ?? null;
}

const ERROR_MAP: Record<string, SpeechErrorCode> = {
  'not-allowed': 'not-allowed',
  'service-not-allowed': 'not-allowed',
  'audio-capture': 'audio-capture',
  network: 'network',
  'no-speech': 'no-speech',
  aborted: 'aborted',
  'language-not-supported': 'unsupported',
};

function transcribe({ lang, maxAlternatives = 3, onInterim, timeoutMs = 12000 }: TranscribeOptions): ListeningSession {
  const Ctor = recognitionCtor();
  if (!Ctor) {
    return { result: Promise.reject(new SpeechError('unsupported')), stop() {}, abort() {} };
  }

  const rec: AnyRecognition = new Ctor();
  rec.lang = lang;
  rec.interimResults = true;
  rec.continuous = false;
  rec.maxAlternatives = maxAlternatives;

  const startedAt = Date.now();
  const finals: string[][] = []; // по одному масиву варіантів на кожен фрагмент
  let aborted = false;
  let timer: ReturnType<typeof setTimeout> | undefined;

  const result = new Promise<{ transcripts: string[]; durationMs: number }>((resolve, reject) => {
    rec.onresult = (event: any) => {
      let interim = '';
      for (let i = event.resultIndex; i < event.results.length; i++) {
        const res = event.results[i];
        if (res.isFinal) {
          const alts: string[] = [];
          for (let k = 0; k < res.length; k++) alts.push(String(res[k].transcript ?? '').trim());
          finals.push(alts.filter(Boolean));
        } else {
          interim += res[0]?.transcript ?? '';
        }
      }
      if (onInterim) onInterim([...finals.map((f) => f[0] ?? ''), interim].join(' ').trim());
    };
    rec.onerror = (event: any) => {
      const code = ERROR_MAP[event?.error] ?? 'other';
      if (code === 'no-speech') return; // завершиться через onend з порожнім результатом
      clearTimeout(timer);
      reject(new SpeechError(code, event?.message));
    };
    rec.onend = () => {
      clearTimeout(timer);
      if (aborted) return reject(new SpeechError('aborted'));
      // Склеюємо фрагменти: перший варіант кожного + альтернативи для однофрагментної фрази
      const transcripts =
        finals.length === 1 ? finals[0] : finals.length > 1 ? [finals.map((f) => f[0] ?? '').join(' ').trim()] : [];
      resolve({ transcripts, durationMs: Date.now() - startedAt });
    };
  });

  try {
    rec.start();
    timer = setTimeout(() => rec.stop(), timeoutMs);
  } catch (err) {
    return { result: Promise.reject(new SpeechError('other', String(err))), stop() {}, abort() {} };
  }

  return {
    result,
    stop: () => rec.stop(),
    abort: () => {
      aborted = true;
      rec.abort();
    },
  };
}

export const browserSpeech: SpeechProvider = {
  id: 'web_speech',
  isSupported: () => recognitionCtor() !== null,
  transcribe,
  synthesize: (text: string) => speakCroatian(text),
};
