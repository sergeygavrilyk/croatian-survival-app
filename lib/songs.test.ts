import { test } from 'node:test';
import assert from 'node:assert/strict';
import { listenUrl, songBySlug, SONGS } from './songs.ts';

const CYR = /[Ѐ-ӿ]/;
// Повний текст — лише для суспільного надбання (авторське право)
const PUBLIC_DOMAIN = new Set(['sretan-rodendan', 'lijepa-nasa-domovino']);

test('пісні: 7 пісень за списком власника, адреси унікальні', () => {
  assert.equal(SONGS.length, 7);
  assert.equal(new Set(SONGS.map((s) => s.slug)).size, SONGS.length);
  for (const s of SONGS) assert.match(s.slug, /^[a-z0-9-]+$/, s.slug);
});

test('пісні: повний текст лише для суспільного надбання', () => {
  for (const s of SONGS) {
    if (PUBLIC_DOMAIN.has(s.slug)) assert.ok(s.lyrics && s.lyrics.length > 0, s.slug);
    else assert.equal(s.lyrics, undefined, `${s.slug}: авторський текст не копіюємо`);
  }
});

test('пісні: хорватське без кирилиці, переклади українською, ключові слова', () => {
  for (const s of SONGS) {
    assert.ok(!CYR.test(s.title) && CYR.test(s.title_ua) && CYR.test(s.about), s.slug);
    assert.ok(s.words.length >= 4, `${s.slug}: щонайменше 4 ключові слова`);
    for (const w of [...s.words, ...(s.lyrics ?? [])]) {
      assert.ok(!CYR.test(w.hr), `${s.slug}: кирилиця в «${w.hr}»`);
      assert.ok(CYR.test(w.ua), `${s.slug}: немає перекладу для «${w.hr}»`);
    }
  }
});

test('пісні: пошук за адресою і посилання «Послухати»', () => {
  assert.equal(songBySlug('kalelarga')?.performer, 'Tomislav Ivčić');
  assert.equal(songBySlug('nema-takoj'), null);
  assert.equal(songBySlug(42), null);
  const url = listenUrl({ listen_query: 'Večeras je naša fešta' });
  assert.ok(url.startsWith('https://www.youtube.com/results?search_query='));
  assert.ok(url.includes('Ve%C4%8Deras'));
});
