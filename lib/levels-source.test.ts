/**
 * Запобіжник ARCH-03 (2026-11-14): список рівнів живе лише в lib/levels.ts (LEVEL_CODES).
 * Раніше переліки рівнів були зашиті в багатьох файлах і застарівали: «Сьогодні» й «Перевірки» не бачили A2.
 * Тест падає, якщо в коді застосунку з'являється новий перелік рівнів: масив ['A0', 'A1'…], тип 'A0' | 'A1',
 * кілька порівнянь з рівнями в одному рядку (level === 'A0' || level === 'A1') чи регулярний вираз (a0|a1…).
 * Що робити замість: LEVEL_CODES, levelsPresent() (рівні з опублікованого контенту), levelRank(), isLevelAtMost(),
 * nextLevelCode() / previousLevelCode(). Дані за рівнями (Record<'A0', …> з кольорами, іконками, модулями мети) — дозволені.
 */
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readdirSync, readFileSync, statSync } from 'node:fs';
import { join, relative } from 'node:path';

const ROOT = join(import.meta.dirname, '..');
const DIRS = ['app', 'lib', 'components', 'utils'];
const ALLOWED = new Set(['lib/levels.ts']);

const LV = '(?:A0|A1|A2|B1|B2)';
const Q = `['"\`]`;
const RULES: ReadonlyArray<[string, RegExp]> = [
  ['масив рівнів', new RegExp(`\\[\\s*${Q}${LV}${Q}\\s*,\\s*${Q}${LV}${Q}`)],
  ['тип-перелік рівнів', new RegExp(`${Q}${LV}${Q}\\s*\\|\\s*${Q}${LV}${Q}`)],
  ['кілька порівнянь з рівнями', new RegExp(`[!=]==\\s*${Q}${LV}${Q}.*[!=]==\\s*${Q}${LV}${Q}`)],
  ['регулярний вираз з рівнями', /\((?:a0|A0)\|(?:a1|A1)/],
];

function sourceFiles(dir: string): string[] {
  const out: string[] = [];
  for (const name of readdirSync(dir)) {
    if (name === 'node_modules' || name.startsWith('.')) continue;
    const path = join(dir, name);
    if (statSync(path).isDirectory()) out.push(...sourceFiles(path));
    else if (/\.(ts|tsx)$/.test(name) && !/\.test\.ts$/.test(name)) out.push(path);
  }
  return out;
}

test('ARCH-03: рівні перелічені лише в lib/levels.ts', () => {
  const found: string[] = [];
  const files = DIRS.flatMap((d) => sourceFiles(join(ROOT, d)));
  assert.ok(files.length > 50, 'тест має бачити код застосунку');
  for (const file of files) {
    const rel = relative(ROOT, file).split('\\').join('/');
    if (ALLOWED.has(rel)) continue;
    readFileSync(file, 'utf8')
      .split(/\r?\n/)
      .forEach((line, i) => {
        for (const [what, re] of RULES) if (re.test(line)) found.push(`${rel}:${i + 1} — ${what}: ${line.trim()}`);
      });
  }
  assert.deepEqual(found, [], `Новий перелік рівнів поза lib/levels.ts — візьміть LEVEL_CODES або рівні з бази:\n${found.join('\n')}`);
});

test('ARCH-03: правила запобіжника ловлять старі переліки', () => {
  const caught = (line: string) => RULES.some(([, re]) => re.test(line));
  assert.ok(caught("const LESSON_LEVELS = ['A0', 'A1'];"));
  assert.ok(caught("export const READING_LEVELS = ['A0', 'A1', 'A2'] as const;"));
  assert.ok(caught("export type GoalLevel = 'A0' | 'A1';"));
  assert.ok(caught("if (level !== 'A0' && level !== 'A1') return [];"));
  assert.ok(caught('const SLUG_RE = /^(a0|a1|a2|b1|b2)-(m\\d{2}|mid|final)$/;'));
  assert.ok(!caught("const MID_LAST_MODULE = { A0: 5, A1: 6, A2: 7 };"));
  assert.ok(!caught("if (kind === 'final') return '🏆';"));
});
