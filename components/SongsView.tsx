'use client';

import { useState } from 'react';
import { ChevronDown, ExternalLink, Music } from 'lucide-react';
import Card from '@/components/ui/Card';
import Hr from '@/components/ui/Hr';
import AudioButton from '@/components/ui/AudioButton';
import PageHeader from '@/components/ui/PageHeader';
import { listenUrl, type Song } from '@/lib/songs';
import { cn } from '@/lib/ui';

/**
 * «Ситуації» → «Пісні»: картка пісні — назва (хорв.) і переклад, виконавець, про що пісня, ключові слова з 🔊,
 * текст (лише суспільне надбання) і «Послухати» на YouTube.
 */
export default function SongsView({ songs }: { songs: readonly Song[] }) {
  const [open, setOpen] = useState<string | null>(songs[0]?.slug ?? null);

  return (
    <div className="min-h-screen pb-28">
      <PageHeader title="Пісні" backHref="/situations" />
      <main className="mx-auto flex max-w-2xl flex-col gap-3 px-4 py-4">
        <p className="text-body text-ink-muted">
          Пісні, які ви почуєте на днях народження, фештах і матчах. Слова з назви й теми — з перекладом і 🔊.
        </p>
        {songs.map((s) => {
          const expanded = open === s.slug;
          return (
            <Card key={s.slug} className="flex flex-col gap-3">
              <button
                type="button"
                onClick={() => setOpen(expanded ? null : s.slug)}
                aria-expanded={expanded}
                className="flex min-h-11 items-start gap-3 text-left"
              >
                <span className="flex size-10 shrink-0 items-center justify-center rounded-full bg-primary-soft text-primary-ink">
                  <Music className="size-5" aria-hidden="true" />
                </span>
                <span className="min-w-0 flex-1">
                  <Hr as="span" className="block font-heading text-h3 break-words">{s.title}</Hr>
                  <span className="block text-label font-normal text-ink-muted">{s.title_ua}</span>
                  <span className="block text-caption text-ink-subtle break-words">{s.performer}</span>
                </span>
                <ChevronDown className={cn('mt-2 size-5 shrink-0 text-ink-subtle transition-transform', expanded && 'rotate-180')} aria-hidden="true" />
              </button>

              {expanded && (
                <div className="flex flex-col gap-3">
                  <p className="text-body">{s.about}</p>
                  <p className="text-caption text-ink-subtle">{s.origin}</p>

                  <div>
                    <h3 className="mb-1 text-label text-ink-muted">Слова</h3>
                    <ul className="flex flex-col divide-y divide-line">
                      {s.words.map((w) => (
                        <li key={w.hr} className="flex items-center gap-2 py-1.5">
                          <Hr className="min-w-0 flex-1 text-body font-semibold break-words">{w.hr}</Hr>
                          <span className="min-w-0 flex-1 text-body text-ink-muted break-words">{w.ua}</span>
                          <AudioButton text={w.hr.replace(/\s*\(.*\)$/, '')} label={`Прослухати «${w.hr}»`} />
                        </li>
                      ))}
                    </ul>
                  </div>

                  {s.lyrics && (
                    <div className="rounded-card border border-line bg-surface-muted p-3">
                      <div className="mb-1 flex items-center justify-between gap-2">
                        <h3 className="text-label text-ink-muted">Текст</h3>
                        <AudioButton text={s.lyrics.map((l) => l.hr).join(' ')} label="Прослухати текст" />
                      </div>
                      <ol className="flex flex-col gap-1.5">
                        {s.lyrics.map((l, i) => (
                          <li key={i}>
                            <Hr as="p" className="text-body-lg">{l.hr}</Hr>
                            <p className="text-label font-normal text-ink-muted">{l.ua}</p>
                          </li>
                        ))}
                      </ol>
                    </div>
                  )}

                  <a
                    href={listenUrl(s)}
                    target="_blank"
                    rel="noopener noreferrer"
                    className="flex min-h-11 items-center justify-center gap-2 rounded-control border border-line bg-surface px-4 text-body font-semibold text-primary hover:border-primary"
                  >
                    Послухати на YouTube
                    <ExternalLink className="size-4" aria-hidden="true" />
                  </a>
                  {!s.lyrics && (
                    <p className="text-caption text-ink-subtle">Текст пісні захищено авторським правом — слухайте й читайте його в офіційних джерелах.</p>
                  )}
                </div>
              )}
            </Card>
          );
        })}
      </main>
    </div>
  );
}
