/**
 * Нижня навігація: які вкладки є і де вона показується (docs/DESIGN_SYSTEM.md §7).
 * Структура — рішення власника 2026-10-12: Сьогодні · Уроки · Практика · Ситуації · Профіль.
 */
export type TabKey = 'today' | 'lessons' | 'practice' | 'situations' | 'profile';

export const TABS: ReadonlyArray<{ key: TabKey; href: string; label: string }> = [
  { key: 'today', href: '/', label: 'Сьогодні' },
  { key: 'lessons', href: '/lessons', label: 'Уроки' },
  { key: 'practice', href: '/trainer', label: 'Практика' },
  { key: 'situations', href: '/situations', label: 'Ситуації' },
  { key: 'profile', href: '/profile', label: 'Профіль' },
];

function under(path: string, base: string): boolean {
  return path === base || path.startsWith(base + '/');
}

/** Яка вкладка активна для шляху; null — шлях поза вкладками. */
export function activeTab(path: string): TabKey | null {
  if (path === '/') return 'today';
  if (under(path, '/lessons')) return 'lessons';
  if (under(path, '/trainer') || under(path, '/mistakes') || under(path, '/dictionary') || under(path, '/reading')) return 'practice';
  if (under(path, '/situations')) return 'situations';
  if (under(path, '/profile')) return 'profile';
  return null;
}

/**
 * Чи показувати нижню панель. Лише на екранах вкладок; урок (/lesson/…),
 * вхід і адмінка — без неї (повноекранні заняття або окремий розділ).
 */
export function showsBottomNav(path: string): boolean {
  const clean = path.length > 1 ? path.replace(/\/+$/, '') : path;
  // Рольова гра — повноекранне заняття, без нижньої панелі
  if (under(clean, '/situations')) return !clean.endsWith('/roleplay');
  return ['/', '/lessons', '/lessons/tests', '/trainer', '/mistakes', '/mistakes/typical', '/reading', '/dictionary', '/profile'].includes(clean);
}

/** «Практика» → «Помилки»: особисті помилки й каталог типових помилок українців (§19). */
export const MISTAKES_SEGMENTS = [
  { href: '/mistakes', label: 'Мої помилки' },
  { href: '/mistakes/typical', label: 'Типові помилки' },
] as const;
