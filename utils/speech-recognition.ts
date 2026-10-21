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
import { hasPlayedAudio, speakCroatian, stopCroatianAudio } from '@/utils/speech';
import { track } from '@/lib/analytics-client';
import { SpeechError, type ListeningSession, type SpeechErrorCode, type SpeechProvider, type TranscribeOptions } from '@/lib/speech-provider';
import { micAccessHelp, micPlatform, pickTranscripts } from '@/lib/speech-session';

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

/** Справжній код останньої помилки браузера (not-allowed / service-not-allowed …) — для точної підказки */
let lastRawError = '';

function transcribe({ lang, maxAlternatives = 3, onInterim, timeoutMs = 12000 }: TranscribeOptions): ListeningSession {
  const Ctor = recognitionCtor();
  if (!Ctor) {
    return { result: Promise.reject(new SpeechError('unsupported')), stop() {}, abort() {} };
  }

  // Safari: якщо в цей момент грає озвучення, розпізнавання не отримує мікрофон — спершу зупиняємо звук
  const wasPlaying = stopCroatianAudio();
  lastRawError = '';

  // Діагностика (2026-10-21, iPhone Safari: кнопка «слухає», але тексту немає): які події надіслав браузер.
  // Пишемо в analytics_events → speech_diagnostic; лише назви подій і час, без тексту й аудіо.
  const t0 = Date.now();
  const trace: string[] = [`${wasPlaying ? 'tts-on' : hasPlayedAudio() ? 'tts-was' : 'tts-no'}`, isStandalone() ? 'pwa' : 'tab'];
  let resultEvents = 0;
  const mark = (s: string) => {
    if (trace.length < 40) trace.push(`${s}@${Date.now() - t0}`);
  };
  const report = (outcome: string, heard: number) => {
    const platform = typeof navigator === 'undefined' ? 'other' : micPlatform(navigator.userAgent);
    // звичайні успішні спроби в Chrome не пишемо — лише Apple і всі невдалі
    if (platform === 'other' && heard > 0) return;
    track('speech_diagnostic', {
      success: heard > 0,
      verdict: outcome,
      count: resultEvents,
      duration_ms: Date.now() - t0,
      speech_platform: platform,
      speech_trace: trace.join(' ').slice(0, 200),
    });
  };

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
      mark('done');
      clearTimeout(timer);
      clearTimeout(graceTimer);
      fn();
    };
    finish = () =>
      settle(() => {
        if (aborted) {
          report('aborted', 0);
          return reject(new SpeechError('aborted'));
        }
        const ordered = [...finals.entries()].sort((a, b) => a[0] - b[0]).map(([, alts]) => alts);
        const transcripts = pickTranscripts(ordered, interim);
        report(transcripts.length > 0 ? 'ok' : 'empty', transcripts.length);
        resolve({ transcripts, durationMs: Date.now() - startedAt });
      });

    for (const [ev, short] of [
      ['start', 'st'], ['audiostart', 'au'], ['soundstart', 'so'], ['speechstart', 'sp'],
      ['speechend', 'spE'], ['soundend', 'soE'], ['audioend', 'auE'], ['nomatch', 'nm'],
    ] as const) {
      rec[`on${ev}`] = () => mark(short);
    }

    rec.onresult = (event: any) => {
      resultEvents += 1;
      if (resultEvents <= 3) mark(event.results?.[event.results.length - 1]?.isFinal ? 'rF' : 'r');
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
      lastRawError = String(event?.error ?? '').slice(0, 40);
      mark(`err:${String(event?.error ?? '?').slice(0, 24)}`);
      const code = ERROR_MAP[event?.error] ?? 'other';
      if (code === 'no-speech') return; // завершиться через onend з тим, що встигли почути
      settle(() => {
        report(`error:${String(event?.error ?? 'other').slice(0, 40)}`, 0);
        reject(new SpeechError(code, event?.message));
      });
    };
    rec.onend = () => {
      mark('end');
      finish();
    };
  });

  const stop = () => {
    mark('stop');
    try {
      rec.stop();
    } catch {
      /* уже зупинено */
    }
    // Safari інколи не надсилає onend після stop() — завершуємо самі з тим, що почули
    clearTimeout(graceTimer);
    graceTimer = setTimeout(() => {
      mark('grace');
      finish();
    }, STOP_GRACE_MS);
  };

  try {
    rec.start();
    timer = setTimeout(stop, timeoutMs);
  } catch (err) {
    mark(`throw:${String((err as { name?: string })?.name ?? err).slice(0, 24)}`);
    report('start-failed', 0);
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

/** Сторінку відкрито як застосунок з іконки (PWA), а не у вкладці браузера */
function isStandalone(): boolean {
  if (typeof window === 'undefined') return false;
  const nav = navigator as Navigator & { standalone?: boolean };
  return nav.standalone === true || window.matchMedia?.('(display-mode: standalone)').matches === true;
}

/** Підказка «немає доступу до мікрофона» для цього пристрою і браузера */
export function micHelpHere(tail = ''): string {
  if (typeof navigator === 'undefined') return micAccessHelp('', tail);
  return micAccessHelp(navigator.userAgent, tail, isStandalone(), lastRawError);
}

export const browserSpeech: SpeechProvider = {
  id: 'web_speech',
  isSupported: () => recognitionCtor() !== null,
  transcribe,
  synthesize: (text: string) => speakCroatian(text),
};
