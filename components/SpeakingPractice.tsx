'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { CircleCheck, CircleAlert, Info, Mic, RotateCcw, Square } from 'lucide-react';
import Card from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import ProgressBar from '@/components/ui/ProgressBar';
import { browserSpeech } from '@/utils/speech-recognition';
import { SpeechError, type ListeningSession, type SpeechErrorCode } from '@/lib/speech-provider';
import { annotateOriginal, evaluateSpeech, type SpeechEvaluation, type SpeechVerdict } from '@/lib/speaking';
import { finishSpeakingSession, recordSpeakingAttempt, startSpeakingSession } from '@/app/actions/speaking';
import { cn, shuffle } from '@/lib/ui';

type Mode = 'repeat' | 'produce';

export interface SpeakingPhrase {
  id: string;
  text_hr: string;
  ukrainian_translation: string;
}

/** Скільки фраз в одному занятті — коротко, щоб не втомлювало */
const SESSION_SIZE = 10;

const VERDICT_UI: Record<SpeechVerdict, { tone: 'success' | 'warning' | 'neutral'; title: string; text?: string }> = {
  great: { tone: 'success', title: 'Чудово! Вас зрозуміють.' },
  understandable: { tone: 'success', title: 'Зрозуміло.', text: 'Фразу зрозуміють. Можна відшліфувати кілька слів.' },
  almost: { tone: 'warning', title: 'Майже.', text: 'Частину слів не розпізнано — спробуйте ще раз.' },
  retry: { tone: 'neutral', title: 'Не вдалося розібрати фразу.', text: 'Послухайте ще раз і скажіть трохи повільніше.' },
  no_speech: { tone: 'neutral', title: 'Нічого не почули.', text: 'Натисніть мікрофон і говоріть ближче до нього.' },
};

const ERROR_TEXT: Record<SpeechErrorCode, string> = {
  unsupported: 'Цей браузер не розпізнає мовлення. Спробуйте Chrome або Edge (Android, комп\'ютер) чи Safari на iPhone.',
  'not-allowed': 'Немає доступу до мікрофона. Дозвольте його в налаштуваннях браузера (значок біля адреси сторінки) і спробуйте ще раз.',
  'audio-capture': 'Мікрофон не знайдено або він зайнятий іншою програмою.',
  network: 'Розпізнавання мовлення потребує інтернету. Перевірте з\'єднання.',
  'no-speech': 'Нічого не почули. Спробуйте ще раз.',
  aborted: 'Розпізнавання зупинено.',
  other: 'Не вдалося розпізнати мовлення. Спробуйте ще раз.',
};

const TONE_CLASS = {
  success: 'bg-success-soft border-success-line text-success-ink',
  warning: 'bg-warning-soft border-warning-line text-warning-ink',
  neutral: 'bg-surface-muted border-line text-ink',
} as const;

/**
 * Говоріння (VS-003, §48–49): фраза → мовлення → розпізнавання (браузер, hr-HR) →
 * порівняння з очікуваною фразою → відгук (зміст → зрозумілість → слова) → повтор.
 * Аудіо не зберігаємо — лише розпізнаний текст.
 */
export default function SpeakingPractice({
  situation,
  phrases,
  onExit,
  onFallback,
}: {
  situation: string;
  phrases: SpeakingPhrase[];
  onExit: () => void;
  /** Перейти до «Перевір себе», якщо мікрофон недоступний */
  onFallback: () => void;
}) {
  const supported = useMemo(() => browserSpeech.isSupported(), []);
  const [mode, setMode] = useState<Mode | null>(null);
  const [round, setRound] = useState(0);
  const order = useMemo(() => shuffle(phrases).slice(0, SESSION_SIZE), [phrases, round]); // eslint-disable-line react-hooks/exhaustive-deps
  const [index, setIndex] = useState(0);
  const [retry, setRetry] = useState(0);
  const [listening, setListening] = useState(false);
  const [interim, setInterim] = useState('');
  const [result, setResult] = useState<SpeechEvaluation | null>(null);
  const [error, setError] = useState<SpeechErrorCode | null>(null);

  const sessionId = useRef<string | null>(null);
  const startedAt = useRef(Date.now());
  const listeningRef = useRef<ListeningSession | null>(null);
  const stats = useRef({ attempts: 0, understood: new Set<string>(), firstTry: 0 });

  const done = mode !== null && index >= order.length;
  const current = order[index];

  // Зупинити мікрофон, якщо користувач пішов з екрана
  useEffect(() => () => listeningRef.current?.abort(), []);

  const begin = (m: Mode) => {
    setMode(m);
    startedAt.current = Date.now();
    stats.current = { attempts: 0, understood: new Set(), firstTry: 0 };
    sessionId.current = null;
    void startSpeakingSession({ situation, mode: m, provider: browserSpeech.id }).then((id) => {
      sessionId.current = id;
    });
  };

  const listen = async () => {
    if (!current || !mode) return;
    if (typeof navigator !== 'undefined' && navigator.onLine === false) {
      setError('network');
      return;
    }
    setError(null);
    setResult(null);
    setInterim('');
    setListening(true);
    const session = browserSpeech.transcribe({ lang: 'hr-HR', maxAlternatives: 3, onInterim: setInterim });
    listeningRef.current = session;
    try {
      const { transcripts, durationMs } = await session.result;
      const evaluation = evaluateSpeech(current.text_hr, transcripts);
      setResult(evaluation);
      stats.current.attempts += 1;
      if (evaluation.verdict === 'great' || evaluation.verdict === 'understandable') {
        if (!stats.current.understood.has(current.id) && retry === 0) stats.current.firstTry += 1;
        stats.current.understood.add(current.id);
      }
      // Зберігаємо у фоні; сервер перераховує оцінку сам
      void recordSpeakingAttempt({
        sessionId: sessionId.current,
        phraseId: current.id,
        targetText: current.text_hr,
        mode,
        transcripts,
        retryNumber: retry,
        durationMs,
        provider: browserSpeech.id,
      });
    } catch (err) {
      const code = err instanceof SpeechError ? err.code : 'other';
      if (code !== 'aborted') setError(code);
    } finally {
      setListening(false);
      listeningRef.current = null;
    }
  };

  const next = () => {
    setResult(null);
    setError(null);
    setInterim('');
    setRetry(0);
    const nextIndex = index + 1;
    setIndex(nextIndex);
    if (nextIndex >= order.length && mode) {
      void finishSpeakingSession({
        sessionId: sessionId.current,
        situation,
        mode,
        phrases: order.length,
        understood: stats.current.understood.size,
        attempts: stats.current.attempts,
        durationMs: Date.now() - startedAt.current,
      });
    }
  };

  const again = () => {
    setRetry((r) => r + 1);
    setResult(null);
    setError(null);
    setInterim('');
  };

  const restart = () => {
    setRound((r) => r + 1);
    setIndex(0);
    setRetry(0);
    setResult(null);
    setError(null);
    if (mode) begin(mode);
  };

  // ---------------------------------------------------------------- браузер не вміє
  if (!supported) {
    return (
      <Card className="flex flex-col gap-4">
        <p className="flex items-start gap-3 text-body">
          <CircleAlert className="mt-0.5 size-5 shrink-0 text-warning" aria-hidden="true" />
          {ERROR_TEXT.unsupported}
        </p>
        <div className="flex flex-col gap-2 sm:flex-row">
          <Button onClick={onFallback}>Перевір себе без мікрофона</Button>
          <Button variant="tertiary" onClick={onExit}>
            До списку фраз
          </Button>
        </div>
      </Card>
    );
  }

  // ---------------------------------------------------------------- вибір режиму
  if (!mode) {
    return (
      <div className="flex flex-col gap-4 animate-fade-in-up">
        <div>
          <h2 className="font-heading text-h2">Говоріння</h2>
          <p className="mt-1 text-body text-ink-muted">Скажіть фразу вголос — застосунок перевірить, чи вас зрозуміють.</p>
        </div>
        <ModeButton
          title="Повторити за диктором"
          hint="Бачите й чуєте хорватську фразу, повторюєте її"
          onClick={() => begin('repeat')}
        />
        <ModeButton
          title="Сказати самому"
          hint="Бачите лише переклад — згадуєте й кажете хорватською"
          onClick={() => begin('produce')}
        />
        <p className="flex items-start gap-2 text-label font-normal text-ink-muted">
          <Info className="mt-0.5 size-4 shrink-0" aria-hidden="true" />
          Мовлення розпізнає ваш браузер (у Chrome — сервіс Google, у Safari — Apple). Ми не записуємо аудіо, зберігаємо лише
          розпізнаний текст.
        </p>
        <Button variant="tertiary" onClick={onExit}>
          До списку фраз
        </Button>
      </div>
    );
  }

  // ---------------------------------------------------------------- підсумок
  if (done) {
    return (
      <Card hero className="animate-fade-in-up text-center">
        <p className="text-label text-ink-muted">Результат</p>
        <p className="mt-1 font-heading text-display">
          {stats.current.understood.size} з {order.length}
        </p>
        <p className="mt-2 text-body text-ink-muted">
          фраз вас зрозуміють{stats.current.firstTry > 0 ? `, ${stats.current.firstTry} — з першої спроби` : ''}.
        </p>
        <div className="mt-6 flex flex-col gap-2 sm:flex-row sm:justify-center">
          <Button onClick={restart}>
            <RotateCcw className="size-5" aria-hidden="true" />
            Ще раз
          </Button>
          <Button variant="tertiary" onClick={onExit}>
            До списку фраз
          </Button>
        </div>
      </Card>
    );
  }

  // ---------------------------------------------------------------- фраза
  const showCroatian = mode === 'repeat' || result !== null;
  const ui = result ? VERDICT_UI[result.verdict] : null;

  return (
    <div className="flex flex-col gap-4">
      <div className="flex items-center gap-3">
        <ProgressBar value={index} max={order.length} label="Прогрес говоріння" />
        <span className="shrink-0 text-label text-ink-muted">
          {index + 1} / {order.length}
        </span>
      </div>

      <Card hero className="flex flex-col gap-4">
        <p className="text-label text-ink-muted">{mode === 'repeat' ? 'Послухайте і повторіть' : 'Скажіть хорватською'}</p>
        {mode === 'produce' && <p className="font-heading text-h2">{current.ukrainian_translation}</p>}
        {showCroatian && (
          <div className="flex items-start gap-3">
            <Hr as="p" className="min-w-0 flex-1 font-heading text-h2 break-words">
              {result ? <HighlightedPhrase target={current.text_hr} evaluation={result} /> : current.text_hr}
            </Hr>
            <AudioButton text={current.text_hr} />
          </div>
        )}
        {mode === 'repeat' && <p className="text-body text-ink-muted">{current.ukrainian_translation}</p>}

        {/* Мікрофон */}
        {!result && (
          <div className="flex flex-col items-center gap-3 py-2">
            <button
              type="button"
              onClick={() => (listening ? listeningRef.current?.stop() : void listen())}
              aria-label={listening ? 'Зупинити' : 'Почати говорити'}
              aria-pressed={listening}
              className={cn(
                'flex size-20 items-center justify-center rounded-full text-white shadow-md transition-colors duration-150 active:scale-[0.98]',
                listening ? 'bg-danger animate-pulse' : 'bg-primary hover:bg-primary-hover',
              )}
            >
              {listening ? <Square className="size-7" aria-hidden="true" /> : <Mic className="size-8" aria-hidden="true" />}
            </button>
            <p className="min-h-6 text-center text-label font-normal text-ink-muted" aria-live="polite">
              {listening ? (interim ? <Hr>{interim}</Hr> : 'Слухаю… говоріть') : 'Натисніть і скажіть фразу'}
            </p>
          </div>
        )}

        {error && (
          <p role="alert" className="rounded-card border border-warning-line bg-warning-soft p-4 text-body text-warning-ink">
            {ERROR_TEXT[error]}
          </p>
        )}

        {/* Відгук */}
        {result && ui && (
          <div className={cn('flex flex-col gap-3 rounded-card border p-4 animate-fade-in-up', TONE_CLASS[ui.tone])} role="status">
            <p className="flex items-center gap-2 text-label">
              {ui.tone === 'success' ? (
                <CircleCheck className="size-5" aria-hidden="true" />
              ) : (
                <CircleAlert className="size-5" aria-hidden="true" />
              )}
              {ui.title}
            </p>
            {ui.text && <p className="text-body">{ui.text}</p>}
            {result.transcript && (
              <p className="text-body text-ink">
                Ви сказали: «<Hr>{result.transcript}</Hr>»
              </p>
            )}
            {result.practiceWords.length > 0 && (
              <div>
                <p className="text-label font-normal text-ink-muted">Попрацюйте над словами:</p>
                <ul className="mt-2 flex flex-wrap gap-2">
                  {result.practiceWords.map((w) => (
                    <li key={w} className="flex items-center rounded-full border border-line bg-surface pl-3">
                      <Hr className="text-body">{w}</Hr>
                      <AudioButton text={w} label={`Прослухати «${w}»`} className="size-9" />
                    </li>
                  ))}
                </ul>
              </div>
            )}
          </div>
        )}

        {result && (
          <div className="grid grid-cols-2 gap-2">
            <Button variant="secondary" onClick={again}>
              <RotateCcw className="size-5" aria-hidden="true" />
              Ще раз
            </Button>
            <Button onClick={next}>{index + 1 < order.length ? 'Далі' : 'Завершити'}</Button>
          </div>
        )}
        {!result && !listening && (
          <Button variant="tertiary" onClick={next}>
            Пропустити фразу
          </Button>
        )}
      </Card>

      <p className="text-center text-caption text-ink-subtle">
        Розпізнавання приблизне: перевіряємо, чи вас зрозуміють, а не вимову до звуку.
      </p>
    </div>
  );
}

function ModeButton({ title, hint, onClick }: { title: string; hint: string; onClick: () => void }) {
  return (
    <button
      type="button"
      onClick={onClick}
      className="flex min-h-16 w-full items-center gap-3 rounded-card border border-line bg-surface px-4 py-3 text-left transition-colors duration-150 hover:border-primary/40 active:scale-[0.98]"
    >
      <span className="flex size-10 shrink-0 items-center justify-center rounded-full bg-primary-soft text-primary-ink" aria-hidden="true">
        <Mic className="size-5" />
      </span>
      <span>
        <span className="block text-body font-semibold">{title}</span>
        <span className="block text-label font-normal text-ink-muted">{hint}</span>
      </span>
    </button>
  );
}

/** Фраза з позначками: неточно розпізнані слова — хвиляста лінія, не почуті — тло. */
function HighlightedPhrase({ target, evaluation }: { target: string; evaluation: SpeechEvaluation }) {
  return (
    <>
      {annotateOriginal(target, evaluation.words).map((w, i) => (
        <span key={i}>
          {i > 0 && ' '}
          <span
            className={cn(
              w.status === 'close' && 'underline decoration-warning decoration-wavy decoration-2 underline-offset-4',
              w.status === 'missed' && 'rounded bg-warning-soft px-1 text-warning-ink',
            )}
          >
            {w.text}
          </span>
          {w.status === 'close' && <span className="sr-only"> (розпізнано неточно)</span>}
          {w.status === 'missed' && <span className="sr-only"> (не почули)</span>}
        </span>
      ))}
    </>
  );
}
