import Link from 'next/link';
import { BookOpenText, ChevronRight, CircleCheck } from 'lucide-react';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import EmptyState from '@/components/ui/EmptyState';
import ProgressBar from '@/components/ui/ProgressBar';
import { levelStyle, moduleIcon } from '@/lib/levels';
import { knownLabel, levelIntro, moduleHeading, readingMinutes, textTypeIcon, textTypeLabel } from '@/lib/reading';
import { cn } from '@/lib/ui';

export interface ReadingListItem {
  id: string;
  code: string;
  text_type: string;
  module_order: number | null;
  title_ua: string;
  title_hr: string;
  word_count: number;
  known_ratio: number | null;
}

export interface ReadingModule {
  order: number;
  title_ua: string;
}

/**
 * Список текстів для читання (§6) одного рівня, згрупований за модулями (A0, A1 — що читати після якого модуля)
 * або темами (A2). Прочитане позначено іконкою й текстом (не лише кольором, §98).
 */
export default function ReadingListView({
  level = 'A1',
  items,
  modules,
  progress,
}: {
  level?: string;
  items: ReadingListItem[];
  modules: ReadingModule[];
  /** id тексту → правильних відповідей / питань */
  progress: Record<string, { correct: number; total: number }>;
}) {
  if (items.length === 0) {
    return (
      <EmptyState
        icon={<BookOpenText className="size-6" aria-hidden="true" />}
        title={`Текстів ${level} поки немає`}
        text="Тут з’являться короткі тексти: вивіски, повідомлення, оголошення, меню, листи й історії — з перекладом кожного слова."
      />
    );
  }
  const readCount = items.filter((t) => progress[t.id]).length;
  const groups = new Map<number, ReadingListItem[]>();
  for (const t of items) {
    const key = t.module_order ?? 0;
    groups.set(key, [...(groups.get(key) ?? []), t]);
  }
  const heading = (order: number) => moduleHeading(level, order, modules.find((m) => m.order === order)?.title_ua);
  const lv = levelStyle(level);
  const allRead = readCount === items.length;

  return (
    <div className="flex flex-col gap-6">
      <div className="flex flex-col gap-3">
        <p className="text-body text-ink-muted">{levelIntro(level)}</p>
        <div className="flex flex-col gap-1.5">
          <ProgressBar value={readCount} max={items.length} label={`Прочитано текстів ${level}`} barClassName={lv.bar} />
          <p className={cn('text-caption', allRead ? 'text-success-ink' : 'text-ink-subtle')}>
            Прочитано {readCount} з {items.length}
            {allRead ? ' — усі тексти рівня! 🎉' : ''}
          </p>
        </div>
      </div>
      {[...groups.entries()]
        .sort(([a], [b]) => a - b)
        .map(([order, list]) => (
          <section key={order} className="flex flex-col gap-2" aria-labelledby={`reading-module-${order}`}>
            <h2 id={`reading-module-${order}`} className={cn('flex items-center gap-2 text-label', lv.ink)}>
              {order > 0 && <span aria-hidden="true">{moduleIcon(level, order)}</span>}
              {heading(order)}
            </h2>
            {list.map((t) => {
              const done = progress[t.id];
              const known = knownLabel(t.known_ratio);
              return (
                <Link key={t.id} href={`/reading/${t.id}`} className="block rounded-card focus-visible:outline-2 focus-visible:outline-primary">
                  <Card className="flex items-center gap-3 p-4 transition-colors duration-150 hover:border-primary">
                    <span
                      className={cn('flex size-12 shrink-0 items-center justify-center rounded-card text-2xl leading-none', lv.soft)}
                      aria-hidden="true"
                    >
                      {textTypeIcon(t.text_type)}
                    </span>
                    <div className="min-w-0 flex-1">
                      <p className="text-caption text-ink-muted">
                        {textTypeLabel(t.text_type)} · {readingMinutes(t.word_count)} хв{known ? ` · ${known}` : ''}
                      </p>
                      <p className="font-heading text-body-lg">{t.title_ua}</p>
                      <Hr as="p" className="text-label font-normal text-ink-muted">
                        {t.title_hr}
                      </Hr>
                    </div>
                    {done ? (
                      <span className="flex shrink-0 items-center gap-1 text-label text-success-ink">
                        <CircleCheck className="size-5" aria-hidden="true" />
                        <span>
                          {done.correct}/{done.total}
                          <span className="sr-only"> — прочитано</span>
                        </span>
                      </span>
                    ) : (
                      <ChevronRight className="size-5 shrink-0 text-ink-subtle" aria-hidden="true" />
                    )}
                  </Card>
                </Link>
              );
            })}
          </section>
        ))}
    </div>
  );
}
