'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { Mic, Play, Square } from 'lucide-react';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import PageHeader from '@/components/ui/PageHeader';
import ProgressBar from '@/components/ui/ProgressBar';
import ErrorState from '@/components/ui/ErrorState';
import EmptyState from '@/components/ui/EmptyState';
import AssessmentResult from '@/components/AssessmentResult';
import { AREA_ICONS } from '@/components/assessment-icons';
import { submitAssessment, type AssessmentResultView } from '@/app/actions/assessment';
import { track } from '@/lib/analytics-client';
import { AREA_LABELS, AREAS, percent, type Area, type ItemResponse } from '@/lib/assessment';
import { isUkrainian, tilesFrom } from '@/lib/lesson-flow';
import { speakCroatian } from '@/utils/speech';
import { browserSpeech } from '@/utils/speech-recognition';
import { SpeechError, type ListeningSession, type SpeechErrorCode } from '@/lib/speech-provider';
import { cn } from '@/lib/ui';

/** Завдання без правильної відповіді (її знає лише сервер). */
export interface PlayerItem {
  id: string;
  area: Area;
  skill: string;
  item_type: string;
  prompt_ua: string;
  prompt_hr: string | null;
  options: string[];
  audio_hr: string | null;
  passage_hr: string | null;
}

const SKILL_TITLE: Record<string, string> = {
  listening: 'Послухайте',
  reading: 'Прочитайте',
  interaction: 'Розмова',
  mediation: 'Допоможіть другу',
  writing: 'Напишіть хорватською',
  speaking: 'Скажіть уголос',
};

type Phase = 'intro' | 'items' | 'submitting' | 'error' | 'result';

/**
 * Тест рівня (§60): вступ → завдання по одному (відповіді не показуємо до кінця) →
 * перевірка на сервері → результат за 4 навичками. Говоріння можна пропустити.
 */
export default function AssessmentPlayer(props: {
  slug: string;
  kind: string;
  cefr: string;
  title: string;
  subtitle: string | null;
  description: string | null;
  minutes: number | null;
  passRatio: number;
  areaMinRatio: number;
  items: PlayerItem[];
  loadError: boolean;
}) {
  const { slug, kind, cefr, title, subtitle, description, minutes, passRatio, areaMinRatio, items, loadError } = props;
  const backHref = `/lessons/tests?level=${cefr}`;
  const [phase, setPhase] = useState<Phase>('intro');
  const [index, setIndex] = useState(0);
  const [responses, setResponses] = useState<Record<string, ItemResponse>>({});
  const [result, setResult] = useState<AssessmentResultView | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [run, setRun] = useState(0); // «Пройти ще раз» — нові ключі завдань
  const startedAt = useRef<string | null>(null);

  const counts = useMemo(() => {
    const c: Record<Area, number> = { understand: 0, produce: 0, interact: 0, mediate: 0 };
    for (const it of items) c[it.area] += 1;
    return c;
  }, [items]);

  if (loadError) {
    return (
      <div className="min-h-screen">
        <PageHeader title={title} backHref={backHref} closeMode />
        <main className="mx-auto max-w-md px-4 py-10">
          <EmptyState title="Тест поки недоступний" text="Перевірте інтернет або спробуйте пізніше." action={<Button href={backHref}>До перевірок</Button>} />
        </main>
      </div>
    );
  }

  const start = () => {
    startedAt.current = new Date().toISOString();
    setResponses({});
    setIndex(0);
    setResult(null);
    setRun((r) => r + 1);
    setPhase('items');
    track('assessment_started', { level: cefr, assessment_kind: kind, assessment_slug: slug, count: items.length });
  };

  const submit = async (all: Record<string, ItemResponse>) => {
    setPhase('submitting');
    setError(null);
    try {
      const res = await submitAssessment(slug, Object.values(all), startedAt.current);
      if (res.ok) {
        setResult(res.result);
        setPhase('result');
      } else {
        setError(res.error);
        setPhase('error');
      }
    } catch {
      setError('Немає інтернету — результат не перевірено. Відповіді збережено на цьому екрані: спробуйте ще раз.');
      setPhase('error');
    }
  };

  const answer = (r: ItemResponse) => {
    const next = { ...responses, [r.item_id]: r };
    setResponses(next);
    if (index + 1 < items.length) setIndex(index + 1);
    else void submit(next);
  };

  if (phase === 'intro') {
    return (
      <div className="min-h-screen">
        <PageHeader title={title} backHref={backHref} closeMode />
        <main className="mx-auto flex max-w-md flex-col gap-4 px-4 py-6">
          <Card className="flex flex-col gap-3">
            <p className="text-label text-ink-muted">{cefr}{subtitle ? ` · ${subtitle}` : ''}</p>
            <h2 className="font-heading text-h2">{title}</h2>
            {description && <p className="text-body text-ink-muted">{description}</p>}
            <ul className="flex flex-col gap-2" aria-label="Що перевіряємо">
              {AREAS.map((a) => {
                const Icon = AREA_ICONS[a];
                return (
                  <li key={a} className="flex items-center gap-3">
                    <span className="flex size-10 shrink-0 items-center justify-center rounded-full bg-primary-soft text-primary-ink">
                      <Icon className="size-5" aria-hidden="true" />
                    </span>
                    <span className="min-w-0 flex-1">
                      <span className="block text-body font-semibold">{AREA_LABELS[a].title}</span>
                      <span className="block text-caption text-ink-subtle">{AREA_LABELS[a].hint}</span>
                    </span>
                    <span className="text-label text-ink-muted">{counts[a]}</span>
                  </li>
                );
              })}
            </ul>
          </Card>
          <ul className="flex flex-col gap-1 px-1 text-body text-ink-muted">
            <li>• {items.length} завдань{minutes ? `, ~${minutes} хв` : ''}. Правильні відповіді — наприкінці.</li>
            <li>• Пройдено, якщо ≥ {percent(passRatio)} % загалом і ≥ {percent(areaMinRatio)} % у кожній навичці.</li>
            <li>• Немає мікрофона — завдання «вголос» можна пропустити.</li>
            <li>• Уроки тест не блокує. Результат — оцінка застосунку, не офіційний сертифікат.</li>
          </ul>
          <Button block onClick={start}>Почати</Button>
        </main>
      </div>
    );
  }

  if (phase === 'submitting') {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center gap-4" role="status">
        <div className="size-10 rounded-full border-4 border-primary-soft border-t-primary animate-spin" aria-hidden="true" />
        <p className="text-body text-ink-muted">Перевіряємо відповіді…</p>
      </div>
    );
  }

  if (phase === 'error') {
    return (
      <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-4">
        <ErrorState title="Не вдалося перевірити тест" text={error ?? undefined} onRetry={() => void submit(responses)} />
      </div>
    );
  }

  if (phase === 'result' && result) {
    return <AssessmentResult result={result} title={title} backHref={backHref} onRetry={start} />;
  }

  const item = items[index];
  const Icon = AREA_ICONS[item.area];
  return (
    <div className="min-h-screen pb-10">
      <PageHeader title={title} backHref={backHref} closeMode>
        <div className="flex items-center gap-3">
          <ProgressBar value={index} max={items.length} label="Прогрес тесту" className="flex-1" />
          <span className="text-caption text-ink-subtle">{index + 1} / {items.length}</span>
        </div>
      </PageHeader>
      <main className="mx-auto flex max-w-md flex-col gap-4 px-4 py-6">
        <p className="flex items-center gap-2 text-label text-ink-muted">
          <Icon className="size-4" aria-hidden="true" />
          {AREA_LABELS[item.area].title} · {SKILL_TITLE[item.skill] ?? 'Завдання'}
        </p>
        <ItemView key={`${run}:${item.id}`} item={item} onAnswer={answer} />
      </main>
    </div>
  );
}

// ---------------------------------------------------------------- одне завдання
function ItemView({ item, onAnswer }: { item: PlayerItem; onAnswer: (r: ItemResponse) => void }) {
  switch (item.item_type) {
    case 'multiple_choice':
      return <ChoiceItem item={item} onAnswer={onAnswer} />;
    case 'type_answer':
      return <TypeItem item={item} onAnswer={onAnswer} />;
    case 'sentence_builder':
      return <TilesItem item={item} onAnswer={onAnswer} />;
    case 'speaking':
      return <SpeakItem item={item} onAnswer={onAnswer} />;
    default:
      return (
        <Button block onClick={() => onAnswer({ item_id: item.id })}>
          Далі
        </Button>
      );
  }
}

function Passage({ text, title }: { text: string; title?: string | null }) {
  return (
    <Card className="flex flex-col gap-1">
      {title && <Hr as="p" className="mb-1 text-label text-ink-muted">{title}</Hr>}
      {text.split('\n').filter((l) => l.trim()).map((line, i) => {
        const m = line.match(/^([^:]{1,30}):\s(.+)$/);
        return (
          <p key={i} className="text-body-lg break-words">
            {m ? (
              <>
                <span className="text-label text-ink-muted">{m[1]}: </span>
                <Hr>{m[2]}</Hr>
              </>
            ) : (
              <Hr>{line}</Hr>
            )}
          </p>
        );
      })}
    </Card>
  );
}

function ListenButton({ text }: { text: string }) {
  const played = useRef(false);
  useEffect(() => {
    // користувач щойно натиснув «Далі» — звук дозволено
    if (!played.current) {
      played.current = true;
      speakCroatian(text);
    }
  }, [text]);
  return (
    <div className="flex flex-col items-center gap-2 py-2">
      <button
        type="button"
        onClick={() => speakCroatian(text)}
        aria-label="Прослухати ще раз"
        className="flex size-20 items-center justify-center rounded-full bg-primary text-white shadow-md transition-colors duration-150 hover:bg-primary-hover active:scale-[0.98]"
      >
        <Play className="size-8 translate-x-0.5" aria-hidden="true" />
      </button>
      <p className="text-label font-normal text-ink-muted">Натисніть, щоб послухати ще раз</p>
    </div>
  );
}

function ChoiceItem({ item, onAnswer }: { item: PlayerItem; onAnswer: (r: ItemResponse) => void }) {
  const [picked, setPicked] = useState<number | null>(null);
  const listenOnly = item.skill === 'listening' && item.audio_hr;
  // У читанні prompt_hr — назва тексту («SMS od kurira»): підпис над текстом, а не окрема фраза
  const titleInPassage = item.skill === 'reading' && Boolean(item.passage_hr);
  return (
    <div className="flex flex-col gap-4">
      {item.passage_hr && <Passage text={item.passage_hr} title={titleInPassage ? item.prompt_hr : null} />}
      <h2 className="font-heading text-h3 break-words">{item.prompt_ua}</h2>
      {listenOnly && <ListenButton text={item.audio_hr!} />}
      {!listenOnly && !titleInPassage && item.prompt_hr && (
        <div className="flex items-start gap-2 rounded-card border border-line bg-surface p-4">
          <Hr as="p" className="min-w-0 flex-1 font-heading text-h3 break-words">«{item.prompt_hr}»</Hr>
          {item.skill !== 'reading' && <AudioButton text={item.prompt_hr} />}
        </div>
      )}
      <div className="flex flex-col gap-2" role="radiogroup" aria-label="Варіанти відповіді">
        {item.options.map((opt, i) => {
          const Text = isUkrainian(opt) ? 'span' : Hr;
          return (
            <button
              key={`${i}:${opt}`}
              type="button"
              role="radio"
              aria-checked={picked === i}
              onClick={() => setPicked(i)}
              className={cn(
                'flex min-h-14 items-center rounded-control border-2 px-4 py-3 text-left text-body-lg transition-colors duration-150',
                picked === i ? 'border-primary bg-primary-soft text-primary-ink' : 'border-line bg-surface hover:border-primary',
              )}
            >
              <Text>{opt}</Text>
            </button>
          );
        })}
      </div>
      <Button block disabled={picked === null} onClick={() => onAnswer({ item_id: item.id, choice: picked })}>
        Далі
      </Button>
      <Button variant="tertiary" block onClick={() => onAnswer({ item_id: item.id, choice: null })}>
        Не знаю
      </Button>
    </div>
  );
}

function TypeItem({ item, onAnswer }: { item: PlayerItem; onAnswer: (r: ItemResponse) => void }) {
  const [value, setValue] = useState('');
  return (
    <form
      className="flex flex-col gap-3"
      onSubmit={(e) => {
        e.preventDefault();
        if (value.trim()) onAnswer({ item_id: item.id, text: value });
      }}
    >
      <h2 className="font-heading text-h3 break-words">{item.prompt_ua}</h2>
      <input
        value={value}
        onChange={(e) => setValue(e.target.value)}
        lang="hr"
        autoCapitalize="none"
        autoCorrect="off"
        autoComplete="off"
        spellCheck={false}
        aria-label="Ваша відповідь хорватською"
        placeholder="Ваша відповідь…"
        className="min-h-12 w-full rounded-control border-2 border-line bg-surface px-4 text-body-lg focus:border-primary focus:outline-none"
      />
      <p className="text-caption text-ink-subtle">Немає хорватських літер на клавіатурі? Можна писати c, s, z, d замість č, ć, š, ž, đ.</p>
      <Button type="submit" block disabled={!value.trim()}>
        Далі
      </Button>
      <Button variant="tertiary" block onClick={() => onAnswer({ item_id: item.id, text: '' })}>
        Не знаю
      </Button>
    </form>
  );
}

function TilesItem({ item, onAnswer }: { item: PlayerItem; onAnswer: (r: ItemResponse) => void }) {
  const tiles = useMemo(() => tilesFrom(item.options), [item.options]);
  const [picked, setPicked] = useState<typeof tiles>([]);
  const pool = tiles.filter((t) => !picked.some((p) => p.key === t.key));
  return (
    <div className="flex flex-col gap-4">
      <h2 className="font-heading text-h3 break-words">{item.prompt_ua}</h2>
      <div aria-live="polite" className="flex min-h-20 flex-wrap items-center gap-2 rounded-card border-2 border-dashed border-line bg-surface p-3">
        {picked.length === 0 && <span className="text-label font-normal text-ink-subtle">Натискайте слова нижче…</span>}
        {picked.map((t) => (
          <button key={t.key} type="button" lang="hr" onClick={() => setPicked((p) => p.filter((x) => x.key !== t.key))}
            className="min-h-11 rounded-control bg-primary-soft px-3 text-body text-primary-ink">
            {t.text}
          </button>
        ))}
      </div>
      <div className="flex flex-wrap justify-center gap-2">
        {pool.map((t) => (
          <button key={t.key} type="button" lang="hr" onClick={() => setPicked((p) => [...p, t])}
            className="min-h-11 rounded-control border border-line bg-surface px-3 text-body shadow-sm active:scale-[0.98]">
            {t.text}
          </button>
        ))}
      </div>
      <Button block disabled={picked.length === 0} onClick={() => onAnswer({ item_id: item.id, text: picked.map((t) => t.text).join(' ') })}>
        Далі
      </Button>
      <Button variant="tertiary" block onClick={() => onAnswer({ item_id: item.id, text: '' })}>
        Не знаю
      </Button>
    </div>
  );
}

const SPEECH_ERROR: Record<SpeechErrorCode, string> = {
  unsupported: 'Цей браузер не розпізнає мовлення (працює в Chrome чи Edge, Safari на iPhone). Завдання можна пропустити — воно не знизить бал.',
  'not-allowed': 'Немає доступу до мікрофона. Дозвольте його в налаштуваннях браузера або пропустіть завдання.',
  'audio-capture': 'Мікрофон не знайдено або він зайнятий іншою програмою.',
  network: 'Розпізнавання мовлення потребує інтернету. Перевірте з’єднання або пропустіть завдання.',
  'no-speech': 'Нічого не почули. Спробуйте ще раз.',
  aborted: 'Розпізнавання зупинено.',
  other: 'Не вдалося розпізнати мовлення. Спробуйте ще раз.',
};

/** Скажіть уголос: розпізнає браузер (SpeechProvider), оцінює сервер. До 3 спроб, далі — «Далі» або «Пропустити». */
function SpeakItem({ item, onAnswer }: { item: PlayerItem; onAnswer: (r: ItemResponse) => void }) {
  const supported = useMemo(() => browserSpeech.isSupported(), []);
  const [listening, setListening] = useState(false);
  const [interim, setInterim] = useState('');
  const [transcripts, setTranscripts] = useState<string[]>([]);
  const [tries, setTries] = useState(0);
  const [error, setError] = useState<SpeechErrorCode | null>(supported ? null : 'unsupported');
  const sessionRef = useRef<ListeningSession | null>(null);

  useEffect(() => () => sessionRef.current?.abort(), []);

  const listen = async () => {
    if (typeof navigator !== 'undefined' && navigator.onLine === false) {
      setError('network');
      return;
    }
    setError(null);
    setInterim('');
    setListening(true);
    const session = browserSpeech.transcribe({ lang: 'hr-HR', maxAlternatives: 3, onInterim: setInterim });
    sessionRef.current = session;
    try {
      const res = await session.result;
      setTranscripts(res.transcripts);
      setTries((t) => t + 1);
      if (res.transcripts.length === 0) setError('no-speech');
    } catch (err) {
      const code = err instanceof SpeechError ? err.code : 'other';
      if (code !== 'aborted') setError(code);
    } finally {
      setListening(false);
      sessionRef.current = null;
    }
  };

  const heard = transcripts[0] ?? '';
  return (
    <div className="flex flex-col gap-4">
      <h2 className="font-heading text-h3 break-words">{item.prompt_ua}</h2>
      <Card className="flex flex-col gap-4">
        {error !== 'unsupported' && (
          <div className="flex flex-col items-center gap-3 py-1">
            <button
              type="button"
              disabled={!listening && tries >= 3}
              onClick={() => (listening ? sessionRef.current?.stop() : void listen())}
              aria-label={listening ? 'Зупинити' : 'Почати говорити'}
              aria-pressed={listening}
              className={cn(
                'flex size-20 items-center justify-center rounded-full text-white shadow-md transition-colors duration-150 active:scale-[0.98] disabled:opacity-50',
                listening ? 'bg-danger animate-pulse' : 'bg-primary hover:bg-primary-hover',
              )}
            >
              {listening ? <Square className="size-7" aria-hidden="true" /> : <Mic className="size-8" aria-hidden="true" />}
            </button>
            <p className="min-h-6 text-center text-label font-normal text-ink-muted" aria-live="polite">
              {listening ? (interim ? <Hr>{interim}</Hr> : 'Слухаю… говоріть') : heard ? 'Можна сказати ще раз або йти далі' : 'Натисніть і скажіть фразу хорватською'}
            </p>
          </div>
        )}
        {heard && !listening && (
          <p className="text-body">
            Почули: «<Hr>{heard}</Hr>»
          </p>
        )}
        {error && (
          <p role="alert" className="rounded-card border border-warning-line bg-warning-soft p-4 text-body text-warning-ink">
            {SPEECH_ERROR[error]}
          </p>
        )}
        <p className="text-caption text-ink-subtle">Аудіо не записуємо: розпізнає браузер, ми бачимо лише текст.</p>
      </Card>
      <Button block disabled={!heard || listening} onClick={() => onAnswer({ item_id: item.id, transcripts })}>
        Далі
      </Button>
      <Button variant="tertiary" block onClick={() => { sessionRef.current?.abort(); onAnswer({ item_id: item.id, skipped: true }); }}>
        Не можу говорити — пропустити
      </Button>
    </div>
  );
}
