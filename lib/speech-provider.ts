/**
 * Абстракція мовлення (§79). Компоненти працюють з інтерфейсом, а не з конкретним сервісом:
 * зараз розпізнавання — у браузері (Web Speech API, рішення власника 2026-10-12),
 * озвучення — /api/tts. Платний сервіс (Google STT, Whisper) підключається новою реалізацією.
 */
export type SpeechErrorCode =
  | 'unsupported'   // браузер не вміє розпізнавати мовлення
  | 'not-allowed'   // немає дозволу на мікрофон
  | 'audio-capture' // мікрофон не знайдено / зайнятий
  | 'network'       // розпізнавач потребує інтернету
  | 'no-speech'     // нічого не почули
  | 'aborted'
  | 'other';

export class SpeechError extends Error {
  constructor(public code: SpeechErrorCode, message?: string) {
    super(message ?? code);
    this.name = 'SpeechError';
  }
}

export interface TranscribeOptions {
  /** BCP-47, для хорватської — hr-HR */
  lang: string;
  /** Скільки варіантів розпізнавання повертати (n-best) */
  maxAlternatives?: number;
  /** Проміжний текст під час мовлення */
  onInterim?: (text: string) => void;
  /** Зупинити слухання через стільки мс (запобіжник) */
  timeoutMs?: number;
}

export interface TranscribeResult {
  /** Варіанти розпізнавання, найімовірніший — перший */
  transcripts: string[];
  durationMs: number;
}

export interface ListeningSession {
  result: Promise<TranscribeResult>;
  /** Завершити слухання і отримати результат */
  stop(): void;
  /** Скасувати без результату */
  abort(): void;
}

export interface SpeechProvider {
  /** Ідентифікатор для журналів (speaking_attempts.provider, ai_usage_events.provider) */
  readonly id: string;
  isSupported(): boolean;
  transcribe(options: TranscribeOptions): ListeningSession;
  synthesize(text: string): void;
  // detect_language() і pronunciation_analysis() (§79) — з'являться з платним сервісом
}
