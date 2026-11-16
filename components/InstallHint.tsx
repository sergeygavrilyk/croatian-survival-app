'use client';

import { useEffect, useState, useSyncExternalStore } from 'react';
import { Share, Smartphone } from 'lucide-react';
import Button from '@/components/ui/Button';
import Card from '@/components/ui/Card';
import { track } from '@/lib/analytics-client';
import {
  currentInstallHint,
  promptInstall,
  rememberInstallHint,
  subscribeInstallHint,
} from '@/lib/install-prompt-client';

/**
 * «Сьогодні»: підказка «Додати на початковий екран» (§76, рішення власника 2026-11-16).
 * Android / комп'ютер — кнопка «Встановити» (системне вікно браузера); iPhone — три кроки в Safari.
 * Коли показувати — lib/install-hint.ts (після першого уроку, не встановлено, не відкладено).
 */
export default function InstallHint({ lessonsDone }: { lessonsDone: number }) {
  const kind = useSyncExternalStore(
    subscribeInstallHint,
    () => currentInstallHint(lessonsDone),
    () => null,
  );
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    if (kind) track('install_hint_shown', { kind, source: 'today' });
  }, [kind]);

  if (!kind) return null;

  const later = () => {
    track('install_hint_result', { kind, source: 'today', success: false });
    rememberInstallHint('later');
  };

  const install = async () => {
    setBusy(true);
    const outcome = await promptInstall();
    setBusy(false);
    if (outcome === 'unavailable') return; // браузер передумав — картка сховається сама
    track('install_hint_result', { kind, source: 'today', success: outcome === 'accepted' });
    rememberInstallHint(outcome === 'accepted' ? 'installed' : 'later');
  };

  const done = () => {
    track('install_hint_result', { kind, source: 'today', success: true });
    rememberInstallHint('done');
  };

  return (
    <Card className="flex flex-col gap-4" data-testid="install-hint" aria-labelledby="install-hint-title">
      <div className="flex items-start gap-4">
        <span className="flex size-12 shrink-0 items-center justify-center rounded-card bg-primary-soft text-primary-ink" aria-hidden="true">
          <Smartphone className="size-6" />
        </span>
        <div className="min-w-0">
          <h2 id="install-hint-title" className="font-heading text-h3">
            Додайте застосунок на початковий екран
          </h2>
          <p className="mt-1 text-body text-ink-muted">
            Так уроки, слова й прогрес надійно зберігаються для навчання без інтернету, а застосунок відкривається одним дотиком.
          </p>
        </div>
      </div>

      {kind === 'ios' && <IosSteps />}

      <div className="flex flex-wrap gap-2">
        {kind === 'native' ? (
          <Button onClick={install} loading={busy}>
            Встановити
          </Button>
        ) : (
          <Button variant="secondary" onClick={done}>
            Готово
          </Button>
        )}
        <Button variant="tertiary" onClick={later}>
          Не зараз
        </Button>
      </div>
    </Card>
  );
}

function IosSteps() {
  return (
    <ol className="flex list-decimal flex-col gap-2 pl-5 text-body" aria-label="Як додати на iPhone">
      <li>
        Натисніть{' '}
        <span className="inline-flex items-center gap-1 font-semibold">
          <Share className="size-4" aria-hidden="true" />
          «Поширити»
        </span>{' '}
        — у Safari унизу або вгорі екрана (іноді — у меню «⋯»).
      </li>
      <li>
        Виберіть <span className="font-semibold">«На початковий екран»</span>.
      </li>
      <li>
        Натисніть <span className="font-semibold">«Додати»</span>.
      </li>
    </ol>
  );
}

