'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { useRouter } from 'next/navigation';
import { BookmarkPlus, CircleCheck, CircleX, Languages, Lightbulb, Square, Volume2, X } from 'lucide-react';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import IconButton from '@/components/ui/IconButton';
import LevelBadge from '@/components/ui/LevelBadge';
import SessionDone from '@/components/ui/SessionDone';
import { levelStyle } from '@/lib/levels';
import { track } from '@/lib/analytics-client';
import {
  glossaryIndex, isCroatianOption, knownLabel, paragraphs, readingMinutes, scoreAnswers, seededShuffle, speechChunks, textTypeIcon, textTypeLabel, tokenize,
  type GlossaryEntry, type ReadingText,
} from '@/lib/reading';
import { cn } from '@/lib/ui';
import { playCroatian, stopCroatianAudio } from '@/utils/speech';

type Result = { ok: true } | { ok: false; error: string };

/**
 * Екран читання (§6, §56): текст, у якому можна натиснути будь-яке слово й побачити переклад,
 * зберегти слово в тренажер, прослухати текст, відкрити переклад і відповісти на 3 питання.
 * Дані й збереження — у сторінки (app/reading/[id]/page.tsx).
 */
export default function ReadingView({
  text,
  onComplete,
  onSaveWord,
}: {
  text: ReadingText;
  onComplete: (correct: number, total: number, durationMs: number) => Promise<Result>;
  onSaveWord: (lemma: string) => Promise<Result>;
}) {
  const router = useRouter();
  const glossary = useMemo(() => glossaryIndex(text.glossary), [text.glossary]);
  const lines = useMemo(() => paragraphs(text.body_hr), [text.body_hr]);
  const isSign = text.text_type === 'sign';
  const listHref = `/reading?level=${encodeURIComponent(text.cefr)}`;
  const options = useMemo(() => text.questions.map((q, i) => seededShuffle(q.options, `${text.code}:${i}`)), [text]);

  const [selected, setSelected] = useState<GlossaryEntry | null>(null);
  const [showTranslation, setShowTranslation] = useState(false);
  const [answers, setAnswers] = useState<Array<string | null>>(() => text.questions.map(() => null));
  const [checked, setChecked] = useState(false);
  const [saveState, setSaveState] = useState<Record<string, 'saving' | 'saved' | string>>({});
  const [completeError, setCompleteError] = useState<string | null>(null);
  const [playing, setPlaying] = useState(false);
  const stopRef = useRef(false);
  const startedAtRef = useRef(Date.now());

  useEffect(() => {
    startedAtRef.current = Date.now();
    track('reading_started', { source: 'reading', level: text.cefr, count: text.word_count, skill: 'reading' });
    return () => {
      stopRef.current = true;
      stopCroatianAudio();
    };
  }, [text.id, text.cefr, text.word_count]);

  // Озвучення всього тексту шматками (TTS не приймає довгих рядків); «Стоп» — зупинити
  const play = () => {
    if (playing) {
      stopRef.current = true;
      stopCroatianAudio();
      setPlaying(false);
      return;
    }
    const chunks = speechChunks(text.body_hr);
    stopRef.current = false;
    setPlaying(true);
    const next = (i: number) => {
      if (stopRef.current || i >= chunks.length) {
        setPlaying(false);
        return;
      }
      // один звук на весь застосунок: 🔊 біля слова або новий ▶ зупиняє читання тексту
      playCroatian(chunks[i], {
        raw: true,
        onEnded: () => next(i + 1),
        onError: () => setPlaying(false),
        onStop: () => {
          stopRef.current = true;
          setPlaying(false);
        },
      });
    };
    next(0);
  };

  const save = async (entry: GlossaryEntry) => {
    setSaveState((s) => ({ ...s, [entry.lemma]: 'saving' }));
    const res = await onSaveWord(entry.lemma);
    setSaveState((s) => ({ ...s, [entry.lemma]: res.ok ? 'saved' : res.error }));
  };

  const allAnswered = answers.every((a) => a !== null);
  const correct = scoreAnswers(text.questions, answers);

  const check = async () => {
    setChecked(true);
    const res = await onComplete(correct, text.questions.length, Date.now() - startedAtRef.current);
    if (!res.ok) setCompleteError(res.error);
  };

  const again = () => {
    setAnswers(text.questions.map(() => null));
    setChecked(false);
    setCompleteError(null);
    startedAtRef.current = Date.now();
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const known = knownLabel(text.known_ratio);
  const selectedState = selected ? saveState[selected.lemma] : undefined;

  return (
    <div className="mx-auto min-h-screen max-w-2xl px-5 pb-40 pt-[calc(1rem+env(safe-area-inset-top))]">
      <div className="mb-4 flex items-center gap-2">
        <IconButton label="Закрити текст" onClick={() => router.push(listHref)}>
          <X className="size-6" aria-hidden="true" />
        </IconButton>
        <LevelBadge level={text.cefr} />
        <span className="text-label text-ink-muted">{textTypeLabel(text.text_type)}</span>
      </div>

      <div className="mb-4 flex items-start gap-4">
        <span
          className={cn('flex size-16 shrink-0 items-center justify-center rounded-card text-4xl leading-none', levelStyle(text.cefr).soft)}
          aria-hidden="true"
        >
          {textTypeIcon(text.text_type)}
        </span>
        <div className="min-w-0 flex-1">
          <h1 className="font-heading text-h1 break-words">{text.title_ua}</h1>
          <Hr as="p" className="mb-1 text-body-lg text-ink-muted">
            {text.title_hr}
          </Hr>
          <p className="text-caption text-ink-muted">
            ~{readingMinutes(text.word_count)} хв · {text.word_count} слів{known ? ` · ${known}` : ''}
          </p>
        </div>
      </div>

      <div className="mb-4 flex gap-2">
        <Button size="sm" variant="secondary" onClick={play} aria-pressed={playing}>
          {playing ? <Square className="size-4" aria-hidden="true" /> : <Volume2 className="size-4" aria-hidden="true" />}
          {playing ? 'Зупинити' : 'Прослухати'}
        </Button>
        <Button size="sm" variant="tertiary" onClick={() => setShowTranslation((v) => !v)} aria-pressed={showTranslation}>
          <Languages className="size-4" aria-hidden="true" />
          {showTranslation ? 'Сховати переклад' : 'Переклад'}
        </Button>
      </div>

      <p className="mb-2 text-label text-ink-muted">Натисніть слово, щоб побачити переклад.</p>
      <Card className={cn('mb-4 flex flex-col', isSign ? 'items-center gap-2' : 'gap-3')}>
        {lines.map((line, li) => (
          <Hr
            as="p"
            key={li}
            className={cn(
              'text-body-lg leading-relaxed',
              // Вивіски (A0): кожен рядок — окрема табличка
              isSign && 'w-full rounded-control border-2 border-ink px-3 py-2 text-center font-heading tracking-wide',
            )}
          >
            {tokenize(line).map((seg, si) =>
              seg.word && glossary.has(seg.word) ? (
                <button
                  key={si}
                  type="button"
                  onClick={() => setSelected(glossary.get(seg.word!) ?? null)}
                  className={cn(
                    'rounded-sm px-px underline decoration-line decoration-dotted underline-offset-4 transition-colors duration-150 hover:bg-primary-soft',
                    selected && selected.form === seg.word && 'bg-primary-soft text-primary-ink',
                  )}
                >
                  {seg.text}
                </button>
              ) : (
                <span key={si}>{seg.text}</span>
              ),
            )}
          </Hr>
        ))}
      </Card>

      {showTranslation && (
        <Card className="mb-4 flex flex-col gap-2 bg-surface-muted">
          <p className="text-label text-ink-muted">Переклад</p>
          {paragraphs(text.body_ua).map((l, i) => (
            <p key={i} className="text-body">
              {l}
            </p>
          ))}
        </Card>
      )}

      {/* Питання на розуміння */}
      <section aria-labelledby="reading-questions" className="flex flex-col gap-3">
        <h2 id="reading-questions" className="font-heading text-h2">
          Чи все зрозуміло?
        </h2>
        {text.questions.map((q, qi) => (
          <Card key={qi} className="flex flex-col gap-2">
            <p className="font-heading text-body-lg">
              {qi + 1}. {q.question_ua}
            </p>
            <div className="flex flex-col gap-2" role="group" aria-label={q.question_ua}>
              {options[qi].map((o) => {
                const picked = answers[qi] === o;
                const isAnswer = o === q.answer;
                return (
                  <button
                    key={o}
                    type="button"
                    disabled={checked}
                    aria-pressed={picked}
                    onClick={() => setAnswers((a) => a.map((x, i) => (i === qi ? o : x)))}
                    className={cn(
                      'flex min-h-12 items-center gap-2 rounded-control border-2 px-3 py-2 text-left text-body transition-colors duration-150',
                      !checked && (picked ? 'border-primary bg-primary-soft text-primary-ink' : 'border-line bg-surface hover:border-primary'),
                      checked && isAnswer && 'border-success-line bg-success-soft text-success-ink',
                      checked && picked && !isAnswer && 'border-danger-line bg-danger-soft text-danger-ink',
                      checked && !picked && !isAnswer && 'border-line bg-surface text-ink-muted',
                    )}
                  >
                    {checked && isAnswer && <CircleCheck className="size-5 shrink-0" aria-hidden="true" />}
                    {checked && picked && !isAnswer && <CircleX className="size-5 shrink-0" aria-hidden="true" />}
                    {isCroatianOption(o) ? (
                      <Hr className="flex-1">{o}</Hr>
                    ) : (
                      <span className="flex-1">{o}</span>
                    )}
                    {checked && isAnswer && <span className="sr-only">— правильна відповідь</span>}
                    {checked && picked && !isAnswer && <span className="sr-only">— ваша відповідь, неправильна</span>}
                  </button>
                );
              })}
            </div>
          </Card>
        ))}

        {!checked ? (
          <Button block disabled={!allAnswered} onClick={() => void check()}>
            Перевірити
          </Button>
        ) : (
          <SessionDone
            correct={correct}
            total={text.questions.length}
            actions={
              <>
                <Button block href={listHref}>
                  До списку текстів
                </Button>
                <Button block variant="secondary" onClick={again}>
                  Ще раз
                </Button>
              </>
            }
          >
            <p>
              Правильно: {correct} з {text.questions.length}.
              {correct < text.questions.length && ' Перечитайте текст — можна відкрити переклад.'}
            </p>
            {completeError && <p className="mt-2 text-label text-danger-ink">{completeError}</p>}
          </SessionDone>
        )}
      </section>

      {/* Переклад слова (нижній лист) */}
      {selected && (
        <div
          role="dialog"
          aria-label={`Слово «${selected.form}»`}
          className="fixed inset-x-0 bottom-0 z-40 mx-auto max-w-2xl rounded-t-hero border border-line bg-surface p-5 pb-[calc(1.25rem+env(safe-area-inset-bottom))] shadow-md animate-fade-in-up"
        >
          <div className="flex items-start gap-2">
            <div className="min-w-0 flex-1">
              <Hr as="p" className="font-heading text-word">
                {selected.lemma}
              </Hr>
              {selected.pos && <p className="text-caption text-ink-muted">{selected.pos}</p>}
              <p className="mt-1 text-body-lg">{selected.ua}</p>
            </div>
            <AudioButton text={selected.lemma} label={`Прослухати «${selected.lemma}»`} />
            <IconButton label="Закрити переклад" onClick={() => setSelected(null)}>
              <X className="size-5" aria-hidden="true" />
            </IconButton>
          </div>
          {(selected.gram || selected.form !== selected.lemma.toLowerCase()) && (
            <div className="mt-3 flex gap-2 rounded-control border border-warning-line bg-warning-soft p-3 text-warning-ink">
              <Lightbulb className="mt-0.5 size-4 shrink-0" aria-hidden="true" />
              <div className="min-w-0 text-label font-normal">
                <p>
                  <span className="sr-only">Граматика: </span>
                  у тексті — <Hr className="font-semibold">{selected.form}</Hr>
                </p>
                {selected.gram && <p className="mt-0.5">{selected.gram}</p>}
              </div>
            </div>
          )}
          {selected.lesson && (
            <div className="mt-3">
              {selectedState === 'saved' ? (
                <p className="flex items-center gap-2 text-label text-success-ink" role="status">
                  <CircleCheck className="size-5" aria-hidden="true" />
                  Збережено в тренажер
                </p>
              ) : (
                <>
                  <Button block size="sm" variant="secondary" loading={selectedState === 'saving'} onClick={() => void save(selected)}>
                    <BookmarkPlus className="size-4" aria-hidden="true" />
                    Зберегти в тренажер
                  </Button>
                  {selectedState && selectedState !== 'saving' && (
                    <p className="mt-2 text-label text-danger-ink" role="status">
                      {selectedState}
                    </p>
                  )}
                </>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
