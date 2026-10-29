'use client';

import { useEffect, useRef, useState, useSyncExternalStore } from 'react';
import { ArrowRight, CircleAlert, CircleCheck, Mic, RotateCcw, SkipForward, Square, X } from 'lucide-react';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import IconButton from '@/components/ui/IconButton';
import ProgressBar from '@/components/ui/ProgressBar';
import StatTile from '@/components/ui/StatTile';
import { speakCroatian } from '@/utils/speech';
import { browserSpeech, micHelpHere } from '@/utils/speech-recognition';
import { SpeechError, type ListeningSession } from '@/lib/speech-provider';
import { evaluateSpeech, isUnderstood } from '@/lib/speaking';
import type { DialogueLine } from '@/lib/lesson-content';
import { levelStyle, type LevelStyle } from '@/lib/levels';
import { pluralUk } from '@/lib/format';
import { wordInitial } from '@/lib/word-theme';
import { startConversation, saveChatMessage } from '@/app/actions/chat';
import { cn } from '@/lib/ui';

export type { DialogueLine };

interface RoleplaySimulatorProps {
  lines: DialogueLine[];
  uniqueSpeakers: string[];
  /** Назва діалогу для шапки */
  title?: string;
  /** Колір рівня уроку (DESIGN_SYSTEM §3.4); за замовчуванням — A0 */
  level?: LevelStyle;
  onExit: () => void;
}

type Heard = { text: string; ok: boolean } | null;

const noSubscribe = () => () => {};

/**
 * «Відіграти роль» у діалозі уроку: користувач обирає персонажа, співрозмовник говорить сам,
 * свою репліку користувач каже вголос (розпізнає браузер через SpeechProvider, оцінює lib/speaking).
 * Немає мікрофона — репліку можна прочитати вголос і йти далі. Аудіо не зберігаємо — лише текст (ai_messages).
 */
export default function RoleplaySimulator({ lines, uniqueSpeakers, title = 'Діалог', level, onExit }: RoleplaySimulatorProps) {
  const lv = level ?? levelStyle('A0');
  const [role, setRole] = useState<string | null>(null);
  const [step, setStep] = useState(0);
  const [conversationId, setConversationId] = useState<string | null>(null);
  const [listening, setListening] = useState(false);
  const [interim, setInterim] = useState('');
  const [heard, setHeard] = useState<Heard>(null);
  const [error, setError] = useState<string | null>(null);
  const [said, setSaid] = useState(0); // репліки, які розпізнали з першої-другої спроби
  const sessionRef = useRef<ListeningSession | null>(null);
  const nextTimer = useRef<number | null>(null);
  const endRef = useRef<HTMLDivElement>(null);
  // Підтримку мікрофона перевіряємо лише в браузері (інакше сервер і клієнт намалюють різне)
  const micSupported = useSyncExternalStore(noSubscribe, () => browserSpeech.isSupported(), () => false);

  useEffect(
    () => () => {
      sessionRef.current?.abort();
      if (nextTimer.current) window.clearTimeout(nextTimer.current);
    },
    [],
  );
  useEffect(() => {
    if (role) endRef.current?.scrollIntoView({ behavior: 'smooth', block: 'end' });
  }, [step, role, heard]);

  const log = (convId: string | null, who: 'user' | 'assistant' | 'system', text: string) => {
    if (convId) void saveChatMessage(convId, who, text).catch(() => {});
  };

  const partnerSays = (index: number, convId: string | null, asRole: string) => {
    const line = lines[index];
    if (line && line.speaker_name !== asRole) {
      speakCroatian(line.hr_text);
      log(convId, 'assistant', line.hr_text);
    }
  };

  const start = async (speaker: string) => {
    setRole(speaker);
    setStep(0);
    setSaid(0);
    setHeard(null);
    setError(null);
    let convId: string | null = null;
    try {
      convId = await startConversation('roleplay');
    } catch {
      convId = null; // журнал розмови — необов'язковий, гра працює й без нього
    }
    setConversationId(convId);
    partnerSays(0, convId, speaker);
  };

  const goNext = () => {
    if (!role) return;
    if (nextTimer.current) {
      window.clearTimeout(nextTimer.current);
      nextTimer.current = null;
    }
    sessionRef.current?.abort();
    setListening(false);
    setHeard(null);
    setError(null);
    setInterim('');
    const next = step + 1;
    setStep(next);
    partnerSays(next, conversationId, role);
  };

  const listen = async (expected: string) => {
    if (listening) {
      sessionRef.current?.stop();
      return;
    }
    setError(null);
    setHeard(null);
    setInterim('');
    setListening(true);
    const session = browserSpeech.transcribe({ lang: 'hr-HR', maxAlternatives: 3, onInterim: setInterim });
    sessionRef.current = session;
    try {
      const { transcripts } = await session.result;
      const text = transcripts[0] ?? '';
      if (!text) {
        setError('Нічого не почули. Натисніть мікрофон і говоріть ближче до нього.');
        return;
      }
      log(conversationId, 'user', text);
      const ok = isUnderstood(evaluateSpeech(expected, transcripts).verdict);
      setHeard({ text, ok });
      if (ok) {
        setSaid((n) => n + 1);
        speakCroatian('Odlično!');
        nextTimer.current = window.setTimeout(goNext, 1400);
      }
    } catch (err) {
      const code = err instanceof SpeechError ? err.code : 'other';
      if (code === 'not-allowed') setError(micHelpHere('Або прочитайте репліку вголос і натисніть «Далі».'));
      else if (code !== 'aborted') setError('Не вдалося розпізнати мовлення. Спробуйте ще раз або пропустіть репліку.');
    } finally {
      setListening(false);
      setInterim('');
      sessionRef.current = null;
    }
  };

  const header = (
    <header className="sticky top-0 z-10 border-b border-line bg-canvas/95 pt-[env(safe-area-inset-top)]">
      <div className="mx-auto flex max-w-md items-center gap-2 px-2 py-2">
        <IconButton label="Закрити гру" onClick={onExit}>
          <X className="size-5" aria-hidden="true" />
        </IconButton>
        <div className="min-w-0 flex-1">
          <p className="truncate font-heading text-label">🎭 {title}</p>
          {role && (
            <ProgressBar
              value={Math.min(step, lines.length)}
              max={lines.length}
              label="Прогрес діалогу"
              className="mt-1"
              barClassName={lv.bar}
            />
          )}
        </div>
        {role && (
          <span className={cn('max-w-28 shrink-0 truncate rounded-full px-2.5 py-0.5 text-caption font-semibold', lv.soft, lv.ink)}>
            Ви: <Hr>{role}</Hr>
          </span>
        )}
      </div>
    </header>
  );

  // ---------------------------------------------------------------- вибір ролі
  if (!role) {
    return (
      <div className="flex min-h-screen flex-col">
        {header}
        <main className="mx-auto flex w-full max-w-md flex-1 flex-col gap-4 px-4 py-6">
          <Card hero className="flex flex-col items-center gap-3 text-center animate-fade-in-up">
            <span aria-hidden="true" className={cn('flex size-16 items-center justify-center rounded-card text-4xl leading-none', lv.soft)}>
              🎭
            </span>
            <h2 className="font-heading text-h2">Оберіть свою роль</h2>
            <p className="text-body text-ink-muted">
              Співрозмовник говоритиме сам, а свої репліки ви кажете вголос. Можна підглядати — текст репліки буде перед очима.
            </p>
          </Card>
          <ul className="flex flex-col gap-2">
            {uniqueSpeakers.map((speaker) => {
              const count = lines.filter((l) => l.speaker_name === speaker).length;
              return (
                <li key={speaker}>
                  <button
                    type="button"
                    onClick={() => void start(speaker)}
                    className={cn(
                      'flex min-h-16 w-full items-center gap-3 rounded-card border-2 bg-surface px-4 py-3 text-left shadow-sm',
                      'transition-colors duration-150 hover:border-primary active:scale-[0.98]',
                      lv.line,
                    )}
                  >
                    <span
                      aria-hidden="true"
                      className={cn('flex size-11 shrink-0 items-center justify-center rounded-full font-heading text-h3', lv.solid)}
                    >
                      {wordInitial(speaker)}
                    </span>
                    <span className="min-w-0 flex-1">
                      <span className="block text-label text-ink-muted">Я граю за</span>
                      <Hr className="block font-heading text-h3 break-words">{speaker}</Hr>
                    </span>
                    <span className="text-caption text-ink-subtle">
                      {count} {pluralUk(count, ['репліка', 'репліки', 'реплік'])}
                    </span>
                  </button>
                </li>
              );
            })}
          </ul>
        </main>
      </div>
    );
  }

  const finished = step >= lines.length;
  const current = lines[step];
  const myTurn = !finished && current?.speaker_name === role;
  const myLines = lines.filter((l) => l.speaker_name === role).length;
  const visible = lines.slice(0, Math.min(step + 1, lines.length));

  return (
    <div className="flex min-h-screen flex-col">
      {header}

      <main className="mx-auto flex w-full max-w-md flex-1 flex-col gap-3 px-4 py-5" aria-live="polite">
        <ol className="flex flex-col gap-3">
          {visible.map((line, i) => {
            const mine = line.speaker_name === role;
            const isCurrent = i === step && !finished;
            return (
              <li key={line.id} className={cn('flex flex-col animate-fade-in-up', mine ? 'items-end' : 'items-start')}>
                <span className={cn('mb-1 flex items-center gap-1.5 px-1', mine && 'flex-row-reverse')}>
                  <span
                    aria-hidden="true"
                    className={cn(
                      'flex size-6 items-center justify-center rounded-full font-heading text-caption',
                      mine ? 'bg-primary-soft text-primary-ink' : cn(lv.soft, lv.ink),
                    )}
                  >
                    {wordInitial(line.speaker_name)}
                  </span>
                  <span className="text-caption text-ink-muted">
                    {mine ? 'Ви' : <Hr>{line.speaker_name}</Hr>}
                  </span>
                </span>
                <button
                  type="button"
                  onClick={() => speakCroatian(line.hr_text)}
                  aria-label={`Прослухати: ${line.hr_text}`}
                  className={cn(
                    'max-w-[88%] rounded-card px-4 py-3 text-left shadow-sm transition-colors duration-150 active:scale-[0.98]',
                    mine ? 'rounded-tr-sm bg-primary-soft' : cn('rounded-tl-sm border bg-surface', lv.line),
                    isCurrent && mine && 'ring-2 ring-primary',
                  )}
                >
                  <Hr as="p" className="text-body-lg font-semibold break-words">
                    {line.hr_text}
                  </Hr>
                  <p className="mt-0.5 text-label font-normal text-ink-muted">{line.ua_translation}</p>
                </button>
              </li>
            );
          })}
        </ol>

        {finished && (
          <Card hero role="status" className="mt-2 flex flex-col items-center gap-3 text-center animate-fade-in-up">
            <span className="text-5xl leading-none animate-pop" aria-hidden="true">
              🎉
            </span>
            <h2 className="font-heading text-h2">Діалог відіграно!</h2>
            {micSupported && myLines > 0 && (
              <ul className="grid w-full grid-cols-1 gap-2">
                <StatTile
                  emoji="🎙️"
                  value={`${said} з ${myLines}`}
                  label={pluralUk(myLines, ['репліку сказали вголос', 'репліки сказали вголос', 'реплік сказали вголос'])}
                  tone="success"
                />
              </ul>
            )}
            <p className="text-body text-ink-muted">Спробуйте ще раз за іншого персонажа — так запам’ятаєте обидві сторони розмови.</p>
          </Card>
        )}

        {error && (
          <p role="alert" className="rounded-card border border-warning-line bg-warning-soft p-4 text-body text-warning-ink">
            {error}
          </p>
        )}
        <div ref={endRef} />
      </main>

      <footer className="sticky bottom-0 border-t border-line bg-canvas/95 pb-[calc(0.75rem+env(safe-area-inset-bottom))] pt-3">
        <div className="mx-auto flex max-w-md flex-col gap-2 px-4">
          {finished ? (
            <>
              <Button block onClick={onExit}>
                Повернутися до уроку
                <ArrowRight className="size-5" aria-hidden="true" />
              </Button>
              <Button block variant="secondary" onClick={() => setRole(null)}>
                <RotateCcw className="size-4" aria-hidden="true" />
                Зіграти іншу роль
              </Button>
            </>
          ) : myTurn ? (
            <>
              <div className="flex flex-col items-center gap-2 text-center">
                <p className="text-caption text-ink-subtle">Ваша репліка — скажіть уголос:</p>
                {(listening || heard) && (
                  <p
                    className={cn(
                      'flex items-center gap-1.5 text-label font-normal',
                      heard ? (heard.ok ? 'text-success-ink' : 'text-warning-ink') : 'text-ink-muted',
                    )}
                  >
                    {heard?.ok && <CircleCheck className="size-4 shrink-0" aria-hidden="true" />}
                    {heard && !heard.ok && <CircleAlert className="size-4 shrink-0" aria-hidden="true" />}
                    {listening ? (
                      interim ? <Hr>{interim}</Hr> : 'Слухаю… говоріть'
                    ) : heard?.ok ? (
                      'Odlično! Вас зрозуміли.'
                    ) : (
                      <span>
                        Почули: «<Hr>{heard?.text}</Hr>» — спробуйте ще раз
                      </span>
                    )}
                  </p>
                )}
              </div>
              {micSupported ? (
                <div className="flex gap-2">
                  <Button
                    variant={listening ? 'danger' : 'primary'}
                    className={cn('flex-[3]', listening && 'animate-pulse')}
                    onClick={() => void listen(current.hr_text)}
                    disabled={heard?.ok}
                    aria-pressed={listening}
                  >
                    {listening ? <Square className="size-5" aria-hidden="true" /> : <Mic className="size-5" aria-hidden="true" />}
                    {listening ? 'Зупинити' : heard ? 'Сказати ще раз' : 'Натисніть і говоріть'}
                  </Button>
                  <Button variant="tertiary" className="flex-1" onClick={goNext}>
                    <SkipForward className="size-4" aria-hidden="true" />
                    Далі
                  </Button>
                </div>
              ) : (
                <>
                  <p className="text-center text-caption text-ink-subtle">
                    Цей браузер не розпізнає мовлення — прочитайте репліку вголос і йдіть далі.
                  </p>
                  <Button block onClick={goNext}>
                    Далі
                  </Button>
                </>
              )}
            </>
          ) : (
            <>
              <p className="text-center text-label font-normal text-ink-muted">
                <span aria-hidden="true">🎧</span> Говорить <Hr>{current?.speaker_name}</Hr> — натисніть репліку, щоб послухати ще раз
              </p>
              <Button block variant="secondary" onClick={goNext}>
                Далі
                <ArrowRight className="size-5" aria-hidden="true" />
              </Button>
            </>
          )}
        </div>
      </footer>
    </div>
  );
}
