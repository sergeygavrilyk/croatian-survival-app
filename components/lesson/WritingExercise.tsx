'use client';

import { useEffect, useMemo, useRef, useState } from 'react';
import { CircleCheck, CircleDashed, CircleX, Eye, Mic, Square } from 'lucide-react';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import { browserSpeech } from '@/utils/speech-recognition';
import { SpeechError, type ListeningSession } from '@/lib/speech-provider';
import { answerLang, checkWriting, MAX_ANSWER, type WritingCheck, type WritingTask } from '@/lib/writing';
import type { PracticeOutcome } from '@/lib/lesson-flow';
import { cn } from '@/lib/ui';

/** Спроба письма / переказу — LessonPlayer зберігає її (writing_attempts / mediation_attempts, лише текст). */
export interface WritingAttempt {
  text: string;
  check: WritingCheck;
  outcome: PracticeOutcome;
  inputMode: 'typed' | 'voice';
}

/**
 * «Напишіть повідомлення» і «Перекажіть другу» (§57, §58). Перевірка без AI — lib/writing.ts:
 * пункти ✓ / ✗, підказки діакритик, зразок. Неправильну не повертаємо в чергу; вправу можна пропустити
 * (тоді вона не рахується як власне мовлення).
 */
export default function WritingExercise({
  task,
  onNext,
  onAttempt,
}: {
  task: WritingTask;
  onNext: (outcome: PracticeOutcome) => void;
  onAttempt?: (attempt: WritingAttempt) => void;
}) {
  const lang = answerLang(task);
  const [text, setText] = useState('');
  const [check, setCheck] = useState<WritingCheck | null>(null);
  const [showModel, setShowModel] = useState(false);
  const [voiceUsed, setVoiceUsed] = useState(false);
  const [listening, setListening] = useState(false);
  const [voiceError, setVoiceError] = useState<string | null>(null);
  const [inputError, setInputError] = useState<string | null>(null);
  const areaRef = useRef<HTMLTextAreaElement>(null);
  const sessionRef = useRef<ListeningSession | null>(null);
  const voiceSupported = useMemo(() => browserSpeech.isSupported(), []);
  const solved = check?.correct === true;
  const finished = solved || showModel;

  useEffect(() => () => sessionRef.current?.abort(), []);

  const insertHint = (word: string) => {
    const el = areaRef.current;
    const start = el?.selectionStart ?? text.length;
    const end = el?.selectionEnd ?? text.length;
    const before = text.slice(0, start);
    const pad = before && !/\s$/.test(before) ? ' ' : '';
    const next = (before + pad + word + ' ' + text.slice(end)).slice(0, MAX_ANSWER);
    setText(next);
    setCheck(null);
    requestAnimationFrame(() => {
      el?.focus();
      const pos = (before + pad + word + ' ').length;
      el?.setSelectionRange(pos, pos);
    });
  };

  const dictate = async () => {
    if (listening) {
      sessionRef.current?.stop();
      return;
    }
    setVoiceError(null);
    setListening(true);
    const session = browserSpeech.transcribe({ lang: lang === 'hr' ? 'hr-HR' : 'uk-UA', maxAlternatives: 1 });
    sessionRef.current = session;
    try {
      const { transcripts } = await session.result;
      const said = transcripts[0]?.trim();
      if (said) {
        setText((t) => (t.trim() ? `${t.trim()} ${said}` : said).slice(0, MAX_ANSWER));
        setVoiceUsed(true);
        setCheck(null);
      } else setVoiceError('Нічого не почули. Спробуйте ще раз або напишіть.');
    } catch (err) {
      const code = err instanceof SpeechError ? err.code : 'other';
      if (code !== 'aborted') setVoiceError('Не вдалося розпізнати мовлення. Напишіть відповідь або спробуйте ще раз.');
    } finally {
      setListening(false);
      sessionRef.current = null;
    }
  };

  const submit = () => {
    if (!text.trim()) {
      setInputError(lang === 'hr' ? 'Напишіть відповідь хорватською.' : 'Напишіть відповідь українською.');
      return;
    }
    const r = checkWriting(task, text);
    if (r.tooShort) {
      setInputError('Напишіть хоча б одне коротке речення.');
      return;
    }
    setInputError(null);
    setCheck(r);
    if (r.correct) onAttempt?.({ text, check: r, outcome: 'correct', inputMode: voiceUsed ? 'voice' : 'typed' });
  };

  const revealModel = () => {
    setShowModel(true);
    if (check && text.trim()) onAttempt?.({ text, check, outcome: 'wrong', inputMode: voiceUsed ? 'voice' : 'typed' });
  };

  const skip = () => {
    sessionRef.current?.abort();
    if (text.trim()) {
      const r = checkWriting(task, text);
      onAttempt?.({ text, check: r, outcome: 'skipped', inputMode: voiceUsed ? 'voice' : 'typed' });
    }
    onNext('skipped');
  };

  return (
    <div className="flex flex-col gap-4">
      {task.type === 'mediation' && task.source_hr && (
        <Card className="text-center">
          <Hr as="p" className="whitespace-pre-line font-heading text-h3 break-words">{task.source_hr}</Hr>
        </Card>
      )}
      {task.type === 'mediation' && task.friend_ua && (
        <div className="flex items-start gap-2">
          <span aria-hidden="true" className="grid size-9 shrink-0 place-items-center rounded-full bg-primary-soft text-label font-semibold text-primary-ink">
            Д
          </span>
          <p className="rounded-card rounded-tl-sm bg-surface-muted px-4 py-3 text-body">
            <span className="sr-only">Друг питає: </span>
            {task.friend_ua}
          </p>
        </div>
      )}

      <section aria-label="Що має бути у відповіді">
        <p className="text-label text-ink-muted">{task.type === 'mediation' ? 'Головне, що треба передати' : 'Має бути в повідомленні'}</p>
        <ul className="mt-1 flex flex-col gap-1">
          {task.points.map((p, i) => {
            const st = check ? (check.points[i]?.done ? 'done' : 'missed') : 'todo';
            const Icon = st === 'done' ? CircleCheck : st === 'missed' ? CircleX : CircleDashed;
            return (
              <li key={p.ua} className={cn('flex items-center gap-2 text-body', st === 'done' && 'text-success-ink', st === 'missed' && 'text-danger-ink')}>
                <Icon className="size-5 shrink-0" aria-hidden="true" />
                <span>
                  {p.ua}
                  {st !== 'todo' && <span className="sr-only">{st === 'done' ? ' — є' : ' — бракує'}</span>}
                </span>
              </li>
            );
          })}
        </ul>
      </section>

      {task.hints.length > 0 && !finished && (
        <section aria-label="Підказки з уроку">
          <p className="text-label text-ink-muted">Підказки з уроку (натисніть, щоб вставити)</p>
          <div className="mt-1 flex flex-wrap gap-2">
            {task.hints.map((h) => (
              <button
                key={h}
                type="button"
                onClick={() => insertHint(h)}
                className="min-h-11 rounded-control border border-line bg-surface px-3 text-body hover:border-primary active:scale-[0.98]"
              >
                <Hr>{h}</Hr>
              </button>
            ))}
          </div>
        </section>
      )}

      <div>
        <label htmlFor="writing-answer" className="text-label text-ink-muted">
          {lang === 'hr' ? 'Ваша відповідь хорватською' : 'Ваша відповідь українською'}
        </label>
        <textarea
          id="writing-answer"
          ref={areaRef}
          lang={lang === 'hr' ? 'hr' : 'uk'}
          value={text}
          readOnly={finished}
          maxLength={MAX_ANSWER}
          rows={3}
          onChange={(e) => {
            setText(e.target.value);
            setInputError(null);
            if (check && !finished) setCheck(null);
          }}
          aria-invalid={inputError ? true : undefined}
          aria-describedby={inputError ? 'writing-error' : undefined}
          className="mt-1 w-full rounded-control border-2 border-line bg-surface px-4 py-3 text-body-lg focus:border-primary focus:outline-none read-only:bg-surface-muted"
          placeholder={lang === 'hr' ? 'Dobar dan, …' : 'У неділю …'}
        />
        {inputError && (
          <p id="writing-error" role="alert" className="mt-1 text-label text-danger-ink">{inputError}</p>
        )}
        {voiceError && <p role="status" className="mt-1 text-label text-ink-muted">{voiceError}</p>}
      </div>

      {check && (
        <div role="status" className={cn('rounded-card px-4 py-3', solved ? 'bg-success-soft text-success-ink' : 'bg-warning-soft text-warning-ink')}>
          <p className="font-semibold">
            {solved
              ? task.type === 'mediation' ? 'Друг усе зрозумів.' : 'Усі пункти є — повідомлення зрозуміле.'
              : `Є ${check.done} з ${check.total}. Допишіть те, чого бракує, і перевірте ще раз.`}
          </p>
          {check.diacritics.length > 0 && (
            <p className="mt-1 text-body">
              Діакритики:{' '}
              {check.diacritics.map((d, i) => (
                <span key={d.written}>
                  {i > 0 && ', '}
                  <Hr className="line-through">{d.written}</Hr> → <Hr className="font-semibold">{d.correct}</Hr>
                </span>
              ))}
            </p>
          )}
        </div>
      )}

      {finished && (
        <Card className="flex flex-col gap-2">
          <p className="text-label text-ink-muted">{task.models.length > 1 ? 'Зразки' : 'Зразок'}</p>
          {task.models.map((m) =>
            lang === 'hr' ? (
              <div key={m} className="flex items-start gap-2">
                <Hr as="p" className="min-w-0 flex-1 text-body-lg italic break-words">{m}</Hr>
                <AudioButton text={m} />
              </div>
            ) : (
              <p key={m} className="text-body-lg italic">{m}</p>
            ),
          )}
        </Card>
      )}

      {finished ? (
        <Button block autoFocus onClick={() => onNext(solved ? 'correct' : 'wrong')}>
          Далі
        </Button>
      ) : (
        <div className="flex flex-col gap-2">
          <Button block onClick={submit}>
            Перевірити
          </Button>
          {voiceSupported && (
            <Button block variant="secondary" onClick={dictate} aria-pressed={listening}>
              {listening ? <Square className="size-4" aria-hidden="true" /> : <Mic className="size-4" aria-hidden="true" />}
              {listening ? 'Зупинити' : 'Сказати вголос'}
            </Button>
          )}
          {check && !solved && (
            <Button block variant="tertiary" onClick={revealModel}>
              <Eye className="size-4" aria-hidden="true" /> Показати зразок
            </Button>
          )}
          <Button block variant="tertiary" onClick={skip}>
            Пропустити
          </Button>
        </div>
      )}
    </div>
  );
}
