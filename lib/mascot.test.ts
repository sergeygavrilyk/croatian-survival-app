// Талісман-далматинець (lib/mascot.ts). Запуск: npm test
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { DEFAULT_MASCOT, MASCOTS, MASCOT_KINDS, mascotInfo, parseMascot, readStoredMascot, storeMascot } from './mascot.ts';

test('Талісман: Pjegica, Šime або Točka; інше — не обрано; старі female / male з макетів → Pjegica / Šime', () => {
  for (const k of MASCOT_KINDS) assert.equal(parseMascot(k), k);
  assert.equal(parseMascot('female'), 'pjegica');
  assert.equal(parseMascot('male'), 'sime');
  for (const v of [null, undefined, '', 'cat', 'Sime', 1]) assert.equal(parseMascot(v), null);
});

test('Талісман: не обрано → Pjegica; у кожного своє зображення, ім’я з діакритиками', () => {
  assert.equal(DEFAULT_MASCOT, 'pjegica');
  assert.equal(mascotInfo(null).kind, 'pjegica');
  assert.equal(mascotInfo('sime').name, 'Šime');
  assert.equal(mascotInfo('tocka').name, 'Točka');
  const srcs = Object.values(MASCOTS).map((m) => m.src);
  assert.equal(new Set(srcs).size, 3);
  for (const s of srcs) assert.match(s, /^\/mascot\/[a-z]+\.svg$/);
});

test('Талісман у браузері: збереження й читання; зламане сховище не кидає помилку', () => {
  const box = new Map<string, string>();
  const storage = { getItem: (k: string) => box.get(k) ?? null, setItem: (k: string, v: string) => void box.set(k, v) };
  assert.equal(readStoredMascot(storage), null);
  storeMascot(storage, 'tocka');
  assert.equal(readStoredMascot(storage), 'tocka');
  storeMascot(storage, null);
  assert.equal(readStoredMascot(storage), 'tocka');
  const broken = { getItem: () => { throw new Error('denied'); }, setItem: () => { throw new Error('denied'); } };
  assert.equal(readStoredMascot(broken), null);
  assert.doesNotThrow(() => storeMascot(broken, 'sime'));
  assert.equal(readStoredMascot(null), null);
});
