import { test } from 'node:test';
import assert from 'node:assert/strict';
import { micAccessHelp, micPlatform, pickTranscripts } from './speech-session.ts';

const IPHONE_SAFARI = 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Mobile/15E148 Safari/604.1';
const IPHONE_CHROME = 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_6 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) CriOS/141.0 Mobile/15E148 Safari/604.1';
const MAC_SAFARI = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.6 Safari/605.1.15';
const MAC_CHROME = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36';
const WIN_CHROME = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36';

test('остаточний результат: усі варіанти для однієї фрази', () => {
  assert.deepEqual(pickTranscripts([['Dobar dan', 'dobar dan!']], ''), ['Dobar dan', 'dobar dan!']);
});

test('Safari: остаточного результату немає — беремо проміжний текст, а не «нічого не почули»', () => {
  assert.deepEqual(pickTranscripts([], '  Gdje je   ljekarna '), ['Gdje je ljekarna']);
  assert.deepEqual(pickTranscripts([], ''), []);
  assert.deepEqual(pickTranscripts([[' ', '']], ' '), []);
});

test('кілька фрагментів і хвіст, що не встиг стати остаточним, — склеюємо', () => {
  assert.deepEqual(pickTranscripts([['Dobar dan'], ['kako ste']], ''), ['Dobar dan kako ste']);
  assert.deepEqual(pickTranscripts([['Dobar dan']], 'kako ste'), ['Dobar dan kako ste']);
});

test('платформа для підказки про мікрофон', () => {
  assert.equal(micPlatform(IPHONE_SAFARI), 'ios_safari');
  assert.equal(micPlatform(IPHONE_CHROME), 'ios_chrome');
  assert.equal(micPlatform(MAC_SAFARI), 'mac_safari');
  assert.equal(micPlatform(MAC_CHROME), 'other');
  assert.equal(micPlatform(WIN_CHROME), 'other');
  assert.equal(micPlatform(''), 'other');
});

test('підказка про мікрофон: iPhone — параметри Safari і диктування, інші — значок біля адреси', () => {
  assert.match(micAccessHelp(IPHONE_SAFARI), /Safari → «Мікрофон»/);
  assert.match(micAccessHelp(IPHONE_SAFARI), /Диктування/);
  assert.match(micAccessHelp(IPHONE_CHROME), /Chrome → «Мікрофон»/);
  assert.match(micAccessHelp(MAC_SAFARI), /«Вебсайти» → «Мікрофон»/);
  assert.match(micAccessHelp(WIN_CHROME), /значок біля адреси/);
  assert.match(micAccessHelp(WIN_CHROME, 'Або пропустіть вправу.'), /адреси сторінки\)\. Або пропустіть вправу\.$/);
});

test('підказка про мікрофон: застосунок з іконки (PWA) на iPhone / Mac — відкрити у вкладці Safari', () => {
  assert.match(micAccessHelp(IPHONE_SAFARI, '', true), /з іконки на екрані «Додому».*у самому Safari/);
  assert.match(micAccessHelp(IPHONE_CHROME, '', true), /у самому Safari/);
  assert.match(micAccessHelp(MAC_SAFARI, 'Або пропустіть вправу.', true), /з Dock.*Або пропустіть вправу\.$/);
  // на Android / Windows режим застосунку мікрофону не заважає — звичайна підказка
  assert.match(micAccessHelp(WIN_CHROME, '', true), /значок біля адреси/);
  assert.doesNotMatch(micAccessHelp(IPHONE_SAFARI, '', false), /з іконки/);
});

test('підказка про мікрофон: service-not-allowed у Safari — диктування й «Екранний час», код у кінці', () => {
  const ios = micAccessHelp(IPHONE_SAFARI, 'І спробуйте ще раз.', false, 'service-not-allowed');
  assert.match(ios, /хоча мікрофон дозволено/);
  assert.match(ios, /Екранний час/);
  assert.match(ios, /«Розпізнавання мовлення» → Safari/);
  assert.match(ios, /І спробуйте ще раз\. \(код: service-not-allowed\)$/);
  assert.match(micAccessHelp(MAC_SAFARI, '', false, 'service-not-allowed'), /Системні параметри/);
  // not-allowed на iPhone — дозвіл саме для сайту через «аА»
  assert.match(micAccessHelp(IPHONE_SAFARI, '', false, 'not-allowed'), /«аА».*\(код: not-allowed\)$/);
  // у Chrome на комп'ютері — звичайна підказка, але з кодом
  assert.match(micAccessHelp(WIN_CHROME, '', false, 'service-not-allowed'), /значок біля адреси.*\(код: service-not-allowed\)$/);
});
