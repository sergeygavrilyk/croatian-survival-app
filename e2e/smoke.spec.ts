import { expect, test } from '@playwright/test';

/**
 * Smoke — без входу й без бази: працює і в CI (підставні адреси Supabase), і на комп'ютері власника.
 * Перевіряє, що збірка відкривається, захищені сторінки ведуть на вхід, а PWA зібрано.
 */

test('вхід: форма українською, перемикач «Реєстрація»', async ({ page }) => {
  await page.goto('/login');
  await expect(page.locator('html')).toHaveAttribute('lang', 'uk');
  await expect(page.getByRole('heading', { level: 1, name: 'Раді вас бачити!' })).toBeVisible();
  await expect(page.getByLabel('Email')).toBeVisible();
  await expect(page.getByLabel('Пароль')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Увійти' })).toBeVisible();

  await page.getByRole('button', { name: 'Реєстрація' }).click();
  await expect(page.getByRole('heading', { level: 1, name: 'Почнімо!' })).toBeVisible();
  await expect(page.getByText(/Щонайменше \d+ символів/)).toBeVisible();
  await expect(page.getByRole('button', { name: 'Створити акаунт' })).toBeVisible();
});

for (const path of ['/lessons', '/lessons?level=A1', '/lesson/c0000000-0000-0000-0000-000000000001']) {
  test(`без входу ${path} → сторінка входу`, async ({ page }) => {
    await page.goto(path);
    await expect(page).toHaveURL(/\/login(\?|$)/);
    await expect(page.getByRole('heading', { level: 1, name: 'Раді вас бачити!' })).toBeVisible();
  });
}

test('текст для читання з хибною адресою — «Текст не знайдено» і шлях назад', async ({ page }) => {
  await page.goto('/reading/not-a-text');
  await expect(page.getByRole('heading', { name: 'Текст не знайдено' })).toBeVisible();
  await expect(page.getByRole('link', { name: 'До текстів' })).toHaveAttribute('href', '/reading');
});

test('PWA зібрано: маніфест і service worker віддаються', async ({ request }) => {
  const manifest = await request.get('/manifest.json');
  expect(manifest.ok()).toBe(true);
  const json = (await manifest.json()) as { name?: string; icons?: unknown[] };
  expect(json.name).toBeTruthy();
  expect(json.icons?.length).toBeGreaterThan(0);

  const sw = await request.get('/sw.js');
  expect(sw.ok(), 'public/sw.js з\'являється лише після npm run build').toBe(true);
});
