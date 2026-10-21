'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { CircleAlert, CircleCheck, Lightbulb, Mic, Play, Square } from 'lucide-react';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import FeedbackBanner, { type FeedbackKind } from '@/components/ui/FeedbackBanner';
import { speakCroatian } from '@/utils/speech';
import { browserSpeech, micHelpHere } from '@/utils/speech-recognition';
import { SpeechError, type ListeningSession, type SpeechErrorCode } from '@/lib/speech-provider';
import { evaluateSpeech, type SpeechEvaluation, type SpeechVerdict } from '@/lib/speaking';
import { checkTypedAnswer } from '@/lib/answer';
import { checkSentence } from '@/lib/mistakes';
import { choicesFrom, isUkrainian, tilesFrom, type PracticeOutcome } from '@/lib/lesson-flow';
import { cn } from '@/lib/ui';

export interface LessonExerciseData {
  id: string;
  exercise_type: string;
  question_text: string;
  correct_answer: string;
  options: unknown;
}

interface Result {
  outcome: PracticeOutcome;
  /** Для FeedbackBanner; у «скажіть уголос» — власний відгук */
  kind?: FeedbackKind;
  verdict?: string;
}

const TITLES: Record<string, string> = {
  multiple_choice: 'Оберіть правильний варіант',
  fill_in_the_blank: 'Вставте слово',
  type_answer: 'Напишіть хорватською',
  sentence_builder: 'Складіть речення',
  listening: 'Прослухайте і складіть фразу',
  speaking: 'Скажіть уголос хорватською',
};

const SPEECH_UI: Record<SpeechVerdict, { ok: boolean; title: string; text?: string }> = {
  great: { ok: true, title: 'Чудово! Вас зрозуміють.' },
  understandable: { ok: true, title: 'Зрозуміло.', text: 'Фразу зрозуміють. Можна відшліфувати кілька слів.' },
  almost: { ok: false, title: 'Майже.', text: 'Частину слів не розпізнано — послухайте зразок і спробуйте ще раз.' },
  retry: { ok: false, title: 'Не вдалося розібрати фразу.', text: 'Послухайте зразок і скажіть трохи повільніше.' },
  no_speech: { ok: false, title: 'Нічого не почули.', text: 'Натисніть мікрофон і говоріть ближче до нього.' },
};

const SPEECH_ERROR: Record<SpeechErrorCode, string> = {
  unsupported: 'Цей браузер не розпізнає мовлення. Спробуйте Chrome чи Edge (Android, комп’ютер) або Safari на iPhone. Вправу можна пропустити.',
  'not-allowed': 'Немає доступу до мікрофона. Дозвольте його в налаштуваннях браузера (значок біля адреси сторінки) або пропустіть вправу.',
  'audio-capture': 'Мікрофон не знайдено або він зайнятий іншою програмою.',
  network: 'Розпізнавання мовлення потребує інтернету. Перевірте з’єднання або пропустіть вправу.',
  'no-speech': 'Нічого не почули. Спробуйте ще раз.',
  aborted: 'Розпізнавання зупинено.',
  other: 'Не вдалося розпізнати мовлення. Спробуйте ще раз.',
};

/**
 * Одна вправа уроку. Показує завдання → відповідь → відгук → «Далі».
 * Рахунок і черга — у LessonPlayer (lib/lesson-flow.ts).
 */
export default function LessonExercise({
  exercise,
  retry,
  onNext,
}: {
  exercise: LessonExerciseData;
  /** Повтор після помилки */
  retry: boolean;
  onNext: (outcome: PracticeOutcome, verdict?: string) => void;
}) {
  const [result, setResult] = useState<Result | null>(null);
  const type = exercise.exercise_type;
  const answer = exercise.correct_answer;
  const answerIsHr = !isUkrainian(answer);

  const finish = (r: Result) => {
    setResult(r);
    if (r.outcome === 'correct' && answerIsHr && type !== 'listening' && type !== 'speaking') speakCroatian(answer);
  };

  return (
    <div className="flex flex-col gap-4 animate-fade-in-up">
      <div>
        <p className="text-label text-ink-muted">
          {TITLES[type] ?? 'Вправа'}
          {retry && <span className="ml-2 rounded-full bg-warning-soft px-2 py-0.5 text-caption text-warning-ink">ще раз</span>}
        </p>
        {type !== 'listening' && (
          <h2 className="mt-1 font-heading text-h2 break-words">
            {type === 'speaking' ? exercise.question_text : <QuestionText text={exercise.question_text} />}
          </h2>
        )}
      </div>

      {(type === 'multiple_choice' || type === 'fill_in_the_blank') && (
        <ChoiceExercise exercise={exercise} locked={result !== null} onAnswer={finish} />
      )}
      {type === 'type_answer' && <TypeExercise answer={answer} locked={result !== null} onAnswer={finish} />}
      {(type === 'sentence_builder' || type === 'listening') && (
        <TilesExercise exercise={exercise} listening={type === 'listening'} locked={result !== null} onAnswer={finish} />
      )}
      {type === 'speaking' && <SpeakingExercise answer={answer} onAnswer={finish} />}

      {result && (
        <div className="flex flex-col gap-3">
          {result.kind && (
            <FeedbackBanner kind={result.kind} expected={answer}>
              {answerIsHr && <AudioButton text={answer} />}
            </FeedbackBanner>
          )}
          {result.outcome === 'wrong' && !retry && (
            <p className="text-label font-normal text-ink-muted">Ця вправа повториться наприкінці.</p>
          )}
          <Button block onClick={() => onNext(result.outcome, result.verdict)} autoFocus>
            Далі
          </Button>
        </div>
      )}
    </div>
  );
}

/** Питання може містити хорватське слово в «лапках» — його позначаємо lang="hr". */
function QuestionText({ text }: { text: string }) {
  const parts = text.split(/(«[^»]*»)/);
  return (
    <>
      {parts.map((p, i) =>
        p.startsWith('«') && !isUkrainian(p) ? (
          <Hr key={i}>{p}</Hr>
        ) : (
          <span key={i}>{p}</span>
        ),
      )}
    </>
  );
}

// ---------------------------------------------------------------- вибір
function ChoiceExercise({
  exercise,
  locked,
  onAnswer,
}: {
  exercise: LessonExerciseData;
  locked: boolean;
  onAnswer: (r: Result) => void;
}) {
  const options = useMemo(() => choicesFrom(exercise.options), [exercise.options]);
  const [picked, setPicked] = useState<string | null>(null);

  return (
    <div className="flex flex-col gap-2" role="group" aria-label="Варіанти відповіді">
      {options.map((opt) => {
        const isAnswer = opt === exercise.correct_answer;
        const isPicked = opt === picked;
        const state = !locked ? 'idle' : isAnswer ? 'right' : isPicked ? 'wrong' : 'dim';
        const Text = isUkrainian(opt) ? 'span' : Hr;
        return (
          <button
            key={opt}
            type="button"
            disabled={locked}
            onClick={() => {
              setPicked(opt);
              onAnswer({ outcome: isAnswer ? 'correct' : 'wrong', kind: isAnswer ? 'exact' : 'wrong' });
            }}
            className={cn(
              'flex min-h-14 items-center justify-between gap-3 rounded-control border-2 px-4 py-3 text-left text-body-lg transition-colors duration-150',
              state === 'idle' && 'border-line bg-surface hover:border-primary active:scale-[0.98]',
              state === 'right' && 'border-success-line bg-success-soft text-success-ink',
              state === 'wrong' && 'border-danger-line bg-danger-soft text-danger-ink',
              state === 'dim' && 'border-line bg-surface opacity-60',
            )}
          >
            <Text>{opt}</Text>
            {state === 'right' && <CircleCheck className="size-5 shrink-0" aria-label="Правильна відповідь" />}
            {state === 'wrong' && <CircleAlert className="size-5 shrink-0" aria-label="Ваша відповідь" />}
          </button>
        );
      })}
    </div>
  );
}

// ---------------------------------------------------------------- написати
function TypeExercise({ answer, locked, onAnswer }: { answer: string; locked: boolean; onAnswer: (r: Result) => void }) {
  const [value, setValue] = useState('');
  const check = () => {
    const res = checkTypedAnswer(value, answer);
    if (res.verdict === 'empty') return;
    onAnswer({ outcome: res.correct ? 'correct' : 'wrong', kind: res.verdict, verdict: res.verdict });
  };
  return (
    <form
      className="flex flex-col gap-3"
      onSubmit={(e) => {
        e.preventDefault();
        check();
      }}
    >
      <input
        value={value}
        onChange={(e) => setValue(e.target.value)}
        disabled={locked}
        lang="hr"
        autoCapitalize="none"
        autoCorrect="off"
        autoComplete="off"
        spellCheck={false}
        aria-label="Ваша відповідь хорватською"
        placeholder="Ваша відповідь…"
        className="min-h-12 w-full rounded-control border-2 border-line bg-surface px-4 text-body-lg focus:border-primary focus:outline-none disabled:opacity-70"
      />
      {!locked && (
        <>
          <p className="text-caption text-ink-subtle">Немає хорватських літер на клавіатурі? Можна писати c, s, z, d замість č, ć, š, ž, đ.</p>
          <Button type="submit" block disabled={!value.trim()}>
            Перевірити
          </Button>
          <Button variant="tertiary" block onClick={() => onAnswer({ outcome: 'wrong', kind: 'gave_up', verdict: 'gave_up' })}>
            Не знаю — показати
          </Button>
        </>
      )}
    </form>
  );
}

// ---------------------------------------------------------------- плитки (склади / аудіювання)
function TilesExercise({
  exercise,
  listening,
  locked,
  onAnswer,
}: {
  exercise: LessonExerciseData;
  listening: boolean;
  locked: boolean;
  onAnswer: (r: Result) => void;
}) {
  const tiles = useMemo(() => tilesFrom(exercise.options), [exercise.options]);
  const [picked, setPicked] = useState<typeof tiles>([]);
  const pool = tiles.filter((t) => !picked.some((p) => p.key === t.key));
  const playedRef = useRef(false);

  // Аудіювання: одразу програємо фразу (користувач щойно натиснув «Далі», тож звук дозволено)
  useEffect(() => {
    if (listening && !playedRef.current) {
      playedRef.current = true;
      speakCroatian(exercise.correct_answer);
    }
  }, [listening, exercise.correct_answer]);

  const check = () => {
    const verdict = checkSentence(picked.map((t) => t.text).join(' '), exercise.correct_answer);
    const ok = verdict !== 'wrong';
    onAnswer({ outcome: ok ? 'correct' : 'wrong', kind: ok ? 'exact' : 'wrong' });
  };

  return (
    <div className="flex flex-col gap-4">
      {listening && (
        <div className="flex flex-col items-center gap-2 py-2">
          <button
            type="button"
            onClick={() => speakCroatian(exercise.correct_answer)}
            aria-label="Прослухати фразу"
            className="flex size-20 items-center justify-center rounded-full bg-primary text-white shadow-md transition-colors duration-150 hover:bg-primary-hover active:scale-[0.98]"
          >
            <Play className="size-8 translate-x-0.5" aria-hidden="true" />
          </button>
          <p className="text-label font-normal text-ink-muted">Натисніть, щоб послухати ще раз</p>
        </div>
      )}

      <div
        aria-live="polite"
        className={cn(
          'flex min-h-20 flex-wrap items-center gap-2 rounded-card border-2 bg-surface p-3',
          locked ? 'border-line' : 'border-dashed border-line',
        )}
      >
        {picked.length === 0 && <span className="text-label font-normal text-ink-subtle">Натискайте слова нижче…</span>}
        {picked.map((t) => (
          <button
            key={t.key}
            type="button"
            disabled={locked}
            onClick={() => setPicked((p) => p.filter((x) => x.key !== t.key))}
            className="min-h-11 rounded-control bg-primary-soft px-3 text-body text-primary-ink"
            lang="hr"
          >
            {t.text}
          </button>
        ))}
      </div>

      {!locked && (
        <>
          <div className="flex flex-wrap justify-center gap-2">
            {pool.map((t) => (
              <button
                key={t.key}
                type="button"
                onClick={() => setPicked((p) => [...p, t])}
                className="min-h-11 rounded-control border border-line bg-surface px-3 text-body shadow-sm active:scale-[0.98]"
                lang="hr"
              >
                {t.text}
              </button>
            ))}
          </div>
          <Button block disabled={picked.length === 0} onClick={check}>
            Перевірити
          </Button>
          <Button variant="tertiary" block onClick={() => onAnswer({ outcome: 'wrong', kind: 'gave_up' })}>
            Не знаю — показати
          </Button>
        </>
      )}
    </div>
  );
}

// ---------------------------------------------------------------- скажіть уголос
function SpeakingExercise({ answer, onAnswer }: { answer: string; onAnswer: (r: Result) => void }) {
  const supported = useMemo(() => browserSpeech.isSupported(), []);
  const [hint, setHint] = useState(false);
  const [listening, setListening] = useState(false);
  const [interim, setInterim] = useState('');
  const [evaluation, setEvaluation] = useState<SpeechEvaluation | null>(null);
  const [error, setError] = useState<SpeechErrorCode | null>(supported ? null : 'unsupported');
  const [done, setDone] = useState(false);
  const sessionRef = useRef<ListeningSession | null>(null);

  useEffect(() => () => sessionRef.current?.abort(), []);

  const listen = async () => {
    if (typeof navigator !== 'undefined' && navigator.onLine === false) {
      setError('network');
      return;
    }
    setError(null);
    setEvaluation(null);
    setInterim('');
    setListening(true);
    const session = browserSpeech.transcribe({ lang: 'hr-HR', maxAlternatives: 3, onInterim: setInterim });
    sessionRef.current = session;
    try {
      const { transcripts } = await session.result;
      const ev = evaluateSpeech(answer, transcripts);
      setEvaluation(ev);
      if (SPEECH_UI[ev.verdict].ok) {
        setDone(true);
        onAnswer({ outcome: 'correct', verdict: ev.verdict });
      }
    } catch (err) {
      const code = err instanceof SpeechError ? err.code : 'other';
      if (code !== 'aborted') setError(code);
    } finally {
      setListening(false);
      sessionRef.current = null;
    }
  };

  const skip = (verdict: string) => {
    sessionRef.current?.abort();
    setDone(true);
    onAnswer({ outcome: 'skipped', verdict });
  };

  const ui = evaluation ? SPEECH_UI[evaluation.verdict] : null;
  const showPhrase = hint || evaluation !== null || error === 'unsupported';

  return (
    <Card className="flex flex-col gap-4">
      {showPhrase ? (
        <div className="flex items-start gap-2">
          <Hr as="p" className="min-w-0 flex-1 font-heading text-h3 break-words">
            {answer}
          </Hr>
          <AudioButton text={answer} />
        </div>
      ) : (
        <button
          type="button"
          onClick={() => setHint(true)}
          className="flex min-h-11 items-center gap-2 self-start rounded-control px-2 text-label text-ink-muted hover:bg-surface-muted"
        >
          <Lightbulb className="size-4" aria-hidden="true" />
          Підказка
        </button>
      )}

      {!done && error !== 'unsupported' && (
        <div className="flex flex-col items-center gap-3 py-1">
          <button
            type="button"
            onClick={() => (listening ? sessionRef.current?.stop() : void listen())}
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
            {listening ? (interim ? <Hr>{interim}</Hr> : 'Слухаю… говоріть') : evaluation ? 'Натисніть і спробуйте ще раз' : 'Натисніть і скажіть фразу'}
          </p>
        </div>
      )}

      {error && (
        <p role="alert" className="rounded-card border border-warning-line bg-warning-soft p-4 text-body text-warning-ink">
          {error === 'not-allowed' ? micHelpHere('Або пропустіть вправу.') : SPEECH_ERROR[error]}
        </p>
      )}

      {evaluation && ui && (
        <div
          role="status"
          className={cn(
            'flex flex-col gap-2 rounded-card border p-4',
            ui.ok ? 'border-success-line bg-success-soft text-success-ink' : 'border-warning-line bg-warning-soft text-warning-ink',
          )}
        >
          <p className="flex items-center gap-2 text-label">
            {ui.ok ? <CircleCheck className="size-5" aria-hidden="true" /> : <CircleAlert className="size-5" aria-hidden="true" />}
            {ui.title}
          </p>
          {ui.text && <p className="text-body">{ui.text}</p>}
          {evaluation.transcript && (
            <p className="text-body text-ink">
              Ви сказали: «<Hr>{evaluation.transcript}</Hr>»
            </p>
          )}
        </div>
      )}

      {!done && (
        <Button
          variant="tertiary"
          block
          onClick={() => skip(error ?? (evaluation ? evaluation.verdict : 'skipped'))}
        >
          {evaluation || error ? 'Пропустити й іти далі' : 'Не можу говорити зараз'}
        </Button>
      )}
      <p className="text-caption text-ink-subtle">Аудіо не записуємо: розпізнає браузер, ми бачимо лише текст.</p>
    </Card>
  );
}
