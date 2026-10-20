'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { BadgeCheck, BookOpen, ChevronRight, KeyRound, Layers, LogOut, Repeat, TrendingUp, type LucideIcon } from 'lucide-react';
import { createClient } from '@/utils/supabase/client';
import Card from '@/components/ui/Card';
import Button from '@/components/ui/Button';
import LevelBadge from '@/components/ui/LevelBadge';
import EmptyState from '@/components/ui/EmptyState';
import { DAILY_GOALS, LEARNING_GOALS } from '@/lib/onboarding';
import { countUk } from '@/lib/format';
import type { ProgressSummary } from '@/lib/progress';
import { levelStyle } from '@/lib/levels';
import { weekCheer } from '@/lib/today';
import { authErrorUk } from '@/lib/auth';
import { cn } from '@/lib/ui';
import MascotPicker from '@/components/MascotPicker';
import { setMascot as saveMascot } from '@/app/actions/mascot';
import { DEFAULT_MASCOT, MASCOTS, storeMascot, type MascotKind } from '@/lib/mascot';

interface ProfileData {
  goals: string[];
  dailyGoalMinutes: number | null;
  currentLevel: string | null;
}

interface PlacementData {
  estimated_cefr: string;
  confidence: string;
  recommended_start: string;
  completed_at: string;
}

const CONFIDENCE_LABEL: Record<string, string> = { high: 'надійна', medium: 'приблизна', low: 'ненадійна' };

/** Профіль: прогрес, рівень і цілі, акаунт (docs/DESIGN_SYSTEM.md §10). */
export default function ProfileView({
  email,
  name,
  summary,
  progressError,
  profile,
  placement,
  mascot: initialMascot,
  mascotAvailable,
}: {
  email: string;
  /** Ім'я для привітання (displayName: з акаунта або частина email) */
  name: string;
  summary: ProgressSummary;
  progressError: boolean;
  profile: ProfileData | null;
  placement: PlacementData | null;
  /** Обраний талісман (null — не обрано) */
  mascot: MascotKind | null;
  /** false — у базі ще немає колонки (міграція M18): вибір не показуємо */
  mascotAvailable: boolean;
}) {
  const router = useRouter();
  const [message, setMessage] = useState<{ ok: boolean; text: string } | null>(null);
  const empty = summary.inLearning === 0 && summary.lessonsCompleted === 0;

  const logout = async () => {
    await createClient().auth.signOut();
    router.push('/login');
    router.refresh();
  };

  const resetPassword = async () => {
    if (!email) return;
    const { error } = await createClient().auth.resetPasswordForEmail(email, {
      redirectTo: `${window.location.origin}/reset-password`,
    });
    setMessage(error ? { ok: false, text: `Не вдалося надіслати лист. ${authErrorUk(error.message)}` } : { ok: true, text: 'Лист для зміни пароля надіслано на вашу пошту.' });
  };

  return (
    <div className="min-h-screen pb-28">
      <header className="mx-auto flex max-w-2xl items-center gap-4 px-5 pt-[calc(2.5rem+env(safe-area-inset-top))] pb-4">
        <span
          className={cn(
            'flex size-16 shrink-0 items-center justify-center rounded-full font-heading text-h1',
            levelStyle(profile?.currentLevel).solid,
          )}
          aria-hidden="true"
        >
          {([...name.trim()][0] ?? '?').toUpperCase()}
        </span>
        <div className="min-w-0">
          <h1 className="font-heading text-h1">Профіль</h1>
          <p className="truncate text-body text-ink-muted">
            <span lang="hr">Bok</span>, {name}! 👋
          </p>
        </div>
      </header>

      <main className="mx-auto flex max-w-2xl flex-col gap-6 px-5">
        {/* ------------------------------------------------ прогрес */}
        <section aria-labelledby="progress-title" className="flex flex-col gap-3">
          <h2 id="progress-title" className="font-heading text-h2">
            Мій прогрес
          </h2>

          {progressError && (
            <p role="alert" className="rounded-card border border-warning-line bg-warning-soft p-4 text-body text-warning-ink">
              Частину даних не вдалося завантажити. Оновіть сторінку.
            </p>
          )}

          {empty ? (
            <Card>
              <EmptyState
                className="py-6"
                icon={<TrendingUp className="size-6" aria-hidden="true" />}
                title="Прогресу ще немає"
                text="Пройдіть перший урок — тут з'являться ваші слова, повторення й активність."
                action={<Button href="/lessons">До уроків</Button>}
              />
            </Card>
          ) : (
            <>
              <div className="grid grid-cols-2 gap-3">
                <StatTile
                  label="Уроків пройдено"
                  value={summary.lessonsCompleted}
                  Icon={BookOpen}
                  iconClassName={cn(levelStyle(profile?.currentLevel).soft, levelStyle(profile?.currentLevel).ink)}
                />
                <StatTile label="Слів у повтореннях" value={summary.inLearning} Icon={Layers} iconClassName="bg-primary-soft text-primary-ink" />
                <StatTile
                  label="Повторити зараз"
                  value={summary.dueNow}
                  Icon={Repeat}
                  iconClassName={summary.dueNow > 0 ? 'bg-primary-soft text-primary-ink' : 'bg-surface-muted text-ink-muted'}
                  action={summary.dueNow > 0 ? { href: '/trainer', label: 'Повторити' } : undefined}
                />
                <StatTile
                  label="Засвоєно надовго"
                  value={summary.longTerm}
                  Icon={BadgeCheck}
                  iconClassName="bg-success-soft text-success-ink"
                  hint="повтор через 3+ тижні"
                />
              </div>

              <ActivityChart summary={summary} />
              {summary.byLevel.length > 0 && <WordsByLevel byLevel={summary.byLevel} total={summary.inLearning} />}
            </>
          )}
        </section>

        {/* ------------------------------------------------ рівень і цілі */}
        <section aria-labelledby="goals-title" className="flex flex-col gap-3">
          <h2 id="goals-title" className="font-heading text-h2">
            Рівень і цілі
          </h2>
          <Card className="flex flex-col gap-4">
            <Row label="Навчаюся з рівня">
              {profile?.currentLevel ? (
                <span className="flex items-center gap-2">
                  <span className={cn('text-label', levelStyle(profile.currentLevel).ink)}>{levelStyle(profile.currentLevel).name}</span>
                  <LevelBadge level={profile.currentLevel} />
                </span>
              ) : (
                <span className="text-ink-muted">не обрано</span>
              )}
            </Row>
            {placement && (
              <Row label="Тест рівня">
                <span className="text-right">
                  <span className="font-semibold">{placement.estimated_cefr}</span>
                  <span className="block text-caption text-ink-subtle">
                    оцінка застосунку, {CONFIDENCE_LABEL[placement.confidence] ?? placement.confidence} ·{' '}
                    {new Date(placement.completed_at).toLocaleDateString('uk-UA')}
                  </span>
                </span>
              </Row>
            )}
            <Row label="Щоденна ціль">
              {profile?.dailyGoalMinutes ? (
                <span className="font-semibold">{DAILY_GOALS.find((d) => d.minutes === profile.dailyGoalMinutes)?.label}</span>
              ) : (
                <span className="text-ink-muted">не обрано</span>
              )}
            </Row>
            <div>
              <p className="text-label font-normal text-ink-muted">Мета</p>
              {profile && profile.goals.length > 0 ? (
                <ul className="mt-2 flex flex-wrap gap-2">
                  {profile.goals.map((g) => (
                    <li key={g} className="rounded-full bg-surface-muted px-3 py-1 text-label">
                      {LEARNING_GOALS.find((x) => x.key === g)?.label ?? g}
                    </li>
                  ))}
                </ul>
              ) : (
                <p className="mt-1 text-body text-ink-muted">не обрано</p>
              )}
            </div>
            <Button variant="secondary" href="/onboarding" block>
              Змінити цілі або пройти тест рівня
            </Button>
          </Card>
        </section>

        {/* ------------------------------------------------ талісман */}
        {mascotAvailable && <MascotSection initial={initialMascot} />}

        {/* ------------------------------------------------ акаунт */}
        <section aria-labelledby="account-title" className="flex flex-col gap-3">
          <h2 id="account-title" className="font-heading text-h2">
            Акаунт
          </h2>
          <Card className="divide-y divide-line p-0">
            <p className="truncate px-5 py-4 text-body">{email}</p>
            <button
              type="button"
              onClick={() => void resetPassword()}
              className="flex min-h-14 w-full items-center gap-3 px-5 text-left text-body hover:bg-surface-muted"
            >
              <KeyRound className="size-5 text-ink-muted" aria-hidden="true" />
              <span className="flex-1">Змінити пароль</span>
              <ChevronRight className="size-5 text-ink-subtle" aria-hidden="true" />
            </button>
            <button
              type="button"
              onClick={() => void logout()}
              className="flex min-h-14 w-full items-center gap-3 rounded-b-card px-5 text-left text-body text-danger-ink hover:bg-danger-soft"
            >
              <LogOut className="size-5" aria-hidden="true" />
              <span className="flex-1">Вийти з акаунту</span>
            </button>
          </Card>
          {message && (
            <p
              role="status"
              className={cn(
                'rounded-card border p-4 text-body',
                message.ok ? 'border-success-line bg-success-soft text-success-ink' : 'border-danger-line bg-danger-soft text-danger-ink',
              )}
            >
              {message.text}
            </p>
          )}
        </section>
      </main>
    </div>
  );
}

// ---------------------------------------------------------------- частини
function StatTile({
  label,
  value,
  hint,
  action,
  Icon,
  iconClassName,
}: {
  label: string;
  value: number;
  hint?: string;
  action?: { href: string; label: string };
  Icon: LucideIcon;
  iconClassName: string;
}) {
  return (
    <Card className="flex flex-col gap-1 p-4">
      <span className={cn('mb-1 flex size-10 items-center justify-center rounded-full', iconClassName)} aria-hidden="true">
        <Icon className="size-5" />
      </span>
      <p className="text-label font-normal text-ink-muted">{label}</p>
      <p className="font-heading text-h1 tabular-nums">{value.toLocaleString('uk-UA')}</p>
      {hint && <p className="text-caption text-ink-subtle">{hint}</p>}
      {action && (
        <Button href={action.href} size="sm" variant="secondary" className="mt-1 self-start">
          {action.label}
        </Button>
      )}
    </Card>
  );
}

/** Талісман: Pjegica, Šime або Točka (рішення власника 2026-10-20). Зберігається одразу, копія — у браузері. */
function MascotSection({ initial }: { initial: MascotKind | null }) {
  const [value, setValue] = useState<MascotKind | null>(initial);
  const [saving, setSaving] = useState(false);
  const [note, setNote] = useState<{ ok: boolean; text: string } | null>(null);

  const choose = async (kind: MascotKind) => {
    if (kind === value || saving) return;
    const prev = value;
    setValue(kind);
    setSaving(true);
    setNote(null);
    const res = await saveMascot(kind);
    setSaving(false);
    if (res.ok) {
      storeMascot(window.localStorage, kind);
      setNote({ ok: true, text: `Готово! Тепер з вами ${MASCOTS[kind].name}.` });
    } else {
      setValue(prev);
      setNote({ ok: false, text: res.error });
    }
  };

  return (
    <section aria-labelledby="mascot-title" className="flex flex-col gap-3">
      <h2 id="mascot-title" className="font-heading text-h2">
        Талісман
      </h2>
      <Card className="flex flex-col gap-3">
        <p className="text-body text-ink-muted">
          Вітає на «Сьогодні» й радіє разом з вами після уроку.{' '}
          {value === null && `Поки що — ${MASCOTS[DEFAULT_MASCOT].name}.`}
        </p>
        <MascotPicker value={value} onChange={(k) => void choose(k)} disabled={saving} />
        {note && (
          <p role={note.ok ? 'status' : 'alert'} className={cn('text-label', note.ok ? 'text-success-ink' : 'text-danger-ink')}>
            {note.text}
          </p>
        )}
      </Card>
    </section>
  );
}

function Row({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div className="flex items-center justify-between gap-4">
      <span className="text-label font-normal text-ink-muted">{label}</span>
      {children}
    </div>
  );
}

/** Навчання за 7 днів (уроки, вправи, повторення, читання): одна серія, стовпці ≤ 24 px, підказка при наведенні / фокусі, таблиця для читачів екрана. */
function ActivityChart({ summary }: { summary: ProgressSummary }) {
  const max = Math.max(1, ...summary.activity.map((d) => d.count));
  const peak = summary.activity.reduce((a, b) => (b.count > a.count ? b : a), summary.activity[0]);
  return (
    <Card>
      <h3 className="font-heading text-h3">Навчання за 7 днів</h3>
      <p className="text-label font-normal text-ink-muted">
        {countUk(summary.reviews7, ['дія', 'дії', 'дій'])} · активних днів: {summary.activeDays} з 7
      </p>
      <p className="mt-1 text-body text-ink-muted">{weekCheer(summary.activeDays)}</p>

      <ul className="mt-4 grid h-36 grid-cols-7 items-end gap-2 border-b border-line" aria-hidden="true">
        {summary.activity.map((d, i) => {
          const isToday = i === summary.activity.length - 1;
          const showLabel = d.count > 0 && (d === peak || isToday);
          return (
            <li key={d.date} className="group relative flex h-full flex-col items-center justify-end">
              {showLabel && <span className="mb-1 text-caption tabular-nums text-ink-muted">{d.count}</span>}
              <span
                className="pointer-events-none absolute -top-7 z-10 hidden whitespace-nowrap rounded-control bg-ink px-2 py-1 text-caption text-white group-hover:block"
                role="tooltip"
              >
                {d.label}: {d.count}
              </span>
              <span
                className={cn('w-full max-w-6 rounded-t-[4px]', d.count > 0 ? 'bg-success' : 'bg-transparent')}
                style={{ height: d.count > 0 ? `${Math.max(6, Math.round((d.count / max) * 100))}%` : 0 }}
              />
            </li>
          );
        })}
      </ul>
      <ul className="mt-2 grid grid-cols-7 gap-2" aria-hidden="true">
        {summary.activity.map((d, i) => (
          <li key={d.date} className={cn('text-center text-caption', i === summary.activity.length - 1 ? 'font-bold text-ink' : 'text-ink-subtle')}>
            {d.label}
          </li>
        ))}
      </ul>

      <table className="sr-only">
        <caption>Навчальні дії за останні 7 днів: уроки, вправи, повторення, читання</caption>
        <thead>
          <tr>
            <th scope="col">День</th>
            <th scope="col">Дій</th>
          </tr>
        </thead>
        <tbody>
          {summary.activity.map((d) => (
            <tr key={d.date}>
              <th scope="row">
                {d.label}, {d.date}
              </th>
              <td>{d.count}</td>
            </tr>
          ))}
        </tbody>
      </table>
    </Card>
  );
}

/** Слова за рівнями CEFR: горизонтальні смуги однієї серії, значення біля кінця смуги. */
function WordsByLevel({ byLevel, total }: { byLevel: ProgressSummary['byLevel']; total: number }) {
  const max = Math.max(1, ...byLevel.map((l) => l.count));
  return (
    <Card>
      <h3 className="font-heading text-h3">Слова за рівнями</h3>
      <p className="text-label font-normal text-ink-muted">{countUk(total, ['слово', 'слова', 'слів'])} у повтореннях</p>
      <ul className="mt-4 flex flex-col gap-3">
        {byLevel.map((l) => (
          <li key={l.level} className="flex items-center gap-3">
            <LevelBadge level={l.level} className="w-10 justify-center" />
            <span className="flex flex-1 items-center gap-2">
              <span
                className={cn('h-3 rounded-r-[4px]', levelStyle(l.level).bar)}
                style={{ width: `${Math.max(2, (l.count / max) * 85)}%` }}
                aria-hidden="true"
              />
              <span className="text-label tabular-nums">{l.count}</span>
            </span>
          </li>
        ))}
      </ul>
    </Card>
  );
}
