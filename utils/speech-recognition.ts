/**
 * Реалізація SpeechProvider у браузері: розпізнавання — Web Speech API (hr-HR),
 * озвучення — наш /api/tts. Лише для клієнта.
 *
 * Важливо (приватність): у Chrome / Edge розпізнавання виконують сервери Google,
 * у Safari — Apple. Ми не записуємо і не зберігаємо аудіо — лише розпізнаний текст.
 *
 * Safari (2026-10-20): результат часто не позначається остаточним і onend інколи не приходить після stop() —
 * беремо проміжний текст (pickTranscripts) і завершуємо самі через STOP_GRACE_MS.
 */
import { speakCroatian } from '@/utils/speech';
import { SpeechError, type ListeningSession, type SpeechErrorCode, type SpeechProvider, type TranscribeOptions } from '@/lib/speech-provider';
import { pickTranscripts } from '@/lib/speech-session';

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

/** Скільки чекаємо onend після stop(): Safari іноді його не надсилає, і кнопка «висіла» б у стані «Слухаю…» */
const STOP_GRACE_MS = 1500;

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
  // Остаточні фрагменти за індексом результату: Safari надсилає той самий результат повторно
  const finals = new Map<number, string[]>();
  // Останній проміжний текст: Safari часто так і не позначає результат остаточним (isFinal)
  let interim = '';
  let aborted = false;
  let settled = false;
  let timer: ReturnType<typeof setTimeout> | undefined;
  let graceTimer: ReturnType<typeof setTimeout> | undefined;
  let settle: (fn: () => void) => void = () => {};
  let finish: () => void = () => {}; // завершити з тим, що почули (або «aborted»), — рівно один раз

  const result = new Promise<{ transcripts: string[]; durationMs: number }>((resolve, reject) => {
    settle = (fn) => {
      if (settled) return;
      settled = true;
      clearTimeout(timer);
      clearTimeout(graceTimer);
      fn();
    };
    finish = () =>
      settle(() => {
        if (aborted) return reject(new SpeechError('aborted'));
        const ordered = [...finals.entries()].sort((a, b) => a[0] - b[0]).map(([, alts]) => alts);
        resolve({ transcripts: pickTranscripts(ordered, interim), durationMs: Date.now() - startedAt });
      });

    rec.onresult = (event: any) => {
      let current = '';
      for (let i = event.resultIndex; i < event.results.length; i++) {
        const res = event.results[i];
        if (res.isFinal) {
          const alts: string[] = [];
          for (let k = 0; k < res.length; k++) alts.push(String(res[k].transcript ?? '').trim());
          finals.set(i, alts.filter(Boolean));
        } else {
          current += res[0]?.transcript ?? '';
        }
      }
      interim = current;
      if (onInterim) {
        const ordered = [...finals.entries()].sort((a, b) => a[0] - b[0]).map(([, alts]) => alts[0] ?? '');
        onInterim([...ordered, interim].join(' ').replace(/\s+/g, ' ').trim());
      }
    };
    rec.onerror = (event: any) => {
      const code = ERROR_MAP[event?.error] ?? 'other';
      if (code === 'no-speech') return; // завершиться через onend з тим, що встигли почути
      settle(() => reject(new SpeechError(code, event?.message)));
    };
    rec.onend = () => finish();
  });

  const stop = () => {
    try {
      rec.stop();
    } catch {
      /* уже зупинено */
    }
    // Safari інколи не надсилає onend після stop() — завершуємо самі з тим, що почули
    clearTimeout(graceTimer);
    graceTimer = setTimeout(() => finish(), STOP_GRACE_MS);
  };

  try {
    rec.start();
    timer = setTimeout(stop, timeoutMs);
  } catch (err) {
    return { result: Promise.reject(new SpeechError('other', String(err))), stop() {}, abort() {} };
  }

  return {
    result,
    stop,
    abort: () => {
      aborted = true;
      try {
        rec.abort();
      } catch {
        /* уже зупинено */
      }
      finish(); // → SpeechError('aborted'), навіть якщо браузер не надішле onend
    },
  };
}

export const browserSpeech: SpeechProvider = {
  id: 'web_speech',
  isSupported: () => recognitionCtor() !== null,
  transcribe,
  synthesize: (text: string) => speakCroatian(text),
};
