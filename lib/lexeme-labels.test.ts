// Мітки живої лексики (lib/lexeme-labels.ts). Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  DEFAULT_LABELS, REGIONS, REGION_LABELS, REGISTERS, REGISTER_LABELS, USAGE_TAGS, USAGE_TAG_LABELS, toggleTag, validateLabels,
  WORD_CATEGORIES, adultContentFrom, categoryFilter, emptyCategoryText, isVisibleWord, isWordCategory, labelChips, labelsAriaText, matchesCategory, readLabels,
  type LexemeLabels,
} from './lexeme-labels.ts';

test('Мітки: переліки як у CHECK M24 (6 регістрів, 9 регіонів з великої літери, 11 ознак), у кожного — підпис', () => {
  assert.deepEqual([...REGISTERS], ['standard', 'formal', 'informal', 'colloquial', 'slang', 'vulgar']);
  assert.equal(REGIONS.length, 9);
  assert.equal(REGIONS[0], 'general');
  for (const r of REGIONS.slice(1)) assert.match(r, /^[A-Z][a-z]+$/);
  assert.equal(USAGE_TAGS.length, 11);
  assert.ok(USAGE_TAGS.includes('offensive') && USAGE_TAGS.includes('kajkavian'));
  for (const r of REGISTERS) assert.ok(REGISTER_LABELS[r]);
  for (const r of REGIONS) assert.ok(REGION_LABELS[r]);
  for (const t of USAGE_TAGS) assert.ok(USAGE_TAG_LABELS[t]);
});

test('Мітки: звичайне слово — standard / general / [] і проходить перевірку', () => {
  assert.deepEqual(DEFAULT_LABELS, { register: 'standard', regionality: 'general', usage_tags: [] });
  assert.deepEqual(validateLabels(DEFAULT_LABELS), []);
  assert.deepEqual(validateLabels({ register: 'slang', regionality: 'Zagreb', usage_tags: ['youth_slang', 'anglicism'] }), []);
});

test('Мітки: без значення чи з невідомим значенням — помилка', () => {
  assert.equal(validateLabels({}).length, 3);
  assert.equal(validateLabels({ register: '', regionality: 'general', usage_tags: [] }).length, 1);
  assert.equal(validateLabels({ register: 'regional', regionality: 'general', usage_tags: [] }).length, 1); // старе значення
  assert.equal(validateLabels({ register: 'standard', regionality: 'dalmatia', usage_tags: [] }).length, 1); // з малої літери
  assert.equal(validateLabels({ register: 'standard', regionality: 'general', usage_tags: null }).length, 1);
  assert.equal(validateLabels({ register: 'standard', regionality: 'general', usage_tags: ['regionalism'] }).length, 1);
  assert.equal(validateLabels({ register: 'standard', regionality: 'general', usage_tags: ['idiom', 'idiom'] }).length, 1);
});

test('Мітки: toggleTag вмикає й вимикає ознаку, без повторів, у порядку переліку', () => {
  assert.deepEqual(toggleTag([], 'anglicism'), ['anglicism']);
  assert.deepEqual(toggleTag(['anglicism'], 'youth_slang'), ['youth_slang', 'anglicism']);
  assert.deepEqual(toggleTag(['youth_slang', 'anglicism'], 'anglicism'), ['youth_slang']);
});

test('Позначка: звичайне слово — без чипів; сленг, регіон і ознаки — чипи в порядку «регістр · регіон · ознаки»', () => {
  assert.deepEqual(labelChips(DEFAULT_LABELS), []);
  const chips = labelChips({ register: 'colloquial', regionality: 'Dalmatia', usage_tags: ['italianism'] });
  assert.deepEqual(chips.map((c) => c.text), ['розмовне', 'регіонально · Далмація', 'італізм']);
  assert.ok(chips.every((c) => c.tone === 'neutral'));
  assert.equal(labelsAriaText(chips), 'Категорія: розмовне, регіонально · Далмація, італізм');
  assert.equal(labelsAriaText([]), '');
  // «образа» й «грубо» — тон уваги, текст лишається (стан не лише кольором, §98)
  const rude = labelChips({ register: 'vulgar', regionality: 'general', usage_tags: ['offensive'] });
  assert.deepEqual(rude.map((c) => [c.text, c.tone]), [['грубо (18+)', 'warning'], ['образа', 'warning']]);
  // ключі унікальні (React key)
  const all = labelChips({ register: 'slang', regionality: 'Zagreb', usage_tags: [...USAGE_TAGS] });
  assert.equal(new Set(all.map((c) => c.key)).size, all.length);
  assert.equal(all.length, 2 + USAGE_TAGS.length);
});

test('Позначка: мітки з бази — невідомі значення не показуємо сирими', () => {
  assert.deepEqual(readLabels({ register: 'slang', regionality: 'Zagreb', usage_tags: ['idiom', 'anglicism'] }), {
    register: 'slang', regionality: 'Zagreb', usage_tags: ['anglicism', 'idiom'], // порядок переліку
  });
  assert.deepEqual(readLabels({}), DEFAULT_LABELS);
  assert.deepEqual(readLabels({ register: 'regional', regionality: 'dalmatia', usage_tags: ['regionalism', 'kajkavian'] }), {
    register: 'standard', regionality: 'general', usage_tags: ['kajkavian'],
  });
  assert.deepEqual(readLabels({ register: null, regionality: null, usage_tags: null }), DEFAULT_LABELS);
});

test('Фільтр «Категорія»: «Усі» першою, id унікальні, у кожної категорії — умова запиту', () => {
  assert.equal(WORD_CATEGORIES[0].id, 'all');
  assert.equal(new Set(WORD_CATEGORIES.map((c) => c.id)).size, WORD_CATEGORIES.length);
  assert.equal(categoryFilter('all'), null);
  for (const c of WORD_CATEGORIES.slice(1)) assert.ok(categoryFilter(c.id), c.id);
  assert.ok(isWordCategory('slang') && !isWordCategory('vulgar') && !isWordCategory(undefined));
  assert.deepEqual(categoryFilter('regional'), { method: 'neq', column: 'regionality', value: 'general' });
  assert.deepEqual(categoryFilter('loanword'), { method: 'overlaps', column: 'usage_tags', value: ['anglicism', 'italianism', 'germanism', 'turkism'] });
  const slang = categoryFilter('slang');
  assert.equal(slang?.method, 'or');
  // значення умов — лише з переліків M24 (інакше запит ніколи нічого не знайде)
  for (const c of WORD_CATEGORIES) {
    const f = categoryFilter(c.id);
    if (!f) continue;
    if (f.method === 'eq' || f.method === 'neq') assert.ok((f.column === 'register' ? REGISTERS : REGIONS).includes(f.value as never), c.id);
    if (f.method === 'overlaps' || f.method === 'contains') for (const t of f.value) assert.ok(USAGE_TAGS.includes(t), `${c.id}: ${t}`);
    if (f.method === 'or') for (const t of f.value.match(/\{(.*)\}/)![1].split(',')) assert.ok(USAGE_TAGS.includes(t as never), t);
  }
  assert.match(emptyCategoryText('idiom'), /«Ідіоми»/);
});

test('Фільтр «Категорія»: які слова потрапляють у категорію', () => {
  const w = (register: LexemeLabels['register'], regionality: LexemeLabels['regionality'], usage_tags: LexemeLabels['usage_tags'] = []) =>
    ({ register, regionality, usage_tags }) as LexemeLabels;
  const pomidor = w('colloquial', 'Dalmatia', ['italianism']);
  assert.ok(matchesCategory(pomidor, 'colloquial') && matchesCategory(pomidor, 'regional') && matchesCategory(pomidor, 'loanword'));
  assert.ok(!matchesCategory(pomidor, 'informal') && !matchesCategory(pomidor, 'slang') && !matchesCategory(pomidor, 'idiom'));
  assert.ok(matchesCategory(w('colloquial', 'general', ['youth_slang']), 'slang')); // молодіжний сленг — у «Сленгу»
  assert.ok(matchesCategory(w('slang', 'general'), 'slang'));
  assert.ok(matchesCategory(w('standard', 'general', ['chakavian']), 'dialect'));
  assert.ok(matchesCategory(w('colloquial', 'general', ['offensive']), 'offensive'));
  assert.ok(!matchesCategory(DEFAULT_LABELS, 'regional'));
  for (const c of WORD_CATEGORIES) assert.equal(matchesCategory(DEFAULT_LABELS, c.id), c.id === 'all', c.id);
});

test('Контент 18+: vulgar — лише з увімкненим перемикачем; «образа» видно всім', () => {
  assert.ok(!isVisibleWord(w18('vulgar')));
  assert.ok(isVisibleWord(w18('vulgar'), true));
  assert.ok(isVisibleWord({ register: 'colloquial', regionality: 'general', usage_tags: ['offensive'] }));
  assert.ok(isVisibleWord(DEFAULT_LABELS));
});

test('Перемикач 18+ (profiles.adult_content, M26): вмикає лише явне true', () => {
  assert.equal(adultContentFrom({ adult_content: true }), true);
  assert.equal(adultContentFrom({ adult_content: false }), false);
  assert.equal(adultContentFrom({ adult_content: 'true' }), false);
  assert.equal(adultContentFrom({}), false); // колонки ще немає (M26 не запущено)
  assert.equal(adultContentFrom(null), false); // немає рядка профілю / помилка
  assert.equal(adultContentFrom(undefined), false);
});

function w18(register: LexemeLabels['register']): LexemeLabels {
  return { register, regionality: 'general', usage_tags: [] };
}
