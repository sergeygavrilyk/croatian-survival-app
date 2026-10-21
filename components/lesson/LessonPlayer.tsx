'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { BookOpen, CircleCheck, Clock, Dumbbell, Languages, MessagesSquare, Sparkles, Target, X } from 'lucide-react';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import SessionDone from '@/components/ui/SessionDone';
import Mascot, { useStoredMascot } from '@/components/ui/Mascot';
import StatTile from '@/components/ui/StatTile';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import IconButton from '@/components/ui/IconButton';
import ProgressBar from '@/components/ui/ProgressBar';
import RoleplaySimulator from '@/components/features/RoleplaySimulator';
import LessonExercise, { type LessonExerciseData, type LessonSpeechAttempt } from './LessonExercise';
import TypicalErrorCard from '@/components/TypicalErrorCard';
import type { TypicalError } from '@/lib/interference';
import { speakCroatian } from '@/utils/speech';
import { track } from '@/lib/analytics-client';
import { finishSpeakingSession, recordSpeakingAttempt, startSpeakingSession } from '@/app/actions/speaking';
import { evaluateSpeech, isUnderstood } from '@/lib/speaking';
import { situationInfo } from '@/lib/situations';
import {
  answerCurrent, estimateMinutes, isRetry, lessonStages, orderExercises, practiceDone, startPractice,
  type LessonStage, type PracticeOutcome,
} from '@/lib/lesson-flow';
import { countUk, pluralUk } from '@/lib/format';
import { lessonCelebration } from '@/lib/celebration';
import type { CompleteLessonResult } from '@/lib/learning';
import { cn } from '@/lib/ui';

export interface LessonWord {
  id: string;
  hr_text: string;
  ua_translation: string;
}

export interface DialogueLine {
  id: string;
  speaker_name: string;
  hr_text: string;
  ua_translation: string;
}

export interface LessonDialogue {
  id: string;
  title_ua: string | null;
  title_hr: string | null;
  situation: string | null;
  lines: DialogueLine[];
}

export interface GrammarRule {
  id: string;
  title_ua: string;
  explanation_ua: string;
  pattern_hr?: string | null;
  examples: Array<{ hr: string; ua: string }>;
}

export interface GrammarTopic {
  id: string;
  title_ua: string;
  title_hr?: string | null;
  description?: string | null;
  rules: GrammarRule[];
}

export interface LessonInfo {
  id: string;
  title_ua: string;
  title_hr: string | null;
  level_code: string | null;
  objectives: string[] | null;
  estimated_minutes: number | null;
}

export interface LessonContent {
  lesson: LessonInfo;
  words: LessonWord[];
  dialogues: LessonDialogue[];
  grammar: GrammarTopic[];
  exercises: LessonExerciseData[];
  /** Типові помилки українців для теми граматики й слів уроку (§19); показуємо на етапі «Граматика» */
  pitfalls?: TypicalError[];
}

type Shell = (children: React.ReactNode, footer?: React.ReactNode) => React.ReactNode;

const STAGE_LABEL: Record<LessonStage, string> = {
  intro: 'Вступ',
  words: 'Слова',
  dialogue: 'Діалоги',
  grammar: 'Граматика',
  practice: 'Вправи',
  summary: 'Підсумок',
};

/** Що повертає збереження уроку: нові слова й серія для святкового екрана (або нічого — тоді без плиток). */
type CompleteResult = Pick<CompleteLessonResult, 'addedToReview' | 'lessonWords' | 'streak'> | void;

/**
 * Урок повністю: вступ → слова → діалоги → граматика → вправи → святковий підсумок (~10–15 хв).
 * Порядок і черга вправ — lib/lesson-flow.ts. Збереження прогресу — onComplete (сторінка).
 */
export default function LessonPlayer({
  content,
  onComplete,
}: {
  content: LessonContent;
  /** Зберегти прогрес уроку; кидає помилку, якщо не вдалося. Повертає нові слова й серію днів 🔥 */
  onComplete: () => Promise<CompleteResult>;
}) {
  const router = useRouter();
  const { lesson, words, dialogues, grammar } = content;
  const exercises = useMemo(() => orderExercises(content.exercises), [content.exercises]);
  const byId = useMemo(() => new Map(exercises.map((e) => [e.id, e])), [exercises]);
  const stages = useMemo(
    () => lessonStages({ words: words.length, dialogues: dialogues.length, grammar: grammar.length, exercises: exercises.length }),
    [words.length, dialogues.length, grammar.length, exercises.length],
  );

  const [stage, setStage] = useState<LessonStage>('intro');
  const [scene, setScene] = useState(0);
  const [practice, setPractice] = useState(() => startPractice(exercises.map((e) => e.id)));
  const [round, setRound] = useState(0); // щоб скинути стан вправи, коли та сама повертається
  const exerciseStartRef = useRef(Date.now());
  // «Скажіть уголос» → speaking_sessions (source = 'lesson') / speaking_attempts. Заняття створюємо
  // при першій спробі, закриваємо на підсумку. Збій збереження не заважає уроку.
  const speechRef = useRef({
    session: null as Promise<string | null> | null,
    startedAt: 0,
    attempts: 0,
    phrases: new Set<string>(),
    understood: new Set<string>(),
    finished: false,
  });
  const recordSpeech = (exerciseId: string) => (attempt: LessonSpeechAttempt) => {
    const s = speechRef.current;
    if (!s.session) {
      s.startedAt = Date.now();
      s.session = startSpeakingSession({ lessonId: lesson.id, mode: 'produce' }).catch(() => null);
    }
    s.attempts += 1;
    s.phrases.add(exerciseId);
    if (isUnderstood(evaluateSpeech(attempt.targetText, attempt.transcripts).verdict)) s.understood.add(exerciseId);
    void s.session
      .then((sessionId) => recordSpeakingAttempt({ sessionId, phraseId: null, ...attempt }))
      .catch(() => {});
  };
  const finishSpeech = () => {
    const s = speechRef.current;
    if (!s.session || s.finished) return;
    s.finished = true;
    void s.session
      .then((sessionId) =>
        finishSpeakingSession({
          sessionId,
          lessonId: lesson.id,
          mode: 'produce',
          phrases: s.phrases.size,
          understood: s.understood.size,
          attempts: s.attempts,
          durationMs: Date.now() - s.startedAt,
        }),
      )
      .catch(() => {});
  };

  const stageIndex = stages.indexOf(stage);
  const goTo = (s: LessonStage) => {
    setStage(s);
    if (typeof window !== 'undefined') window.scrollTo({ top: 0 });
  };
  const next = () => goTo(stages[Math.min(stageIndex + 1, stages.length - 1)]);
  const back = () => goTo(stages[Math.max(stageIndex - 1, 0)]);

  const situation = dialogues.find((d) => d.situation)?.situation ?? null;
  const minutes =
    lesson.estimated_minutes ??
    estimateMinutes({ words: words.length, turns: dialogues.reduce((n, d) => n + d.lines.length, 0), exercises: exercises.length });

  const restart = () => {
    setPractice(startPractice(exercises.map((e) => e.id)));
    setScene(0);
    setRound((r) => r + 1);
    goTo('intro');
  };

  // ---------------------------------------------------------------- шапка
  const progressValue =
    stage === 'practice'
      ? stageIndex + practiceDone(practice) / Math.max(practice.total, 1)
      : stage === 'dialogue'
        ? stageIndex + scene / Math.max(dialogues.length, 1)
        : stageIndex;

  const header = (
    <header className="sticky top-0 z-10 border-b border-line bg-canvas/95 pt-[env(safe-area-inset-top)]">
      <div className="mx-auto flex max-w-md items-center gap-2 px-2 py-2">
        <IconButton label="Закрити урок" onClick={() => router.push('/lessons')}>
          <X className="size-5" aria-hidden="true" />
        </IconButton>
        <ProgressBar value={progressValue} max={stages.length - 1} label="Прогрес уроку" className="flex-1" />
        <span className="w-20 shrink-0 text-right text-caption text-ink-muted">{STAGE_LABEL[stage]}</span>
      </div>
    </header>
  );

  const shell: Shell = (children, footer) => (
    <div className="flex min-h-screen flex-col">
      {header}
      <main className="mx-auto flex w-full max-w-md flex-1 flex-col gap-4 px-4 py-5">{children}</main>
      {footer && (
        <footer className="sticky bottom-0 border-t border-line bg-canvas/95 pb-[calc(0.75rem+env(safe-area-inset-bottom))] pt-3">
          <div className="mx-auto flex max-w-md flex-col gap-2 px-4">{footer}</div>
        </footer>
      )}
    </div>
  );

  // ---------------------------------------------------------------- вступ
  if (stage === 'intro') {
    const turns = dialogues.reduce((n, d) => n + d.lines.length, 0);
    return shell(
      <Card hero className="flex flex-col gap-4 animate-fade-in-up">
        <p className="flex items-center gap-2 text-label text-ink-muted">
          {lesson.level_code && <span className="rounded-full bg-primary-soft px-2 py-0.5 text-primary-ink">{lesson.level_code}</span>}
          <Clock className="size-4" aria-hidden="true" />~{minutes} хв
        </p>
        <div>
          <h1 className="font-heading text-h1">{lesson.title_ua}</h1>
          {lesson.title_hr && (
            <Hr as="p" className="mt-1 text-body-lg text-ink-muted">
              {lesson.title_hr}
            </Hr>
          )}
        </div>
        {lesson.objectives && lesson.objectives.length > 0 && (
          <div>
            <p className="flex items-center gap-2 text-label">
              <Target className="size-4 text-primary-ink" aria-hidden="true" />
              Після уроку ви зможете:
            </p>
            <ul className="mt-2 flex flex-col gap-1.5">
              {lesson.objectives.map((o) => (
                <li key={o} className="flex items-start gap-2 text-body">
                  <CircleCheck className="mt-0.5 size-4 shrink-0 text-success" aria-hidden="true" />
                  {o}
                </li>
              ))}
            </ul>
          </div>
        )}
        <ul className="grid grid-cols-3 gap-2 text-center">
          <Stat icon={<BookOpen className="size-5" aria-hidden="true" />} value={words.length} label={pluralUk(words.length, ['слово', 'слова', 'слів'])} />
          <Stat icon={<MessagesSquare className="size-5" aria-hidden="true" />} value={turns} label={pluralUk(turns, ['репліка', 'репліки', 'реплік'])} />
          <Stat icon={<Dumbbell className="size-5" aria-hidden="true" />} value={exercises.length} label={pluralUk(exercises.length, ['вправа', 'вправи', 'вправ'])} />
        </ul>
      </Card>,
      <Button block onClick={next}>
        Почати урок
      </Button>,
    );
  }

  // ---------------------------------------------------------------- слова
  if (stage === 'words') {
    return shell(
      <>
        <div>
          <h2 className="font-heading text-h2">Слова уроку</h2>
          <p className="mt-1 text-body text-ink-muted">Послухайте кожне слово й повторіть уголос. Після уроку вони потраплять у повторення.</p>
        </div>
        <ul className="flex flex-col gap-2">
          {words.map((w) => (
            <li key={w.id}>
              <Card className="flex items-center gap-3 py-3 pl-4 pr-2">
                <div className="min-w-0 flex-1">
                  <Hr as="p" className="font-heading text-h3 break-words">
                    {w.hr_text}
                  </Hr>
                  <p className="text-body text-ink-muted">{w.ua_translation}</p>
                </div>
                <AudioButton text={w.hr_text} label={`Прослухати «${w.hr_text}»`} />
              </Card>
            </li>
          ))}
        </ul>
      </>,
      <>
        <Button block onClick={next}>
          Далі
        </Button>
        <Button block variant="tertiary" onClick={back}>
          Назад
        </Button>
      </>,
    );
  }

  // ---------------------------------------------------------------- діалоги
  if (stage === 'dialogue') {
    const d = dialogues[Math.min(scene, dialogues.length - 1)];
    return (
      <DialogueStep
        key={d.id}
        shell={shell}
        dialogue={d}
        index={scene}
        total={dialogues.length}
        onNext={() => {
          if (scene + 1 < dialogues.length) {
            setScene(scene + 1);
            window.scrollTo({ top: 0 });
          } else next();
        }}
        onBack={() => {
          if (scene > 0) setScene(scene - 1);
          else back();
        }}
      />
    );
  }

  // ---------------------------------------------------------------- граматика
  if (stage === 'grammar') {
    return shell(
      <>
        <h2 className="font-heading text-h2">Граматика</h2>
        {grammar.map((topic) => (
          <Card key={topic.id} className="flex flex-col gap-4">
            <div>
              <h3 className="font-heading text-h3">{topic.title_ua}</h3>
              {topic.description && <p className="mt-1 text-body text-ink-muted">{topic.description}</p>}
            </div>
            {topic.rules.map((rule) => (
              <div key={rule.id} className="flex flex-col gap-2 border-t border-line pt-4">
                <p className="text-label text-primary-ink">{rule.title_ua}</p>
                <p className="text-body">{rule.explanation_ua}</p>
                {rule.pattern_hr && (
                  <Hr as="p" className="rounded-control bg-surface-muted px-3 py-2 text-center font-heading text-body">
                    {rule.pattern_hr}
                  </Hr>
                )}
                {rule.examples.length > 0 && (
                  <ul className="flex flex-col gap-1">
                    {rule.examples.map((ex, i) => (
                      <li key={i} className="flex items-center gap-2">
                        <div className="min-w-0 flex-1">
                          <Hr as="p" className="text-body font-semibold">
                            {ex.hr}
                          </Hr>
                          <p className="text-label font-normal text-ink-muted">{ex.ua}</p>
                        </div>
                        <AudioButton text={ex.hr} label={`Прослухати «${ex.hr}»`} />
                      </li>
                    ))}
                  </ul>
                )}
              </div>
            ))}
          </Card>
        ))}
        {(content.pitfalls ?? []).map((e) => (
          <TypicalErrorCard key={e.code} error={e} />
        ))}
      </>,
      <>
        <Button block onClick={next}>
          До вправ
        </Button>
        <Button block variant="tertiary" onClick={back}>
          Назад
        </Button>
      </>,
    );
  }

  // ---------------------------------------------------------------- вправи
  const currentId = practice.queue[0];
  const current = stage === 'practice' && currentId ? byId.get(currentId) : undefined;
  if (current) {
    const retry = isRetry(practice);
    const onNext = (outcome: PracticeOutcome, verdict?: string) => {
      track('exercise_completed', {
        lesson_id: lesson.id,
        exercise_id: current.id,
        exercise_type: current.exercise_type,
        success: outcome === 'correct',
        attempt: retry ? 2 : 1,
        duration_ms: Date.now() - exerciseStartRef.current,
        ...(verdict ? { verdict } : {}),
      });
      exerciseStartRef.current = Date.now();
      const after = answerCurrent(practice, outcome);
      setPractice(after);
      setRound((r) => r + 1);
      if (after.queue.length === 0) {
        finishSpeech();
        goTo('summary');
      }
      else window.scrollTo({ top: 0 });
    };
    return shell(
      <>
        <p className="text-caption text-ink-muted">
          Вправа {Math.min(practiceDone(practice) + 1, practice.total)} з {practice.total}
        </p>
        <LessonExercise
          key={`${current.id}:${round}`}
          exercise={current}
          retry={retry}
          onNext={onNext}
          onSpeechAttempt={current.exercise_type === 'speaking' ? recordSpeech(current.id) : undefined}
        />
      </>,
    );
  }

  // ---------------------------------------------------------------- підсумок
  return (
    <SummaryStep
      shell={shell}
      onComplete={onComplete}
      firstTry={practice.firstTry.length}
      solved={practice.solved.length}
      total={practice.total}
      words={words.length}
      objectives={lesson.objectives ?? []}
      situation={situation}
      onRestart={restart}
    />
  );
}

function Stat({ icon, value, label }: { icon: React.ReactNode; value: number; label: string }) {
  return (
    <li className="flex flex-col items-center gap-1 rounded-control bg-surface-muted px-2 py-3">
      <span className="text-primary-ink">{icon}</span>
      <span className="font-heading text-h3">{value}</span>
      <span className="text-caption text-ink-muted">{label}</span>
    </li>
  );
}

// ---------------------------------------------------------------- діалог
function DialogueStep({
  shell,
  dialogue,
  index,
  total,
  onNext,
  onBack,
}: {
  shell: Shell;
  dialogue: LessonDialogue;
  index: number;
  total: number;
  onNext: () => void;
  onBack: () => void;
}) {
  const [showTranslation, setShowTranslation] = useState(true);
  const [acting, setActing] = useState(false);
  const speakers = useMemo(() => Array.from(new Set(dialogue.lines.map((l) => l.speaker_name))), [dialogue.lines]);

  if (acting) {
    return <RoleplaySimulator lines={dialogue.lines} uniqueSpeakers={speakers} onExit={() => setActing(false)} />;
  }

  return shell(
    <>
      <div>
        <p className="text-label text-ink-muted">
          Діалог {index + 1} з {total}
        </p>
        <h2 className="mt-1 font-heading text-h2">{dialogue.title_ua ?? 'Діалог'}</h2>
        {dialogue.title_hr && (
          <Hr as="p" className="text-body text-ink-muted">
            {dialogue.title_hr}
          </Hr>
        )}
      </div>
      <div className="flex items-center justify-between gap-2">
        <p className="text-caption text-ink-subtle">Натисніть репліку, щоб послухати</p>
        <button
          type="button"
          onClick={() => setShowTranslation((v) => !v)}
          aria-pressed={!showTranslation}
          className="flex min-h-11 items-center gap-1 rounded-control px-2 text-label font-normal text-ink-muted hover:bg-surface-muted"
        >
          <Languages className="size-4" aria-hidden="true" />
          {showTranslation ? 'Сховати переклад' : 'Показати переклад'}
        </button>
      </div>
      <ol className="flex flex-col gap-3">
        {dialogue.lines.map((line) => {
          const right = speakers.indexOf(line.speaker_name) % 2 === 1;
          return (
            <li key={line.id} className={cn('flex flex-col', right ? 'items-end' : 'items-start')}>
              <Hr className="mb-1 px-1 text-caption text-ink-subtle">{line.speaker_name}</Hr>
              <button
                type="button"
                onClick={() => speakCroatian(line.hr_text)}
                className={cn(
                  'max-w-[88%] rounded-card px-4 py-3 text-left shadow-sm transition-colors duration-150 active:scale-[0.98]',
                  right ? 'bg-primary-soft text-ink' : 'border border-line bg-surface text-ink',
                )}
              >
                <Hr as="p" className="text-body-lg font-semibold break-words">
                  {line.hr_text}
                </Hr>
                {showTranslation && <p className="mt-0.5 text-label font-normal text-ink-muted">{line.ua_translation}</p>}
              </button>
            </li>
          );
        })}
      </ol>
    </>,
    <>
      <Button block onClick={onNext}>
        {index + 1 < total ? 'Наступний діалог' : 'Далі'}
      </Button>
      <div className="grid grid-cols-2 gap-2">
        <Button variant="tertiary" onClick={onBack}>
          Назад
        </Button>
        <Button variant="secondary" onClick={() => setActing(true)}>
          Відіграти роль
        </Button>
      </div>
    </>,
  );
}

// ---------------------------------------------------------------- святковий підсумок
/**
 * Свято після уроку (рішення власника 2026-10-20): 🎉 + конфеті один раз, «+N нових слів», серія днів 🔥,
 * «Тепер ви вмієте…» (цілі уроку). Тексти — lib/celebration.ts. Прогрес зберігаємо один раз, щойно відкрився підсумок.
 */
function SummaryStep({
  shell,
  onComplete,
  firstTry,
  solved,
  total,
  words,
  objectives,
  situation,
  onRestart,
}: {
  shell: Shell;
  onComplete: () => Promise<CompleteResult>;
  firstTry: number;
  solved: number;
  total: number;
  words: number;
  objectives: string[];
  situation: string | null;
  onRestart: () => void;
}) {
  const [save, setSave] = useState<'saving' | 'saved' | 'error'>('saving');
  const [result, setResult] = useState<CompleteResult>(undefined);
  const startedRef = useRef(false);
  const completeRef = useRef(onComplete);

  const run = () =>
    completeRef.current().then(
      (res) => {
        setResult(res);
        setSave('saved');
      },
      () => setSave('error'),
    );
  const retrySave = () => {
    setSave('saving');
    void run();
  };

  // Зберігаємо один раз, щойно відкрився підсумок
  useEffect(() => {
    if (startedRef.current) return;
    startedRef.current = true;
    void completeRef.current().then(
      (res) => {
        setResult(res);
        setSave('saved');
      },
      () => setSave('error'),
    );
  }, []);

  const info = situation ? situationInfo(situation) : null;
  const mascot = useStoredMascot();
  const party = result
    ? lessonCelebration({ newWords: result.addedToReview, lessonWords: result.lessonWords, streak: result.streak })
    : null;

  return shell(
    <SessionDone
      correct={firstTry}
      total={total}
      emoji="🎉"
      hero={<Mascot kind={mascot} size={128} pop />}
      title="Урок пройдено!"
      headingAs="h1"
      celebrate
      barLabel="Правильних з першої спроби"
      stats={
        save === 'saved' && party && party.tiles.length > 0 ? (
          <ul className={cn('grid w-full gap-2', party.tiles.length > 1 ? 'grid-cols-2' : 'grid-cols-1')}>
            {party.tiles.map((t, i) => (
              <StatTile key={t.emoji} {...t} index={i} />
            ))}
          </ul>
        ) : null
      }
      footer={
        <>
          {objectives.length > 0 && (
            <div className="w-full rounded-card bg-surface-muted px-4 py-3 text-left">
              <p className="flex items-center gap-2 text-label">
                <Target className="size-4 text-primary-ink" aria-hidden="true" />
                Тепер ви вмієте:
              </p>
              <ul className="mt-2 flex flex-col gap-1.5">
                {objectives.map((o) => (
                  <li key={o} className="flex items-start gap-2 text-body">
                    <CircleCheck className="mt-0.5 size-4 shrink-0 text-success" aria-hidden="true" />
                    {o}
                  </li>
                ))}
              </ul>
            </div>
          )}
          <p className="text-body">
            {save === 'saving' && 'Зберігаємо прогрес…'}
            {save === 'saved' &&
              (party
                ? [party.streakNote, party.reviewNote].filter(Boolean).join(' ') || 'Прогрес збережено.'
                : words > 0
                  ? `Прогрес збережено. ${countUk(words, ['слово', 'слова', 'слів'])} уроку чекають на вас у повторенні завтра.`
                  : 'Прогрес збережено.')}
            {save === 'error' && <span className="text-danger-ink">Не вдалося зберегти прогрес — перевірте інтернет.</span>}
          </p>
        </>
      }
    >
      {total > 0 && (
        <>
          З першої спроби: {firstTry} з {total}
          {solved > firstTry ? ` · після повтору ще ${solved - firstTry}` : ''}.
        </>
      )}
    </SessionDone>,
    <>
      {save === 'error' ? (
        <Button block onClick={retrySave}>
          Зберегти ще раз
        </Button>
      ) : (
        <Button block href="/lessons">
          До уроків
        </Button>
      )}
      {info && (
        <Button block variant="secondary" href={`/situations/${situation}/roleplay`}>
          <Sparkles className="size-4" aria-hidden="true" />
          Розмова з AI: {info.label}
        </Button>
      )}
      <Button block variant="tertiary" onClick={onRestart}>
        Пройти урок ще раз
      </Button>
    </>,
  );
}
