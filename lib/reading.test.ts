import { test } from 'node:test';
import assert from 'node:assert/strict';
import {
  glossaryIndex, isCroatianOption, knownLabel, levelIntro, moduleCardTitles, moduleHeading, moduleTitle, paragraphs, pickReadingLevel, questionsFrom, readingMinutes,
  scoreAnswers, seededShuffle, speechChunks, textTypeLabel, tokenize,
} from './reading.ts';

test('tokenize: слова з діакритикою, розділові знаки окремо, текст складається назад без змін', () => {
  const line = 'Bok, Olena! Jesi li slobodna u subotu?';
  const segs = tokenize(line);
  assert.equal(segs.map((s) => s.text).join(''), line);
  assert.deepEqual(segs.filter((s) => s.word).map((s) => s.word), ['bok', 'olena', 'jesi', 'li', 'slobodna', 'u', 'subotu']);
});

test('tokenize: слова з дефісом цілі, числа й пошта — не слова', () => {
  const segs = tokenize('Platite SMS-om 1,60 € ili pišite na posao@hotelmarina.hr.');
  const words = segs.filter((s) => s.word).map((s) => s.word);
  assert.deepEqual(words, ['platite', 'sms-om', 'ili', 'pišite', 'na']);
  assert.ok(segs.some((s) => s.text === 'posao@hotelmarina.hr.' && s.word === null));
});

test('paragraphs: рядки без порожніх', () => {
  assert.deepEqual(paragraphs('Mama: Tko?\n\nTata: Ja.\r\n'), ['Mama: Tko?', 'Tata: Ja.']);
});

test('glossaryIndex: за формою в нижньому регістрі, некоректні записи пропускаємо', () => {
  const idx = glossaryIndex([
    { form: 'Kupujem', lemma: 'kupovati', ua: 'купувати', lesson: false },
    { form: 'kruh', lemma: 'kruh', ua: 'хліб', lesson: true },
    { form: 'x' },
    null,
  ]);
  assert.equal(idx.size, 2);
  assert.equal(idx.get('kupujem')?.lemma, 'kupovati');
  assert.equal(idx.get('kruh')?.lesson, true);
  assert.equal(glossaryIndex('oops').size, 0);
});

test('glossaryIndex: граматичні підказки (§56) — лише непорожні рядки, обрізані до 200 символів', () => {
  const idx = glossaryIndex([
    { form: 'subotu', lemma: 'subota', ua: 'субота', lesson: true, pos: 'іменник, жіночий рід', gram: 'знахідний відмінок, однина' },
    { form: 'bok', lemma: 'bok', ua: 'привіт', pos: '  ', gram: 42 },
    { form: 'dugo', lemma: 'dug', ua: 'довгий', pos: 'x'.repeat(500) },
  ]);
  assert.equal(idx.get('subotu')?.pos, 'іменник, жіночий рід');
  assert.equal(idx.get('subotu')?.gram, 'знахідний відмінок, однина');
  assert.equal(idx.get('bok')?.pos, undefined);
  assert.equal(idx.get('bok')?.gram, undefined);
  assert.equal(idx.get('dugo')?.pos?.length, 200);
});

test('questionsFrom і scoreAnswers', () => {
  const qs = questionsFrom([
    { question_ua: 'Де?', options: ['Тут', 'Там'], answer: 'Тут' },
    { question_ua: 'Коли?', options: ['Зараз'], answer: 'Потім' },
    { question_ua: 'Хто?', options: ['Ана', 'Іван'], answer: 'Іван' },
  ]);
  assert.equal(qs.length, 2);
  assert.equal(scoreAnswers(qs, ['Тут', 'Ана']), 1);
  assert.equal(scoreAnswers(qs, ['Тут', 'Іван']), 2);
  assert.equal(scoreAnswers(qs, [null, null]), 0);
});

test('seededShuffle: сталий порядок для зерна, ті самі елементи', () => {
  const a = seededShuffle(['a', 'b', 'c'], 'RD-A1-001:0');
  assert.deepEqual(seededShuffle(['a', 'b', 'c'], 'RD-A1-001:0'), a);
  assert.deepEqual([...a].sort(), ['a', 'b', 'c']);
  // різні зерна дають різний порядок хоча б іноді
  const orders = new Set(Array.from({ length: 12 }, (_, i) => seededShuffle(['a', 'b', 'c'], `s${i}`).join('')));
  assert.ok(orders.size > 1);
});

test('speechChunks: шматки до ліміту, нічого не губиться', () => {
  const body = 'Taras živi u Zagrebu. Svaki dan se budi u šest i pol, prvo se tušira, a onda doručkuje s obitelji, pa ide na posao tramvajem i radi u skladištu do četiri.\nNavečer čita.';
  const chunks = speechChunks(body, 60);
  assert.ok(chunks.every((c) => c.length <= 60), JSON.stringify(chunks));
  assert.equal(chunks.join(' ').replace(/\s+/g, ' '), body.replace(/\s+/g, ' '));
});

test('підписи: вид тексту, хвилини, знайомі слова', () => {
  assert.equal(textTypeLabel('menu'), 'Меню');
  assert.equal(textTypeLabel('poem'), 'Текст');
  assert.equal(readingMinutes(20), 1);
  assert.equal(readingMinutes(150), 3);
  assert.equal(knownLabel(0.923), 'знайомих слів 92 %');
  assert.equal(knownLabel(null), null);
});

test('рівень читання: з адреси, з профілю (B1/B2 → A2), інакше A1; лише наявні рівні', () => {
  assert.equal(pickReadingLevel('A2', 'A0'), 'A2');
  assert.equal(pickReadingLevel(undefined, 'A0'), 'A0');
  assert.equal(pickReadingLevel(null, 'B1'), 'A2');
  assert.equal(pickReadingLevel('x', null), 'A1');
  assert.equal(pickReadingLevel('A2', 'A2', ['A0', 'A1']), 'A1'); // A2 ще не опубліковано — найближчий нижчий
  assert.equal(pickReadingLevel('A0', null, ['A1', 'A2']), 'A1');
  assert.equal(pickReadingLevel('A2', null, []), 'A2');
});

test('заголовки груп: модулі A0/A1 і теми A2, вивіски', () => {
  assert.equal(moduleTitle('Модуль A0.10 — Survival Croatian (виживання)'), 'Survival Croatian (виживання)');
  assert.equal(moduleHeading('A1', 3, 'Модуль A1.3 — Покупки'), 'Після модуля A1.3 · Покупки');
  assert.equal(moduleHeading('A0', 2, null), 'Після модуля A0.2');
  assert.equal(moduleHeading('A2', 2, null), 'Тема 2 · Подорожі');
  assert.equal(moduleHeading('A2', null), 'Інші тексти');
  assert.equal(textTypeLabel('sign'), 'Вивіски');
  assert.ok(levelIntro('A0').includes('Вивіски'));
});

test('варіант відповіді хорватською: літери без кирилиці; числа й ціни — ні', () => {
  assert.equal(isCroatianOption('Hvala i doviđenja!'), true);
  assert.equal(isCroatianOption('Дякуємо і до побачення'), false);
  assert.equal(isCroatianOption('1,50 €'), false);
  assert.equal(isCroatianOption('На поверсі біля входу (prizemlje)'), false);
});

test('шапка модуля: без потрійного «Модуль», хорватська назва — лише якщо нова', () => {
  assert.deepEqual(moduleCardTitles('Модуль A0.1 — Pozdrav!', 'Modul A0.1 — Pozdrav!', 'A0', 1),
    { kicker: 'Модуль A0.1', title: 'Pozdrav!', subtitle: null });
  assert.deepEqual(moduleCardTitles('Модуль A0.2 — Ja sam…', 'Modul A0.2 — Ja sam...', 'A0', 2).subtitle, null);
  assert.deepEqual(moduleCardTitles('Модуль A0.3 — Brojevi (числа)', 'Modul A0.3 — Brojevi', 'A0', 3),
    { kicker: 'Модуль A0.3', title: 'Brojevi (числа)', subtitle: null });
  assert.deepEqual(moduleCardTitles('Модуль A1.1 — Повсякденне життя', 'Modul A1.1 — Svakodnevni život', 'A1', 1),
    { kicker: 'Модуль A1.1', title: 'Повсякденне життя', subtitle: 'Svakodnevni život' });
  assert.deepEqual(moduleCardTitles('Без префікса', null, 'A1', 10),
    { kicker: 'Модуль A1.10', title: 'Без префікса', subtitle: null });
});
