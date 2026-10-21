import { expect, test, type Page } from '@playwright/test';
import { HAS_USER, NO_USER_REASON, TEST_LESSON_ID } from './env';

/**
 * Сценарії з тестовим акаунтом — лише на комп'ютері власника (`npm run e2e`), не в CI.
 * Пишуть у робочу базу лише прогрес тестового акаунта (lesson_progress, повторення, події).
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

test('урок від початку до святкового екрана: прогрес збережено', async ({ page }) => {
  test.slow(); // 15 вправ, кожна неправильна — ще раз наприкінці
  await page.goto(`/lesson/${TEST_LESSON_ID}`);
  await expect(page.getByRole('heading', { level: 1 })).toBeVisible();
  await page.getByRole('button', { name: 'Почати урок' }).click();

  await walkThroughLesson(page);

  await expect(page.getByRole('heading', { name: 'Урок пройдено!' })).toBeVisible();
  await expect(page.getByText('Зберігаємо прогрес…')).toBeHidden({ timeout: 30_000 });
  await expect(page.getByText('Не вдалося зберегти прогрес')).toHaveCount(0);
  await expect(page.getByRole('link', { name: 'До уроків' })).toHaveAttribute('href', /^\/lessons/);
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
  // (У першій версії обидві відкривались в одній вкладці через адресний рядок, і щойно відкрита офлайн
  // сторінка уроку перебивала перехід на текст повторним завантаженням самої себе — див. HISTORY 2026-10-21.)
  await page.close();
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

    // Як людина в застосунку: без мережі «Читання» → натиснути на текст (перехід усередині застосунку)
    const listPage = await context.newPage();
    await listPage.goto('/reading');
    await listPage.locator(`a[href="${textPath}"]`).first().click();
    await expect(listPage).toHaveURL(new RegExp(`${textPath}$`));
    await expect(listPage.getByRole('heading', { level: 1, name: textTitle }), 'перехід зі списку без мережі').toBeVisible();
  } finally {
    await context.setOffline(false);
  }
});

// ------------------------------------------------------------------ помічники

/** Пройти етапи уроку й вправи до підсумку. Відповідаємо «не знаю» / пропускаємо / перший варіант:
 *  неправильна вправа повторюється один раз, тож урок усе одно доходить до кінця. */
async function walkThroughLesson(page: Page) {
  const done = page.getByRole('heading', { name: 'Урок пройдено!' });
  const exact = (name: string) => page.getByRole('button', { name, exact: true });
  const stageNext = [exact('Далі'), exact('Наступний діалог'), exact('До вправ')];
  const giveUp = exact('Не знаю — показати');
  const skipSpeech = page.getByRole('button', { name: /^(Не можу говорити зараз|Пропустити й іти далі)$/ });
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
