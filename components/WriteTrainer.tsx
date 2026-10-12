'use client';

import React, { useEffect, useMemo, useRef, useState } from 'react';
import { speakCroatian } from '@/utils/speech';
import { checkTypedAnswer, maskExample, type AnswerCheck } from '@/lib/answer';

/**
 * VS-001, кроки 5–7: користувач бачить українське слово (і приклад з пропуском),
 * сам вводить хорватське слово і отримує зворотний звʼязок.
 */
export interface WriteCard {
  id: string;
  hr_text: string;
  ua_translation: string;
  phonetic_note?: string;
  example?: string;
}

interface WriteTrainerProps {
  cards: WriteCard[];
  /** correct — чи зараховано відповідь; responseTimeMs — від показу картки до перевірки */
  onAnswer: (card: WriteCard, result: AnswerCheck, responseTimeMs: number) => void;
  onFinishSession: () => void;
}

const CROATIAN_LETTERS = ['č', 'ć', 'đ', 'š', 'ž'];

const VERDICT_TEXT: Record<AnswerCheck['verdict'], string> = {
  exact: 'Правильно! 🎉',
  diacritics: 'Правильно, але зверніть увагу на діакритику',
  typo: 'Майже! Невелика одруківка',
  wrong: 'Поки ні',
  empty: 'Поки ні',
};

export default function WriteTrainer({ cards, onAnswer, onFinishSession }: WriteTrainerProps) {
  const [index, setIndex] = useState(0);
  const [value, setValue] = useState('');
  const [result, setResult] = useState<AnswerCheck | null>(null);
  const [correctCount, setCorrectCount] = useState(0);
  const inputRef = useRef<HTMLInputElement>(null);
  const shownAtRef = useRef(Date.now());

  const card = cards[index];
  const masked = useMemo(
    () => (card?.example ? maskExample(card.example, card.hr_text) : null),
    [card]
  );

  // Нова картка: чисте поле, фокус, старт таймера
  useEffect(() => {
    setValue('');
    setResult(null);
    shownAtRef.current = Date.now();
    inputRef.current?.focus();
  }, [index]);

  if (!card) {
    return (
      <div className="max-w-md mx-auto px-6 pt-16 text-center">
        <div className="bg-white p-10 rounded-[2rem] shadow-xl border border-gray-100">
          <div className="text-6xl mb-6">✍️</div>
          <h2 className="text-2xl font-black text-gray-900 mb-2">Сесію завершено!</h2>
          <p className="text-gray-500 font-medium mb-8">
            Правильно: {correctCount} з {cards.length}
          </p>
          <button
            onClick={onFinishSession}
            className="w-full bg-blue-600 hover:bg-blue-700 text-white font-bold py-4 rounded-2xl shadow-md transition-all active:scale-95"
          >
            Повернутися на головну
          </button>
        </div>
      </div>
    );
  }

  const insertLetter = (letter: string) => {
    const input = inputRef.current;
    if (!input || result) return;
    const start = input.selectionStart ?? value.length;
    const end = input.selectionEnd ?? value.length;
    const next = value.slice(0, start) + letter + value.slice(end);
    setValue(next);
    requestAnimationFrame(() => {
      input.focus();
      input.setSelectionRange(start + 1, start + 1);
    });
  };

  const check = (giveUp = false) => {
    if (result) return;
    const res = giveUp ? { verdict: 'wrong' as const, correct: false, expected: card.hr_text } : checkTypedAnswer(value, card.hr_text);
    if (!giveUp && res.verdict === 'empty') return; // порожнє поле — нічого не робимо
    setResult(res);
    if (res.correct) setCorrectCount((c) => c + 1);
    speakCroatian(card.hr_text);
    onAnswer(card, res, Date.now() - shownAtRef.current);
  };

  const next = () => setIndex((i) => i + 1);

  const progress = Math.round((index / cards.length) * 100);
  const ok = result?.correct;

  return (
    <div className="max-w-md mx-auto px-4 pt-2 pb-10 flex flex-col gap-5">
      {/* Прогрес */}
      <div className="flex items-center gap-3">
        <div className="flex-1 h-3 bg-gray-200 rounded-full overflow-hidden">
          <div className="h-full bg-blue-600 rounded-full transition-all duration-500" style={{ width: `${progress}%` }} />
        </div>
        <span className="text-sm font-bold text-gray-500">{index + 1} / {cards.length}</span>
      </div>

      {/* Завдання */}
      <div className="bg-white rounded-[2rem] shadow-xl border border-gray-100 p-7 text-center">
        <p className="text-xs font-bold text-gray-400 uppercase tracking-widest mb-3">Як це хорватською?</p>
        <h2 className="text-3xl font-black text-gray-900 break-words">{card.ua_translation}</h2>
        {card.phonetic_note && <p className="mt-2 text-sm text-gray-400">{card.phonetic_note}</p>}

        {masked?.found && !result && (
          <p className="mt-5 text-gray-600 italic leading-snug">{masked.text}</p>
        )}

        <form
          className="mt-6"
          onSubmit={(e) => {
            e.preventDefault();
            if (result) next();
            else check();
          }}
        >
          <input
            ref={inputRef}
            value={value}
            onChange={(e) => setValue(e.target.value)}
            readOnly={!!result}
            lang="hr"
            autoCapitalize="none"
            autoComplete="off"
            autoCorrect="off"
            spellCheck={false}
            placeholder="Введіть слово…"
            aria-label="Хорватське слово"
            className={`w-full text-center text-2xl font-bold rounded-2xl border-2 px-4 py-3 outline-none transition-colors ${
              result
                ? ok
                  ? 'border-emerald-400 bg-emerald-50 text-emerald-800'
                  : 'border-rose-400 bg-rose-50 text-rose-800'
                : 'border-gray-200 focus:border-blue-500'
            }`}
          />

          {!result && (
            <div className="mt-3 flex justify-center gap-2" aria-label="Хорватські літери">
              {CROATIAN_LETTERS.map((letter) => (
                <button
                  key={letter}
                  type="button"
                  onClick={() => insertLetter(letter)}
                  className="w-11 h-11 rounded-xl border border-gray-200 bg-gray-50 text-lg font-bold text-gray-700 hover:bg-blue-50 hover:border-blue-300 active:scale-95"
                >
                  {letter}
                </button>
              ))}
            </div>
          )}

          {/* Зворотний звʼязок */}
          {result && (
            <div role="status" className="mt-5 text-left">
              <p className={`font-bold ${ok ? 'text-emerald-700' : 'text-rose-700'}`}>{VERDICT_TEXT[result.verdict]}</p>
              {result.verdict !== 'exact' && (
                <p className="mt-1 text-gray-700">
                  Правильно: <span className="font-black text-gray-900">{result.expected}</span>
                </p>
              )}
              <button
                type="button"
                onClick={() => speakCroatian(card.hr_text)}
                className="mt-3 inline-flex items-center gap-2 text-blue-600 font-semibold hover:text-blue-800"
              >
                🔊 Прослухати
              </button>
              {card.example && (
                <button
                  type="button"
                  onClick={() => speakCroatian(card.example!)}
                  className="mt-3 block text-left text-gray-600 italic hover:text-blue-700"
                >
                  🔊 {card.example}
                </button>
              )}
            </div>
          )}

          <div className="mt-6 flex gap-3">
            {!result ? (
              <>
                <button
                  type="button"
                  onClick={() => check(true)}
                  className="flex-1 py-4 rounded-2xl font-bold text-gray-600 bg-gray-100 hover:bg-gray-200"
                >
                  Не знаю
                </button>
                <button
                  type="submit"
                  disabled={!value.trim()}
                  className="flex-[2] py-4 rounded-2xl font-bold text-white bg-blue-600 hover:bg-blue-700 disabled:opacity-50"
                >
                  Перевірити
                </button>
              </>
            ) : (
              <button type="submit" className="w-full py-4 rounded-2xl font-bold text-white bg-blue-600 hover:bg-blue-700">
                Далі ➔
              </button>
            )}
          </div>
        </form>
      </div>
    </div>
  );
}
