import { expect, test, type BrowserContext, type Page, type Route } from '@playwright/test';
import { HAS_USER, NO_USER_REASON, TEST_LESSON_ID } from './env';

/**
 * Сценарії з тестовим акаунтом: у власника — `npm run e2e`, у CI — робота `e2e-user` на кожному PR (з 2026-11-14).
 * Пишуть у робочу базу лише прогрес тестового акаунта (lesson_progress, reading_progress, повторення, події, client_ops).
 */
test.skip(!HAS_USER, NO_USER_REASON);

test('«Уроки»: A0 за замовчуванням, перемикання рівня через адресу, «Назад» повертає A0', async ({ page }) => {
  await page.goto('/lessons');
  await expect(page.getByRole('heading', { level: 1, name: 'Уроки' })).toBeVisible();
  await expect(page.getByText(/^A0 · /)).toBeVisible();
  // перший модуль розгорнуто, у ньому є уроки
  await expect(page.locator('button[aria-expanded="true"]').first()).toBeVisible();
  await expect(page.locator('a[href^="/lesson/"]').first()).toBeVisible();

  const levels = page.getByRole('navigation', { name: 'Рівень' });
  await levels.getByRole('link', { name: 'A1', exact: true }).click();
  await expect(page).toHaveURL(/\/lessons\?level=A1$/);
  await expect(page.getByText(/^A1 · /)).toBeVisible();
  await expect(levels.getByRole('link', { name: 'A1', exact: true })).toHaveAttribute('aria-current', 'page');
  await expect(page.locator('a[href^="/lesson/"]').first()).toBeVisible();

  await page.goBack();
  await expect(page).toHaveURL(/\/lessons$/);
  await expect(page.getByText(/^A0 · /)).toBeVisible();
});

test('«Граматика рівня»: з «Уроків» → теми A1 → тема → тренування; пошук без діакритик', async ({ page }) => {
  await page.goto('/lessons?level=A1');
  await page.getByRole('link', { name: /Граматика рівня A1/ }).click();
  await expect(page).toHaveURL(/\/lessons\/grammar\?level=A1$/);
  await expect(page.getByRole('heading', { level: 1, name: 'Граматика рівня' })).toBeVisible();
  await expect(page.getByText(/^Пройдено \d+ з \d+$/)).toBeVisible();

  await page.getByRole('searchbox').fill('akuzativ');
  await expect(page.getByRole('list', { name: 'Знайдені теми' }).getByRole('link')).not.toHaveCount(0);
  await page.getByRole('list', { name: 'Знайдені теми' }).getByRole('link').first().click();
  await expect(page).toHaveURL(/\/lessons\/grammar\/[0-9a-f-]{36}$/);
  await expect(page.getByRole('heading', { level: 1, name: 'Знахідний відмінок' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Уроки з цією темою' })).toBeVisible();

  const train = page.getByRole('button', { name: /Потренувати тему/ });
  if (await train.count()) {
    await train.click();
    await expect(page.getByText(/^Вправа 1 з \d+$/)).toBeVisible();
    await page.getByRole('button', { name: 'Закрити тренування' }).click();
  }
  await expect(page.getByRole('link', { name: 'Граматика A1' })).toHaveAttribute('href', '/lessons/grammar?level=A1');
});

test('«Підсумок граматики»: позначити тему → вправи', async ({ page }) => {
  await page.goto('/lessons/grammar/review?level=A0');
  await expect(page.getByRole('heading', { level: 1, name: 'Підсумок граматики A0' })).toBeVisible();
  await page.getByRole('button', { name: 'Треба повторити' }).first().click();
  await expect(page.getByText('Позначено 1 з', { exact: false })).toBeVisible();
  await page.getByRole('button', { name: 'Далі: вправи' }).click();
  await expect(page.getByText(/^Вправа 1 з \d+$|Вправ на ці теми поки немає/)).toBeVisible();
});

test('урок від початку до святкового екрана: прогрес збережено', async ({ page }) => {
  test.slow(); // 17 вправ (15 + письмо й переказ), кожна неправильна — ще раз наприкінці
  await page.goto(`/lesson/${TEST_LESSON_ID}`);
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
  await page.getByRole('button', { name: 'Почати урок' }).click();

  await walkThroughLesson(page);

  await expect(page.getByRole('heading', { name: 'Урок пройдено!' })).toBeVisible();
  await expect(page.getByText('Зберігаємо прогрес…')).toBeHidden({ timeout: 30_000 });
  await expect(page.getByText('Не вдалося зберегти прогрес')).toHaveCount(0);
  await expect(page.getByRole('link', { name: 'До уроків' })).toHaveAttribute('href', /^\/lessons/);
});

test.describe('«Сьогодні» на iPhone', () => {
  // Chromium з адресою браузера iPhone: Safari не можна запустити, але логіка підказки дивиться саме на неї
  test.use({
    userAgent:
      'Mozilla/5.0 (iPhone; CPU iPhone OS 18_1 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.1 Mobile/15E148 Safari/604.1',
  });

  test('підказка «Додати на початковий екран» (§76): кроки в Safari, «Не зараз» ховає', async ({ page }) => {
    // Підказка — після першого уроку: попередній тест щойно пройшов урок (серія ≥ 1)
    await page.goto('/');
    const hint = page.getByTestId('install-hint');
    await expect(hint).toBeVisible();
    await expect(hint.getByRole('heading', { name: 'Додайте застосунок на початковий екран' })).toBeVisible();
    await expect(hint.getByRole('list', { name: 'Як додати на iPhone' })).toContainText('«На початковий екран»');
    await expect(hint.getByRole('button', { name: 'Встановити' })).toHaveCount(0);

    await hint.getByRole('button', { name: 'Не зараз' }).click();
    await expect(hint).toBeHidden();
    await page.reload();
    await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
    await expect(page.getByTestId('install-hint')).toHaveCount(0);
  });
});

test('урок, якого немає: «Урок не знайдено» і шлях до уроків', async ({ page }) => {
  await page.goto('/lesson/00000000-0000-0000-0000-000000000000');
  await expect(page.getByRole('heading', { name: 'Урок не знайдено' })).toBeVisible();
  await expect(page.getByRole('link', { name: 'До уроків' })).toHaveAttribute('href', '/lessons');
});

test('читання: список → текст відкривається', async ({ page }) => {
  await openFirstReadingText(page);
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
});

test('словник: пошук → картка слова → «Додати в повторення»', async ({ page }) => {
  await page.goto('/dictionary');
  await page.getByLabel('Пошук слова').fill('pomidor');
  await page.getByRole('button', { name: /^pomidor — .*Відкрити картку слова/ }).click();
  const sheet = page.getByRole('dialog', { name: 'pomidor' });
  await expect(sheet).toBeVisible();
  await expect(sheet).toContainText('регіонально');
  // тестовий акаунт міг додати слово в минулому запуску; кнопка з'являється, лише коли відомо, що слова ще немає в повтореннях
  const add = sheet.getByRole('button', { name: 'Додати в повторення' });
  const status = sheet.getByRole('status');
  await expect(add.or(status)).toBeVisible();
  if (await add.isVisible()) {
    await add.click();
    await expect(status).toContainText('Додано в повторення');
  } else {
    await expect(status).toContainText('вже вчите');
  }
  await page.keyboard.press('Escape');
  await expect(sheet).toBeHidden();
  await expect(page.getByRole('button', { name: /^pomidor — .*вчу\. Відкрити картку слова/ })).toBeVisible();
});

test('словник: позначка категорії на картці й фільтр «Категорія»', async ({ page }) => {
  await page.goto('/dictionary');
  const categories = page.getByRole('group', { name: 'Категорія слів' });
  await expect(categories.getByRole('button', { name: 'Усі', pressed: true })).toBeVisible();

  // Сленг + пошук: обидві умови разом (два «or» у запиті до бази)
  await categories.getByRole('button', { name: 'Сленг' }).click();
  await expect(categories.getByRole('button', { name: 'Сленг', pressed: true })).toBeVisible();
  await page.getByLabel('Пошук слова').fill('onak');
  const row = page.getByRole('button', { name: /^onak — .*сленг.*Відкрити картку слова/ });
  await expect(row).toBeVisible();
  await row.click();
  const sheet = page.getByRole('dialog', { name: 'onak' });
  await expect(sheet.getByRole('list', { name: /Категорія: сленг, регіонально · Загреб/ })).toBeVisible();
  await page.keyboard.press('Escape');

  // Інша категорія — слова немає, кнопка повертає всі категорії
  await categories.getByRole('button', { name: 'Ідіоми' }).click();
  await expect(page.getByRole('heading', { name: 'Слів не знайдено' })).toBeVisible();
  await page.getByRole('button', { name: 'Показати всі категорії' }).click();
  await expect(categories.getByRole('button', { name: 'Усі', pressed: true })).toBeVisible();
  await expect(row).toBeVisible();
});

test('ситуація: діалоги фільтруються за рівнем', async ({ page }) => {
  await page.goto('/situations/basics');
  await page.getByRole('tab', { name: /^Діалоги/ }).click();
  const levels = page.getByRole('group', { name: 'Рівень діалогів' });
  await expect(levels.getByRole('button', { name: /^Усі · \d+$/, pressed: true })).toBeVisible();

  const a1 = levels.getByRole('button', { name: /^A1 · \d+$/ });
  const count = Number((await a1.textContent())?.split('·')[1]?.trim());
  await a1.click();
  await expect(levels.getByRole('button', { name: /^A1 · \d+$/, pressed: true })).toBeVisible();
  await expect(page.getByText(new RegExp(`^${count} діалог.* · рівень A1$`))).toBeVisible();

  await levels.getByRole('button', { name: /^Усі · \d+$/ }).click();
  await expect(page.getByText(/ · рівень A1$/)).toBeHidden();
});

test('ситуація: фрази фільтруються за рівнем, «Перевір себе» — лише вибрані', async ({ page }) => {
  await page.goto('/situations/basics');
  await expect(page.getByRole('tab', { name: /^Фрази/, selected: true })).toBeVisible();
  const levels = page.getByRole('group', { name: 'Рівень фраз' });
  await expect(levels.getByRole('button', { name: /^Усі · \d+$/, pressed: true })).toBeVisible();

  const a1 = levels.getByRole('button', { name: /^A1 · \d+$/ });
  const count = Number((await a1.textContent())?.split('·')[1]?.trim());
  await a1.click();
  await expect(levels.getByRole('button', { name: /^A1 · \d+$/, pressed: true })).toBeVisible();
  await expect(page.getByText(new RegExp(`^${count} фраз.* · рівень A1$`))).toBeVisible();

  await page.getByRole('button', { name: 'Перевір себе' }).click();
  await expect(page.getByText(`1 / ${count}`, { exact: true })).toBeVisible();
  await page.getByRole('button', { name: 'Завершити' }).click();

  await levels.getByRole('button', { name: /^Усі · \d+$/ }).click();
  await expect(page.getByText(/ · рівень A1$/)).toBeHidden();
});

test('профіль: «Показувати контент 18+» — вимкнено, увімкнути лише з підтвердженням 18+', async ({ page }) => {
  await page.goto('/profile');
  const toggle = page.getByRole('switch', { name: 'Показувати контент 18+' });
  test.skip((await toggle.count()) === 0, 'колонки profiles.adult_content ще немає — M26 запуститься після мержу');

  const startOn = (await toggle.getAttribute('aria-checked')) === 'true';
  if (startOn) {
    await toggle.click(); // залишок попереднього прогону — повертаємо «вимкнено»
    await expect(toggle).toHaveAttribute('aria-checked', 'false');
  }
  await toggle.click();
  await expect(page.getByText('Підтвердьте, що вам уже виповнилося 18 років.')).toBeVisible();
  await page.getByRole('button', { name: 'Скасувати' }).click();
  await expect(toggle).toHaveAttribute('aria-checked', 'false');

  await toggle.click();
  await page.getByRole('button', { name: 'Так, мені 18+' }).click();
  await expect(toggle).toHaveAttribute('aria-checked', 'true');
  await expect(page.getByText('Контент 18+ увімкнено.')).toBeVisible();

  await toggle.click(); // тестовий акаунт лишаємо з вимкненим 18+
  await expect(toggle).toHaveAttribute('aria-checked', 'false');
  await expect(page.getByText('Контент 18+ приховано.')).toBeVisible();
});

test('офлайн (§76): відкриті раз урок і текст відкриваються без інтернету', async ({ page, context, request }) => {
  test.slow();
  const sw = await request.get('/sw.js');
  test.skip(!sw.ok(), 'PWA вимкнено (npm run dev) — офлайн перевіряємо лише у збірці: npm run e2e');

  const lessonUrl = `/lesson/${TEST_LESSON_ID}`;
  await page.goto(lessonUrl);
  const lessonTitle = (await page.getByRole('heading', { level: 1 }).textContent())?.trim() ?? '';
  expect(lessonTitle).not.toBe('');
  await waitForServiceWorker(page);
  await page.reload(); // тепер сторінку віддає service worker і кладе в кеш
  await expect(page.getByRole('heading', { level: 1, name: lessonTitle })).toBeVisible();

  const textPath = await openFirstReadingText(page);
  const textTitle = (await page.getByRole('heading', { level: 1 }).textContent())?.trim() ?? '';
  await page.reload();
  await expect(page.getByRole('heading', { level: 1, name: textTitle })).toBeVisible();

  // Кеш PWA справді містить обидві сторінки (не залежить від того, як браузер емулює офлайн)
  for (const path of [lessonUrl, textPath]) {
    const cached = await page.evaluate(async (p) => {
      const res = await caches.match(new URL(p, location.origin).href, { ignoreSearch: true });
      return res ? (await res.text()).length : 0;
    }, path);
    expect(cached, `сторінка ${path} у кеші PWA`).toBeGreaterThan(0);
  }

  // Без мережі кожну сторінку відкриваємо в новій вкладці — як людина, що знову відкриває застосунок офлайн.
  await page.close();
  const journal = await recordNavigations(context);
  await context.setOffline(true);
  try {
    for (const [path, title] of [
      [lessonUrl, lessonTitle],
      [textPath, textTitle],
    ] as const) {
      const offlinePage = await context.newPage();
      await offlinePage.goto(path);
      await expect(offlinePage.getByRole('heading', { level: 1, name: title }), `${path} без мережі`).toBeVisible();
      await offlinePage.close();
    }

    // Мережа «моргнула» (подія online): сторінка не перезавантажується сама — інакше губиться незбережене в уроці
    // і скасовується перехід, який людина вже почала. Саме це раз на кілька прогонів ламало тест (2026-11-16):
    // Chromium без мережі інколи сам шле online, а PWA мала reloadOnOnline: true.
    const lessonPage = await context.newPage();
    await lessonPage.goto(lessonUrl);
    await expect(lessonPage.getByRole('heading', { level: 1, name: lessonTitle })).toBeVisible();
    await lessonPage.evaluate(() => {
      (window as unknown as { __e2eStay?: boolean }).__e2eStay = true;
      window.dispatchEvent(new Event('online'));
    });
    await lessonPage.waitForTimeout(1_000);
    expect(
      await lessonPage.evaluate(() => (window as unknown as { __e2eStay?: boolean }).__e2eStay === true),
      'подія online не перезавантажує сторінку',
    ).toBe(true);
    await lessonPage.close();

    // Як людина в застосунку: без мережі «Читання» → натиснути на текст (перехід усередині застосунку)
    const listPage = await context.newPage();
    await listPage.goto('/reading');
    await listPage.locator(`a[href="${textPath}"]`).first().click();
    await expect(listPage).toHaveURL(new RegExp(`${textPath}$`));
    await expect(listPage.getByRole('heading', { level: 1, name: textTitle }), 'перехід зі списку без мережі').toBeVisible();
  } catch (err) {
    // Запис кроків (trace) у CI не вивантажуємо (у ньому пароль), тож журнал переходів — у лог кроку
    console.log(`Журнал переходів без мережі:\n${journal.join('\n')}`);
    throw err;
  } finally {
    await context.setOffline(false);
  }
});

test('офлайн без втрат: урок без зв\'язку з сервером — у черзі, з\'явився зв\'язок — прогрес збережено', async ({ page }) => {
  test.slow(); // урок від початку до кінця
  await page.goto(`/lesson/${TEST_LESSON_ID}`);
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
  // Зв'язку з сервером немає: кожен виклик server action обривається, як без інтернету (сторінки — як завжди)
  const dropActions = async (route: Route) => {
    if (route.request().method() === 'POST' && route.request().headers()['next-action']) await route.abort('internetdisconnected');
    else await route.continue();
  };
  await page.route('**/*', dropActions);
  await page.getByRole('button', { name: 'Почати урок' }).click();
  await walkThroughLesson(page);

  await expect(page.getByRole('heading', { name: 'Урок пройдено!' })).toBeVisible();
  await expect(page.getByText('Прогрес збережемо, щойно з’явиться інтернет')).toBeVisible({ timeout: 30_000 });
  await expect(page.getByText('Не вдалося зберегти прогрес')).toHaveCount(0);
  expect(await queuedKinds(page), 'завершення уроку — у черзі на телефоні').toContain('lesson_completed');

  // «Уроки» без зв'язку: значок «… чекають на інтернет»
  await page.goto('/lessons');
  await expect(page.getByText(/чека(є|ють) на інтернет/)).toBeVisible();

  // Зв'язок з'явився — черга відправляється сама, значок зникає
  await page.unroute('**/*', dropActions);
  await page.evaluate(() => window.dispatchEvent(new Event('online')));
  await expect.poll(() => queuedKinds(page), { timeout: 60_000, message: 'черга відправлена' }).toEqual([]);
  await expect(page.getByText(/чека(є|ють) на інтернет/)).toHaveCount(0);
});

test('офлайн без втрат: текст без інтернету — «Результат збережемо…», інтернет з\'явився — черга порожня', async ({ page, context }) => {
  await openFirstReadingText(page);
  await context.setOffline(true);
  try {
    for (const group of await page.locator('section[aria-labelledby="reading-questions"]').getByRole('group').all()) {
      await group.getByRole('button').first().click();
    }
    await page.getByRole('button', { name: 'Перевірити' }).click();
    await expect(page.getByText('Результат збережемо, щойно з’явиться інтернет.')).toBeVisible();
    expect(await queuedKinds(page)).toContain('reading_completed');
  } finally {
    await context.setOffline(false);
  }
  await expect.poll(() => queuedKinds(page), { timeout: 60_000, message: 'черга відправлена' }).toEqual([]);
});

test('офлайн без втрат, етап 2: тренажер без інтернету — картки з телефона, відповідь у черзі, інтернет з\'явився — черга порожня', async ({ page, context }) => {
  // Режим «Картки», усі рівні — тоді перемикання на «Написати» без мережі збирає нову сесію з копії
  await page.addInitScript(() => localStorage.setItem('cs_trainer_prefs_v2', JSON.stringify({ mode: 'recognize', level: 'ALL' })));
  await page.goto('/trainer');
  await expect(page.getByRole('heading', { level: 1, name: 'Практика' })).toBeVisible();
  await expect(page.getByLabel('Підготовка карток')).toHaveCount(0, { timeout: 30_000 });
  test.skip(await page.getByText('Тут з’являться ваші слова').isVisible(), 'у тестового акаунта ще немає слів у повторенні');
  // Онлайн тренажер зберіг копію колоди на телефоні
  await expect
    .poll(() => page.evaluate(() => {
      const uid = document.cookie.split('; ').find((c) => c.startsWith('cs_uid='))?.slice('cs_uid='.length);
      return uid ? Boolean(localStorage.getItem(`cs_offline_trainer_${uid}`)) : false;
    }), { message: 'копія колоди на телефоні' })
    .toBe(true);

  await context.setOffline(true);
  try {
    await page.getByRole('button', { name: 'Написати', exact: true }).click();
    await expect(page.getByText('Без інтернету: картки з телефона.')).toBeVisible();
    await expect(page.getByLabel('Хорватське слово')).toBeVisible();
    await page.getByRole('button', { name: 'Не знаю', exact: true }).click();
    await expect(page.getByRole('button', { name: /Далі/ })).toBeVisible();
    await expect(page.getByText('Не вдалося зберегти відповідь')).toHaveCount(0);
    expect(await queuedKinds(page), 'відповідь — у черзі на телефоні').toContain('srs_rating');
  } finally {
    await context.setOffline(false);
  }
  await page.evaluate(() => window.dispatchEvent(new Event('online')));
  await expect.poll(() => queuedKinds(page), { timeout: 60_000, message: 'черга відправлена' }).toEqual([]);
});

// ------------------------------------------------------------------ помічники

/** Види дій у черзі на телефоні поточного користувача (lib/offline-queue.ts: ключ cs_queue_<id>). */
async function queuedKinds(page: Page): Promise<string[]> {
  return page.evaluate(() => {
    const uid = document.cookie.split('; ').find((c) => c.startsWith('cs_uid='))?.slice('cs_uid='.length);
    if (!uid) return ['<немає cs_uid>'];
    try {
      const raw = localStorage.getItem(`cs_queue_${uid}`);
      return raw ? (JSON.parse(raw) as { ops: { kind: string }[] }).ops.map((o) => o.kind) : [];
    } catch {
      return ['<пошкоджено>'];
    }
  });
}


/** Пройти етапи уроку й вправи до підсумку. Відповідаємо «не знаю» / пропускаємо / перший варіант:
 *  неправильна вправа повторюється один раз, тож урок усе одно доходить до кінця.
 *  Пропускаємо «скажіть уголос», «напишіть повідомлення» / «перекажіть другу» (з 2026-11-05 — дві останні вправи
 *  тестового уроку) і «прослухайте діалог чи оголошення»: пропуск зараховано, вправа не повертається. */
async function walkThroughLesson(page: Page) {
  const done = page.getByRole('heading', { name: 'Урок пройдено!' });
  const exact = (name: string) => page.getByRole('button', { name, exact: true });
  const stageNext = [exact('Далі'), exact('Наступний діалог'), exact('До вправ')];
  const giveUp = exact('Не знаю — показати');
  const skipSpeech = page.getByRole('button', {
    name: /^(Не можу говорити зараз|Пропустити й іти далі|Пропустити|Не можу слухати зараз — пропустити)$/,
  });
  const choices = page.getByRole('group', { name: 'Варіанти відповіді' }).getByRole('button');

  for (let step = 0; step < 120; step++) {
    if (await done.isVisible()) return;
    if (await giveUp.isVisible()) await giveUp.click();
    else if (await skipSpeech.isVisible()) await skipSpeech.click();
    else if (await choices.first().isVisible()) {
      if (await choices.first().isEnabled()) await choices.first().click();
    }
    let moved = false;
    for (const b of stageNext) {
      if (await b.isVisible()) {
        await b.click();
        moved = true;
        break;
      }
    }
    if (!moved) await page.waitForTimeout(200); // відгук на відповідь ще з'являється
  }
  throw new Error('Урок не дійшов до підсумку за 120 кроків');
}

async function openFirstReadingText(page: Page): Promise<string> {
  await page.goto('/reading');
  const link = page.locator('a[href^="/reading/"]').first();
  await expect(link).toBeVisible();
  const href = (await link.getAttribute('href')) ?? '';
  await link.click();
  await expect(page).toHaveURL(new RegExp(`${href}$`));
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
  return href;
}

/** Журнал переходів у нових вкладках (для логу CI, якщо офлайн-тест упаде): хто і куди перезавантажив сторінку,
 *  події online / offline, помилки консолі. Стек показує, який код запустив перехід. */
async function recordNavigations(context: BrowserContext): Promise<string[]> {
  const journal: string[] = [];
  await context.addInitScript(() => {
    const t0 = Date.now();
    const log = (m: string) => console.log(`[nav] +${Date.now() - t0}ms ${location.pathname} ${m}`);
    addEventListener('online', () => log('online'));
    addEventListener('offline', () => log('offline'));
    const nav = (window as unknown as { navigation?: EventTarget }).navigation;
    nav?.addEventListener('navigate', (ev) => {
      const e = ev as unknown as { navigationType: string; destination: { url: string; sameDocument: boolean } };
      if (e.destination.sameDocument) return;
      const stack = (new Error().stack ?? '').split('\n').slice(2, 6).map((l) => l.trim()).join(' <- ');
      log(`${e.navigationType} -> ${e.destination.url} | ${stack}`);
    });
  });
  context.on('console', (m) => {
    if (m.text().startsWith('[nav]') || m.type() === 'error') journal.push(m.text().slice(0, 600));
  });
  context.on('page', (p) =>
    p.on('framenavigated', (f) => {
      if (f === p.mainFrame()) journal.push(`відкрито ${f.url()}`);
    }),
  );
  return journal;
}

async function waitForServiceWorker(page: Page) {
  await page.evaluate(async () => {
    const reg = await navigator.serviceWorker.ready;
    if (!navigator.serviceWorker.controller) {
      await new Promise<void>((resolve) => {
        navigator.serviceWorker.addEventListener('controllerchange', () => resolve(), { once: true });
        setTimeout(resolve, 5_000);
      });
    }
    return Boolean(reg.active);
  });
}

test('словник без інтернету (§76): шукає серед слів на телефоні — з відкритого уроку', async ({ page, context, request }) => {
  test.slow();
  const sw = await request.get('/sw.js');
  test.skip(!sw.ok(), 'PWA вимкнено (npm run dev) — офлайн перевіряємо лише у збірці: npm run e2e');

  // Урок з інтернетом — його слова лягають у копію на телефоні
  await page.goto(`/lesson/${TEST_LESSON_ID}`);
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
  const lemma = await page.evaluate((key) => {
    const raw = localStorage.getItem(key);
    const words = raw ? (JSON.parse(raw) as { data?: { words?: { hr_text?: string }[] } }).data?.words : undefined;
    return words?.find((w) => (w.hr_text ?? '').trim().length > 2)?.hr_text?.trim() ?? '';
  }, `cs_offline_lesson_${TEST_LESSON_ID}`);
  expect(lemma, 'слово уроку в копії на телефоні').not.toBe('');

  await page.goto('/dictionary');
  await waitForServiceWorker(page);
  await page.reload(); // сторінку словника віддає service worker і кладе в кеш
  await expect(page.getByRole('heading', { level: 1, name: 'Практика' })).toBeVisible();

  await context.setOffline(true);
  try {
    await page.reload();
    await expect(page.getByTestId('dictionary-offline')).toBeVisible();
    await page.getByLabel('Пошук слова').fill(lemma);
    await expect(page.getByRole('list').getByText(lemma, { exact: true }).first()).toBeVisible();
  } finally {
    await context.setOffline(false);
  }
  // Інтернет повернувся — знову весь словник, без перезавантаження сторінки
  await expect(page.getByTestId('dictionary-offline')).toBeHidden({ timeout: 15_000 });
});

test('офлайн наперед (§76): наступні уроки модуля, тексти й фрази ситуацій відкриваються без інтернету', async ({ page, context, request }) => {
  test.slow();
  const sw = await request.get('/sw.js');
  test.skip(!sw.ok(), 'PWA вимкнено (npm run dev) — офлайн перевіряємо лише у збірці: npm run e2e');

  // Service worker має керувати сторінкою, інакше зберігати наперед нікуди
  await page.goto('/lessons');
  await waitForServiceWorker(page);
  await page.evaluate(() => localStorage.removeItem('cs_offline_prefetch_v1'));

  // Відкрили урок 1 — за кілька секунд на телефоні наступні уроки модуля й тексти модуля
  await page.goto(`/lesson/${TEST_LESSON_ID}`);
  await expect(page.getByRole('button', { name: 'Почати урок' })).toBeVisible();
  const cachedPaths = (prefix: string, exclude = '') =>
    page.evaluate(
      async ([p, ex]) => {
        const keys = await (await caches.open('pages')).keys();
        return keys.map((k) => new URL(k.url).pathname).filter((path) => path.startsWith(p) && (!ex || !path.endsWith(ex)));
      },
      [prefix, exclude] as const,
    );
  await expect
    .poll(async () => (await cachedPaths('/lesson/', TEST_LESSON_ID)).length, { timeout: 30_000, message: 'наступні уроки модуля в кеші' })
    .toBeGreaterThan(0);
  const nextLesson = (await cachedPaths('/lesson/', TEST_LESSON_ID))[0];
  await expect.poll(async () => (await cachedPaths('/reading/')).length, { timeout: 30_000, message: 'тексти модуля в кеші' }).toBeGreaterThan(0);
  const moduleText = (await cachedPaths('/reading/'))[0];

  // «Сьогодні» — ситуації з фразами
  await page.goto('/');
  await expect
    .poll(async () => (await cachedPaths('/situations/')).length, { timeout: 30_000, message: 'ситуації в кеші' })
    .toBeGreaterThan(0);
  const situation = (await cachedPaths('/situations/'))[0];

  await page.close();
  await context.setOffline(true);
  try {
    const lessonPage = await context.newPage();
    await lessonPage.goto(nextLesson);
    await expect(lessonPage.getByRole('button', { name: 'Почати урок' }), `${nextLesson} без мережі — ще не відкривали`).toBeVisible();
    await lessonPage.close();

    const textPage = await context.newPage();
    await textPage.goto(moduleText);
    await expect(textPage.getByRole('heading', { level: 1 }), `${moduleText} без мережі`).toBeVisible();
    await expect(textPage.getByText('Текст не знайдено')).toBeHidden();
    await textPage.close();

    const situationPage = await context.newPage();
    await situationPage.goto(situation);
    await expect(situationPage.getByRole('button', { name: 'Перевір себе' }), `${situation}: фрази без мережі`).toBeVisible();
    const dialogues = situationPage.getByRole('tab', { name: /^Діалоги/ });
    if (await dialogues.isEnabled()) {
      await dialogues.click();
      await expect(situationPage.getByTestId('situation-dialogues-online'), 'діалоги — лише з інтернетом').toBeVisible();
    }
  } finally {
    await context.setOffline(false);
  }
});

test('ARCH-03: рівні з опублікованими перевірками видно в «Перевірках» і на «Уроках» (A2)', async ({ page }) => {
  // Рівні беруться з бази, а не з переліку в коді: опубліковані перевірки A2 мають бути видні без правки коду
  await page.goto('/lessons/tests?level=A2');
  await expect(page.getByRole('heading', { level: 1, name: 'Перевірки рівня' })).toBeVisible();
  const levels = page.getByRole('navigation', { name: 'Рівень' });
  for (const l of ['A0', 'A1', 'A2']) await expect(levels.getByRole('link', { name: l, exact: true })).toBeVisible();
  await expect(levels.getByRole('link', { name: 'A2', exact: true })).toHaveAttribute('aria-current', 'page');
  await expect(page.getByText('Фінальна перевірка рівня A2')).toBeVisible();

  await page.goto('/lessons?level=A2');
  await expect(page.getByRole('link', { name: /Перевірки рівня A2/ })).toHaveAttribute('href', '/lessons/tests?level=A2');
  await expect(page.locator('a[href="/assessment/a2-m01"]')).toBeVisible();
  await expect(page.locator('a[href="/assessment/a2-final"]')).toBeVisible();
});
