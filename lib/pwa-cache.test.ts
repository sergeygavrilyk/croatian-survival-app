import assert from 'node:assert/strict';
import { test } from 'node:test';
import {
  PAGE_CACHE_MAX_AGE_SECONDS,
  PAGE_CACHE_MAX_ENTRIES,
  PAGE_CACHE_NAMES,
  PAGE_NETWORK_TIMEOUT_SECONDS,
  pageCacheRules,
  type PageCacheRule,
} from './pwa-cache.ts';

type Req = { mode: string; headers: Map<string, string> };

function req(mode: string, headers: Record<string, string> = {}): Req {
  return { mode, headers: new Map(Object.entries(headers)) };
}

/** Як у service worker: Workbox переносить функцію текстом, тож вона не може спиратися на зовнішні змінні. */
function asInServiceWorker(rule: PageCacheRule) {
  const fn = new Function(`return (${rule.urlPattern.toString()});`)() as (a: unknown) => boolean;
  return (path: string, r: Req, sameOrigin = true) =>
    fn({ request: { mode: r.mode, headers: { get: (k: string) => r.headers.get(k) ?? null } }, url: new URL(`https://x.test${path}`), sameOrigin });
}

const byName = (name: PageCacheRule['options']['cacheName']) => {
  const rule = pageCacheRules.find((r) => r.options.cacheName === name);
  if (!rule) throw new Error(`немає правила ${name}`);
  return asInServiceWorker(rule);
};

test('кеш сторінок: 30 днів, до 200 сторінок, тайм-аут мережі 5 с (рішення 2026-11-16)', () => {
  assert.equal(PAGE_CACHE_MAX_AGE_SECONDS, 30 * 24 * 60 * 60);
  assert.equal(PAGE_CACHE_MAX_ENTRIES, 200);
  assert.equal(PAGE_NETWORK_TIMEOUT_SECONDS, 5);
  assert.deepEqual(
    pageCacheRules.map((r) => r.options.cacheName),
    ['pages-rsc-prefetch', 'pages-rsc', 'pages', 'pages'],
    'усі три кеші сторінок замінено, у такому порядку; четверте правило — сторінки наперед (2026-11-16)',
  );
  assert.deepEqual([...new Set(pageCacheRules.map((r) => r.options.cacheName))], [...PAGE_CACHE_NAMES], 'вихід з акаунта чистить усі кеші сторінок');
  for (const rule of pageCacheRules) {
    assert.equal(rule.handler, 'NetworkFirst', rule.options.cacheName);
    assert.ok(rule.options.expiration.maxAgeSeconds >= 30 * 24 * 60 * 60, rule.options.cacheName);
    assert.ok(rule.options.expiration.maxEntries >= 200, rule.options.cacheName);
  }
  assert.equal(pageCacheRules.find((r) => r.options.cacheName === 'pages')?.options.networkTimeoutSeconds, 5);
  assert.equal(pageCacheRules.find((r) => r.options.cacheName === 'pages-rsc')?.options.networkTimeoutSeconds, 5);
});

test('«pages» ловить лише відкриття сторінки, а не скрипти, стилі, картинки й API', () => {
  const pages = byName('pages');
  assert.equal(pages('/lesson/c0000000-0000-0000-0000-000000000001', req('navigate')), true);
  assert.equal(pages('/reading/abc?level=A1', req('navigate')), true);
  assert.equal(pages('/', req('navigate')), true);
  // правила стають перед стандартними — не можна перехопити чужі запити
  assert.equal(pages('/_next/static/chunks/main.js', req('no-cors')), false);
  assert.equal(pages('/_next/static/css/app.css', req('no-cors')), false);
  assert.equal(pages('/icons/icon-192.png', req('no-cors')), false);
  assert.equal(pages('/manifest.json', req('cors')), false);
  assert.equal(pages('/reading/abc', req('cors', { RSC: '1' })), false, 'дані роутера — у pages-rsc');
  assert.equal(pages('/api/tts', req('navigate')), false);
  assert.equal(pages('/lesson/x', req('navigate'), false), false, 'чужий сайт');
});

test('«pages-rsc» і «pages-rsc-prefetch» — лише запити роутера Next.js', () => {
  const rsc = byName('pages-rsc');
  const prefetch = byName('pages-rsc-prefetch');
  assert.equal(rsc('/reading/abc', req('cors', { RSC: '1' })), true);
  assert.equal(rsc('/reading/abc', req('cors')), false);
  assert.equal(rsc('/_next/static/chunks/main.js', req('no-cors')), false);
  assert.equal(rsc('/api/x', req('cors', { RSC: '1' })), false);
  assert.equal(prefetch('/reading/abc', req('cors', { RSC: '1', 'Next-Router-Prefetch': '1' })), true);
  assert.equal(prefetch('/reading/abc', req('cors', { RSC: '1' })), false, 'звичайний перехід — не prefetch');
  assert.equal(prefetch('/reading/abc', req('cors', { RSC: '1', 'Next-Router-Prefetch': '1' }), false), false);
});

test('сторінки наперед (2026-11-16): лише запит із заголовком, у кеш «pages», лише відповіді 200', async () => {
  const { PREFETCH_HEADER, PREFETCH_HEADER_VALUE } = await import('./offline-prefetch.ts');
  const rule = pageCacheRules[3];
  assert.equal(rule.options.cacheName, 'pages', 'той самий кеш, що й відкриття сторінки — без мережі навігація знайде її');
  assert.deepEqual(rule.options.cacheableResponse, { statuses: [200] }, 'переадресація на вхід не потрапляє в кеш');
  assert.equal(rule.options.expiration.maxEntries, PAGE_CACHE_MAX_ENTRIES);
  const prefetch = asInServiceWorker(rule);
  const marked = { [PREFETCH_HEADER]: PREFETCH_HEADER_VALUE };
  assert.equal(prefetch('/lesson/c0000000-0000-0000-0000-000000000002', req('cors', marked)), true);
  assert.equal(prefetch('/situations/pharmacy', req('cors', marked)), true);
  assert.equal(prefetch('/lesson/x', req('cors')), false, 'звичайний запит — ні');
  assert.equal(prefetch('/lesson/x', req('cors', { [PREFETCH_HEADER]: 'yes' })), false);
  assert.equal(prefetch('/lesson/x', req('cors', { [PREFETCH_HEADER]: 'full' })), true, 'оновлення після оновлення застосунку (2026-11-16)');
  assert.equal(prefetch('/api/tts', req('cors', marked)), false);
  assert.equal(prefetch('/lesson/x', req('cors', marked), false), false, 'чужий сайт');
  // звичайне відкриття сторінки цим правилом не змінюється
  assert.equal(pageCacheRules[2].options.cacheableResponse, undefined);
});
