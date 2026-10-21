'use client';

import { useEffect, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { CircleCheck, CircleAlert, Languages, Lightbulb, Mic, RotateCcw, Send, Sparkles, Square, Volume2, VolumeX } from 'lucide-react';
import PageHeader from '@/components/ui/PageHeader';
import Card from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import IconButton from '@/components/ui/IconButton';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import LevelBadge from '@/components/ui/LevelBadge';
import AiPanel from '@/components/ui/AiPanel';
import { browserSpeech, micHelpHere } from '@/utils/speech-recognition';
import { speakCroatian } from '@/utils/speech';
import { SpeechError, type ListeningSession } from '@/lib/speech-provider';
import { MAX_USER_TURNS, MAX_MESSAGE_CHARS, type Correction, type RoleplayAssessment, type RoleplayScenario } from '@/lib/roleplay';
import type { SituationInfo } from '@/lib/situations';
import { finishRoleplay, sendRoleplayMessage, startRoleplay } from '@/app/actions/roleplay';
import { cn } from '@/lib/ui';

interface ChatMessage {
  id: string;
  role: 'assistant' | 'user';
  text: string;
  translation?: string;
  correction?: Correction | null;
}

type Stage = 'intro' | 'chat' | 'summary';

/**
 * Рольова гра з AI (VS-004, §52, §87): сценарій → AI починає → відповідь текстом або голосом →
 * AI відповідає й виправляє важливе → підсумок → помилки зберігаються для повторення.
 */
export default function RoleplayChat({
  situation,
  scenario,
  level,
  phrases,
}: {
  situation: SituationInfo;
  scenario: RoleplayScenario;
  level: string;
  phrases: Array<{ id: string; text_hr: string; ukrainian_translation: string }>;
}) {
  const router = useRouter();
  const [stage, setStage] = useState<Stage>('intro');
  const [conversationId, setConversationId] = useState<string | null>(null);
  const [messages, setMessages] = useState<ChatMessage[]>([]);
  const [input, setInput] = useState('');
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState<string | null>(null);
  // Що повторити кнопкою «Спробувати ще раз» (лише для дій з AI)
  const [retryAction, setRetryAction] = useState<'start' | 'send' | 'finish' | null>(null);
  const [userTurns, setUserTurns] = useState(0);
  const [finished, setFinished] = useState(false);
  const [autoSpeak, setAutoSpeak] = useState(true);
  const [showTranslations, setShowTranslations] = useState(level === 'A0' || level === 'A1');
  const [showPhrases, setShowPhrases] = useState(false);
  const [confirmExit, setConfirmExit] = useState(false);
  const [result, setResult] = useState<{ assessment: RoleplayAssessment | null; goalReached: boolean; errorsSaved: number } | null>(null);

  const [listening, setListening] = useState(false);
  const listeningRef = useRef<ListeningSession | null>(null);
  const endRef = useRef<HTMLDivElement>(null);
  // Підтримку мікрофона перевіряємо лише в браузері (інакше сервер і клієнт намалюють різне)
  const [micSupported, setMicSupported] = useState(false);
  useEffect(() => setMicSupported(browserSpeech.isSupported()), []);

  useEffect(() => {
    endRef.current?.scrollIntoView({ behavior: 'smooth', block: 'end' });
  }, [messages, busy]);
  useEffect(() => () => listeningRef.current?.abort(), []);

  const addAssistant = (text: string, translation: string) => {
    setMessages((m) => [...m, { id: `a${Date.now()}`, role: 'assistant', text, translation }]);
    if (autoSpeak) speakCroatian(text);
  };

  const start = async () => {
    setBusy(true);
    setError(null);
    setRetryAction(null);
    const res = await startRoleplay(situation.code);
    setBusy(false);
    if (!res.ok) {
      setError(res.error);
      setRetryAction('start');
      return;
    }
    setConversationId(res.conversationId);
    setMessages([]);
    setUserTurns(0);
    setFinished(false);
    setResult(null);
    setStage('chat');
    addAssistant(res.turn.reply_hr, res.turn.reply_ua);
  };

  const send = async () => {
    const text = input.trim();
    if (!text || !conversationId || busy || finished) return;
    setBusy(true);
    setError(null);
    setRetryAction(null);
    const userId = `u${Date.now()}`;
    setMessages((m) => [...m, { id: userId, role: 'user', text }]);
    setInput('');
    const res = await sendRoleplayMessage(conversationId, text);
    setBusy(false);
    if (!res.ok) {
      // Репліку не збережено — повертаємо текст у поле, щоб можна було надіслати ще раз
      setMessages((m) => m.filter((x) => x.id !== userId));
      setInput(text);
      setError(res.error);
      setRetryAction('send');
      return;
    }
    setMessages((m) => m.map((x) => (x.id === userId ? { ...x, correction: res.turn.correction } : x)));
    addAssistant(res.turn.reply_hr, res.turn.reply_ua);
    setUserTurns(res.userTurns);
    if (res.finished) setFinished(true);
  };

  const finish = async () => {
    if (!conversationId) return;
    setConfirmExit(false);
    setBusy(true);
    setError(null);
    setRetryAction(null);
    const res = await finishRoleplay(conversationId);
    setBusy(false);
    if (!res.ok) {
      setError(res.error);
      setRetryAction('finish');
      return;
    }
    setResult(res);
    setStage('summary');
  };

  const listen = async () => {
    if (listening) {
      listeningRef.current?.stop();
      return;
    }
    setError(null);
    setRetryAction(null);
    setListening(true);
    const session = browserSpeech.transcribe({ lang: 'hr-HR', maxAlternatives: 1, onInterim: (t) => setInput(t) });
    listeningRef.current = session;
    try {
      const { transcripts } = await session.result;
      if (transcripts[0]) setInput(transcripts[0].slice(0, MAX_MESSAGE_CHARS));
    } catch (err) {
      const code = err instanceof SpeechError ? err.code : 'other';
      if (code === 'not-allowed') setError(micHelpHere('Або напишіть текстом.'));
      else if (code !== 'aborted') setError('Не вдалося розпізнати мовлення. Спробуйте ще раз або напишіть текстом.');
    } finally {
      setListening(false);
      listeningRef.current = null;
    }
  };

  const onBack = () => {
    if (stage === 'chat' && userTurns > 0 && !finished) setConfirmExit(true);
    else if (stage === 'chat' && userTurns > 0 && finished) void finish();
    else router.push(`/situations/${situation.code}`);
  };

  // ---------------------------------------------------------------- шапка
  const header = (
    <PageHeader
      title={`Рольова гра · ${situation.label}`}
      closeMode
      onBack={onBack}
      action={
        stage === 'chat' ? (
          <IconButton label={autoSpeak ? 'Вимкнути озвучення' : 'Увімкнути озвучення'} aria-pressed={autoSpeak} onClick={() => setAutoSpeak((v) => !v)}>
            {autoSpeak ? <Volume2 className="size-5" aria-hidden="true" /> : <VolumeX className="size-5" aria-hidden="true" />}
          </IconButton>
        ) : undefined
      }
    />
  );

  // ---------------------------------------------------------------- вступ
  if (stage === 'intro') {
    return (
      <div className="min-h-screen pb-10">
        {header}
        <main className="mx-auto flex max-w-2xl flex-col gap-4 px-5 pt-6">
          <Card hero className="flex flex-col gap-3 animate-fade-in-up">
            <div className="flex items-center justify-between gap-3">
              <p className="text-label text-ink-muted">{situation.emoji} Ваш співрозмовник</p>
              <LevelBadge level={level} />
            </div>
            <p className="font-heading text-h2">
              <Hr className="capitalize">{scenario.aiRoleHr}</Hr> <span className="text-ink-muted">· {scenario.aiRoleUa}</span>
            </p>
            <p className="text-body text-ink-muted">{scenario.settingUa}</p>
            <div className="rounded-card bg-primary-soft p-4">
              <p className="text-label text-primary-ink">Ваше завдання</p>
              <p className="mt-1 text-body-lg">{scenario.goalUa}</p>
            </div>
            <ul className="flex flex-col gap-1 text-label font-normal text-ink-muted">
              <li>• Відповідайте хорватською — текстом або голосом 🎙.</li>
              <li>• AI виправлятиме лише важливе: зміст, зрозумілість, граматику.</li>
              <li>• До {MAX_USER_TURNS} ваших реплік, потім — підсумок і помилки для повторення.</li>
            </ul>
          </Card>
          {error && <ErrorBox text={error} />}
          <Button block onClick={() => void start()} loading={busy}>
            <Sparkles className="size-5" aria-hidden="true" />
            Почати розмову
          </Button>
          <p className="text-center text-caption text-ink-subtle">Співрозмовника грає AI: його репліки можуть містити неточності.</p>
        </main>
      </div>
    );
  }

  // ---------------------------------------------------------------- підсумок
  if (stage === 'summary' && result) {
    const a = result.assessment;
    const done = result.goalReached;
    return (
      <div className="min-h-screen pb-10">
        {header}
        <main className="mx-auto flex max-w-2xl flex-col gap-4 px-5 pt-6 animate-fade-in-up">
          <Card hero className={cn('flex flex-col gap-2 border', done ? 'border-success-line bg-success-soft' : 'border-warning-line bg-warning-soft')}>
            <p className={cn('flex items-center gap-2 font-heading text-h2', done ? 'text-success-ink' : 'text-warning-ink')}>
              {done ? <CircleCheck className="size-6" aria-hidden="true" /> : <CircleAlert className="size-6" aria-hidden="true" />}
              {done ? 'Завдання виконано' : 'Завдання ще не виконано'}
            </p>
            <p className="text-body text-ink">{a?.summary_ua ?? (userTurns === 0 ? 'Ви ще нічого не сказали — спробуйте ще раз.' : 'Розмову збережено.')}</p>
          </Card>

          {a && a.strengths_ua.length > 0 && (
            <Card>
              <h2 className="font-heading text-h3">Що вийшло добре</h2>
              <ul className="mt-2 flex flex-col gap-1 text-body">
                {a.strengths_ua.map((s, i) => (
                  <li key={i}>✓ {s}</li>
                ))}
              </ul>
            </Card>
          )}

          {a && a.errors.length > 0 && (
            <AiPanel title="AI · над чим попрацювати">
              <ul className="flex flex-col gap-3">
                {a.errors.map((e, i) => (
                  <li key={i} className="border-t border-ai-line pt-3 first:border-0 first:pt-0">
                    <p className="text-label font-normal text-ink-muted line-through decoration-danger/60">
                      <Hr>{e.original}</Hr>
                    </p>
                    <div className="flex items-start gap-2">
                      <Hr as="p" className="flex-1 text-body-lg font-semibold">
                        {e.corrected_hr}
                      </Hr>
                      <AudioButton text={e.corrected_hr} className="-mt-2" />
                    </div>
                    <p className="text-label font-normal text-ink-muted">{e.explanation_ua}</p>
                  </li>
                ))}
              </ul>
            </AiPanel>
          )}
          {result.errorsSaved > 0 && (
            <div className="flex flex-col items-center gap-2 text-center">
              <p className="text-label font-normal text-ink-muted">Збережено для повторення: {result.errorsSaved}</p>
              <Button variant="secondary" href="/mistakes">Виправити помилки зараз</Button>
            </div>
          )}

          <div className="flex flex-col gap-2 sm:flex-row">
            <Button block onClick={() => setStage('intro')}>
              <RotateCcw className="size-5" aria-hidden="true" />
              Ще раз
            </Button>
            <Button block variant="secondary" href={`/situations/${situation.code}`}>
              До ситуації
            </Button>
          </div>
        </main>
      </div>
    );
  }

  // ---------------------------------------------------------------- розмова
  return (
    <div className="flex min-h-screen flex-col">
      {header}

      <div className="mx-auto w-full max-w-2xl px-5 pt-3">
        <div className="flex items-center justify-between gap-2 text-label font-normal text-ink-muted">
          <span>
            Репліка {Math.min(userTurns + 1, MAX_USER_TURNS)} з {MAX_USER_TURNS}
          </span>
          <button
            type="button"
            onClick={() => setShowTranslations((v) => !v)}
            aria-pressed={showTranslations}
            className="flex min-h-11 items-center gap-1 rounded-control px-2 hover:bg-surface-muted"
          >
            <Languages className="size-4" aria-hidden="true" />
            {showTranslations ? 'Сховати переклад' : 'Показати переклад'}
          </button>
        </div>
        <p className="text-caption text-ink-subtle">Завдання: {scenario.goalUa}</p>
      </div>

      <main className="mx-auto flex w-full max-w-2xl flex-1 flex-col gap-3 px-5 py-4" aria-live="polite">
        {messages.map((m) =>
          m.role === 'assistant' ? (
            <div key={m.id} className="flex flex-col items-start animate-fade-in-up">
              <span className="mb-1 px-1 text-caption text-ink-subtle">
                <Hr className="capitalize">{scenario.aiRoleHr}</Hr> · AI
              </span>
              <div className="flex max-w-[90%] items-start gap-2 rounded-card bg-surface-muted px-4 py-3">
                <div className="min-w-0">
                  <Hr as="p" className="text-body-lg break-words">
                    {m.text}
                  </Hr>
                  {showTranslations && m.translation && <p className="mt-0.5 text-label font-normal text-ink-muted">{m.translation}</p>}
                </div>
                <AudioButton text={m.text} className="-mr-2 -mt-1" />
              </div>
            </div>
          ) : (
            <div key={m.id} className="flex flex-col items-end">
              <span className="mb-1 px-1 text-caption text-ink-subtle">Ви</span>
              <div className="max-w-[90%] rounded-card bg-primary-soft px-4 py-3">
                <Hr as="p" className="text-body-lg break-words">
                  {m.text}
                </Hr>
              </div>
              {m.correction && (
                <div className="mt-2 max-w-[90%] rounded-card border border-ai-line bg-ai-soft px-4 py-3 animate-fade-in-up">
                  <p className="flex items-center gap-1 text-caption font-semibold text-ai-ink">
                    <Sparkles className="size-3.5" aria-hidden="true" />
                    Краще сказати
                  </p>
                  <div className="flex items-start gap-1">
                    <Hr as="p" className="flex-1 text-body font-semibold">
                      {m.correction.corrected_hr}
                    </Hr>
                    <AudioButton text={m.correction.corrected_hr} className="-mr-2 -mt-2 size-9" />
                  </div>
                  <p className="text-label font-normal text-ink-muted">{m.correction.explanation_ua}</p>
                </div>
              )}
            </div>
          ),
        )}
        {busy && (
          <div className="flex items-center gap-1 self-start rounded-card bg-surface-muted px-4 py-3" role="status" aria-label="AI відповідає">
            <span className="size-2 animate-pulse rounded-full bg-ink-subtle" />
            <span className="size-2 animate-pulse rounded-full bg-ink-subtle [animation-delay:150ms]" />
            <span className="size-2 animate-pulse rounded-full bg-ink-subtle [animation-delay:300ms]" />
          </div>
        )}
        {finished && !busy && (
          <Card className="flex flex-col gap-3 border-success-line bg-success-soft text-center">
            <p className="font-heading text-h3 text-success-ink">
              {userTurns >= MAX_USER_TURNS ? 'Розмову завершено' : 'Схоже, завдання виконано!'}
            </p>
            <Button onClick={() => void finish()}>Подивитися підсумок</Button>
          </Card>
        )}
        {error && (
          <ErrorBox
            text={error}
            onRetry={
              busy ? undefined
                : retryAction === 'send' ? () => void send()
                : retryAction === 'finish' ? () => void finish()
                : undefined
            }
          />
        )}
        <div ref={endRef} />
      </main>

      {/* Поле відповіді */}
      {!finished && (
        <div className="sticky bottom-0 border-t border-line bg-surface/95 pb-[calc(0.75rem+env(safe-area-inset-bottom))] pt-3">
          <div className="mx-auto flex max-w-2xl flex-col gap-2 px-5">
            {showPhrases && phrases.length > 0 && (
              <ul className="flex max-h-32 flex-wrap gap-2 overflow-y-auto" aria-label="Корисні фрази">
                {phrases.map((p) => (
                  <li key={p.id}>
                    <button
                      type="button"
                      onClick={() => setInput((v) => (v ? `${v} ${p.text_hr}` : p.text_hr).slice(0, MAX_MESSAGE_CHARS))}
                      title={p.ukrainian_translation}
                      className="min-h-9 rounded-full border border-line bg-surface px-3 text-label font-normal hover:border-primary/40"
                    >
                      <Hr>{p.text_hr}</Hr>
                    </button>
                  </li>
                ))}
              </ul>
            )}
            <form
              className="flex items-end gap-2"
              onSubmit={(e) => {
                e.preventDefault();
                void send();
              }}
            >
              {phrases.length > 0 && (
                <IconButton label={showPhrases ? 'Сховати корисні фрази' : 'Корисні фрази'} aria-pressed={showPhrases} onClick={() => setShowPhrases((v) => !v)}>
                  <Lightbulb className="size-5" aria-hidden="true" />
                </IconButton>
              )}
              <label className="sr-only" htmlFor="roleplay-input">
                Ваша репліка хорватською
              </label>
              <input
                id="roleplay-input"
                lang="hr"
                value={input}
                onChange={(e) => setInput(e.target.value.slice(0, MAX_MESSAGE_CHARS))}
                placeholder={listening ? 'Слухаю…' : 'Ваша відповідь хорватською'}
                autoComplete="off"
                disabled={busy}
                className="min-h-11 min-w-0 flex-1 rounded-control border border-line bg-surface px-4 text-body outline-none focus:border-primary"
              />
              {micSupported && (
                <IconButton
                  label={listening ? 'Зупинити' : 'Сказати голосом'}
                  aria-pressed={listening}
                  onClick={() => void listen()}
                  disabled={busy}
                  className={cn(listening && 'bg-danger text-white hover:bg-danger hover:text-white animate-pulse')}
                >
                  {listening ? <Square className="size-5" aria-hidden="true" /> : <Mic className="size-5" aria-hidden="true" />}
                </IconButton>
              )}
              <IconButton
                label="Надіслати"
                type="submit"
                disabled={busy || !input.trim()}
                className="bg-primary text-white hover:bg-primary-hover hover:text-white"
              >
                <Send className="size-5" aria-hidden="true" />
              </IconButton>
            </form>
          </div>
        </div>
      )}

      {/* Підтвердження виходу */}
      {confirmExit && (
        <div className="fixed inset-0 z-50 flex items-end justify-center bg-ink/40 p-4 sm:items-center" role="dialog" aria-modal="true" aria-labelledby="exit-title">
          <Card hero className="w-full max-w-md shadow-md">
            <h2 id="exit-title" className="font-heading text-h3">
              Завершити розмову?
            </h2>
            <p className="mt-1 text-body text-ink-muted">Отримаєте підсумок, а помилки збережемо для повторення.</p>
            <div className="mt-4 flex flex-col gap-2">
              <Button block onClick={() => void finish()} loading={busy}>
                Завершити й побачити підсумок
              </Button>
              <Button block variant="secondary" onClick={() => setConfirmExit(false)}>
                Продовжити розмову
              </Button>
              <Button block variant="tertiary" onClick={() => router.push(`/situations/${situation.code}`)}>
                Вийти без підсумку
              </Button>
            </div>
          </Card>
        </div>
      )}
    </div>
  );
}

function ErrorBox({ text, onRetry }: { text: string; onRetry?: () => void }) {
  return (
    <div role="alert" className="rounded-card border border-danger-line bg-danger-soft p-4 text-body text-danger-ink">
      <p>{text}</p>
      {onRetry && (
        <button
          type="button"
          onClick={onRetry}
          className="mt-3 min-h-11 rounded-control border border-danger-line bg-surface px-4 font-semibold"
        >
          Спробувати ще раз
        </button>
      )}
    </div>
  );
}
