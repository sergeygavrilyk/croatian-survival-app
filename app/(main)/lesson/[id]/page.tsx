'use client';

import { useCallback, useEffect, useRef, useState } from 'react';
import { useParams } from 'next/navigation';
import { createClient } from '@/utils/supabase/client';
import LessonPlayer, {
  type DialogueLine, type GrammarTopic, type LessonContent, type LessonDialogue, type LessonInfo, type LessonWord,
} from '@/components/lesson/LessonPlayer';
import type { LessonExerciseData } from '@/components/lesson/LessonExercise';
import ErrorState from '@/components/ui/ErrorState';
import { completeLesson } from '@/app/actions/progress';
import { track, getSessionId } from '@/lib/analytics-client';
import { examplesFrom, lessonPitfalls, type TypicalError } from '@/lib/interference';

// Кеш уроку в браузері: версія змінюється, коли змінюється формат даних
const LESSON_CACHE_VERSION = 'v13'; // v13: модуль A0.10 «Survival» за темою (curriculum_a0_v4_m10); v12: модуль A0.9 «Grad» за темою (curriculum_a0_v4_m09); v11: модулі A0.7 «Hrana» і A0.8 «Kupovina» за темою (curriculum_a0_v4_m07, _m08); v10: модулі A0.5 «Obitelj» і A0.6 «Moj dom» за темою (curriculum_a0_v4_m05, _m06); v9: модуль A0.4 «Vrijeme» за темою, погода й свята (curriculum_a0_v4_m04); v8: модуль A0.3 «Brojevi» за темою, номери уроків (curriculum_a0_v4_m03); v7: модуль A0.2 за темою, нові уроки й номери (curriculum_a0_v4_m02); v6: імена в діалогах A0.1 (Даша); v5: уроки A0 за темою (curriculum_a0_v4); v4: типові помилки (pitfalls)
const LESSON_CACHE_TTL_MS = 12 * 60 * 60 * 1000; // 12 годин

type CachedLesson = LessonContent & { cachedAt: number };

/** Зберегти порядок елементів уроку (lesson_items.order_index), а не порядок відповіді бази. */
function inOrder<T extends { id: string }>(ids: string[], rows: T[] | null): T[] {
  const byId = new Map((rows ?? []).map((r) => [r.id, r]));
  return ids.map((id) => byId.get(id)).filter((r): r is T => r !== undefined);
}

function stringList(v: unknown): string[] | null {
  return Array.isArray(v) ? v.filter((x): x is string => typeof x === 'string' && x.trim() !== '') : null;
}

export default function LessonPage() {
  const params = useParams();
  const lessonId = params.id as string;

  const [content, setContent] = useState<LessonContent | null>(null);
  const [loading, setLoading] = useState(true);
  const [failed, setFailed] = useState(false);
  const [attempt, setAttempt] = useState(0);
  const startedAtRef = useRef<number>(Date.now());
  const startTrackedRef = useRef(false);

  useEffect(() => {
    let cancelled = false;
    const supabase = createClient();
    const cacheKey = `cs_lesson_data_${LESSON_CACHE_VERSION}_${lessonId}`;

    async function load() {
      let stale: CachedLesson | null = null;
      // 1. Локальний кеш: свіжий — показуємо одразу; застарілий — лише якщо немає інтернету (§76)
      try {
        const cached = localStorage.getItem(cacheKey);
        if (cached) {
          const parsed = JSON.parse(cached) as CachedLesson;
          if (Date.now() - (parsed.cachedAt ?? 0) < LESSON_CACHE_TTL_MS) return parsed;
          stale = parsed;
        }
      } catch {
        // пошкоджений кеш або недоступне сховище — завантажуємо з сервера
      }

      try {
        const { data: lessonRow, error: lessonError } = await supabase
          .from('lessons')
          .select('id, title_ua, title_hr, level_code, objectives, estimated_minutes')
          .eq('id', lessonId)
          .eq('status', 'PUBLISHED')
          .single();
        if (lessonError) throw lessonError;

        const { data: items, error: itemsError } = await supabase
          .from('lesson_items')
          .select('item_type, item_id, order_index')
          .eq('lesson_id', lessonId)
          .order('order_index', { ascending: true });
        if (itemsError) throw itemsError;

        type Item = { item_type: string; item_id: string };
        const idsOf = (type: string) => ((items ?? []) as Item[]).filter((i) => i.item_type === type).map((i) => i.item_id);
        const lexemeIds = idsOf('lexeme');
        const exerciseIds = idsOf('exercise');
        const grammarIds = idsOf('grammar');

        const [lexemesRes, exercisesRes, conversationsRes, grammarRes] = await Promise.all([
          lexemeIds.length
            ? supabase.from('lexemes').select('id, lemma, ukrainian_translation').in('id', lexemeIds).eq('status', 'PUBLISHED')
            : Promise.resolve({ data: [], error: null }),
          exerciseIds.length
            ? supabase
                .from('exercises')
                .select('id, exercise_type, question_text, correct_answer, options')
                .in('id', exerciseIds)
                .eq('status', 'PUBLISHED')
            : Promise.resolve({ data: [], error: null }),
          supabase
            .from('conversations')
            .select('id, title_ua, title_hr, situation, order_index')
            .eq('lesson_id', lessonId)
            .eq('status', 'PUBLISHED')
            .order('order_index', { ascending: true }),
          grammarIds.length
            ? supabase
                .from('grammar_topics')
                .select('id, title_ua, title_hr, description, rules:grammar_rules(id, title_ua, explanation_ua, pattern_hr, examples, order_index)')
                .in('id', grammarIds)
                .eq('status', 'PUBLISHED')
            : Promise.resolve({ data: [], error: null }),
        ]);
        for (const r of [lexemesRes, exercisesRes, conversationsRes, grammarRes]) if (r.error) throw r.error;

        const conversations = (conversationsRes.data ?? []) as Array<{ id: string; title_ua: string | null; title_hr: string | null; situation: string | null }>;
        let turns: Array<DialogueLine & { conversation_id: string }> = [];
        if (conversations.length) {
          const { data, error } = await supabase
            .from('conversation_turns')
            .select('id, conversation_id, speaker_name, hr_text, ua_translation, order_index')
            .in('conversation_id', conversations.map((c) => c.id))
            .order('order_index', { ascending: true });
          if (error) throw error;
          turns = (data ?? []) as typeof turns;
        }

        const lesson: LessonInfo = {
          id: lessonRow.id,
          title_ua: lessonRow.title_ua ?? 'Урок',
          title_hr: lessonRow.title_hr ?? null,
          level_code: lessonRow.level_code ?? null,
          objectives: stringList(lessonRow.objectives),
          estimated_minutes: typeof lessonRow.estimated_minutes === 'number' ? lessonRow.estimated_minutes : null,
        };
        const words: LessonWord[] = inOrder(
          lexemeIds,
          (lexemesRes.data ?? []).map((l: { id: string; lemma: string; ukrainian_translation: string | null }) => ({
            id: l.id,
            hr_text: l.lemma,
            ua_translation: l.ukrainian_translation ?? '',
          })),
        );
        const dialogues: LessonDialogue[] = conversations
          .map((c) => ({
            id: c.id,
            title_ua: c.title_ua,
            title_hr: c.title_hr,
            situation: c.situation,
            lines: turns.filter((t) => t.conversation_id === c.id),
          }))
          .filter((d) => d.lines.length > 0);
        const grammar = inOrder(
          grammarIds,
          ((grammarRes.data ?? []) as GrammarTopic[]).map((topic) => ({
            ...topic,
            rules: [...(topic.rules ?? [])].sort(
              (a, b) => ((a as { order_index?: number }).order_index ?? 0) - ((b as { order_index?: number }).order_index ?? 0),
            ),
          })),
        );
        const exercises = inOrder(exerciseIds, (exercisesRes.data ?? []) as LessonExerciseData[]);

        // Типові помилки українців для теми й слів уроку (§19). Необов'язково: збій не ламає урок.
        let pitfalls: TypicalError[] = [];
        if (grammarIds.length || lexemeIds.length) {
          const filters = [
            grammarIds.length ? `grammar_topic_id.in.(${grammarIds.join(',')})` : null,
            lexemeIds.length ? `lexeme_id.in.(${lexemeIds.join(',')})` : null,
          ].filter(Boolean).join(',');
          const { data, error } = await supabase
            .from('linguistic_errors')
            .select('id, code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id')
            .eq('status', 'PUBLISHED')
            .or(filters);
          if (error) console.warn('Типові помилки не завантажились:', error.message);
          const rows = ((data ?? []) as Array<Omit<TypicalError, 'examples'> & { examples: unknown }>).map((r) => ({
            ...r,
            examples: examplesFrom(r.examples),
          }));
          pitfalls = lessonPitfalls(rows, grammarIds, lexemeIds, 2);
        }

        const fresh: CachedLesson = { lesson, words, dialogues, grammar, exercises, pitfalls, cachedAt: Date.now() };
        try {
          localStorage.setItem(cacheKey, JSON.stringify(fresh));
        } catch {
          // сховище переповнене або недоступне — урок працює і без кешу
        }
        return fresh;
      } catch (err) {
        console.error('Помилка завантаження уроку:', err);
        // Немає інтернету — показуємо останню збережену версію уроку (офлайн, §76)
        return stale;
      }
    }

    void load().then((data) => {
      if (cancelled) return;
      setContent(data);
      setFailed(data === null);
      setLoading(false);
    });
    return () => {
      cancelled = true;
    };
  }, [lessonId, attempt]);

  // Аналітика: урок відкрито (один раз, коли дані завантажились)
  useEffect(() => {
    if (!content || startTrackedRef.current) return;
    startTrackedRef.current = true;
    startedAtRef.current = Date.now();
    track('lesson_started', { lesson_id: lessonId, level: content.lesson.level_code ?? undefined });
  }, [content, lessonId]);

  // Завершення уроку: прогрес уроку + слова уроку в повторення (SRS). Помилку показує екран підсумку.
  const handleComplete = useCallback(async () => {
    await completeLesson(lessonId, {
      session_id: getSessionId(),
      duration_ms: Date.now() - startedAtRef.current,
      level: content?.lesson.level_code ?? undefined,
    });
  }, [lessonId, content]);

  if (loading) {
    return (
      <div className="flex min-h-screen flex-col items-center justify-center gap-4" role="status">
        <div className="size-10 rounded-full border-4 border-primary-soft border-t-primary animate-spin" aria-hidden="true" />
        <p className="text-body text-ink-muted">Завантаження уроку…</p>
      </div>
    );
  }

  if (failed || !content) {
    return (
      <div className="mx-auto flex min-h-screen max-w-md flex-col justify-center px-4">
        <ErrorState
          title="Не вдалося відкрити урок"
          text="Перевірте інтернет і спробуйте ще раз. Уроки, які ви вже відкривали, доступні й офлайн."
          onRetry={() => {
            setLoading(true);
            setAttempt((a) => a + 1);
          }}
        />
      </div>
    );
  }

  return <LessonPlayer content={content} onComplete={handleComplete} />;
}
