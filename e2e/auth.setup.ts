import { expect, test as setup } from '@playwright/test';
import { AUTH_FILE, E2E_EMAIL, E2E_PASSWORD, HAS_USER, NO_USER_REASON } from './env';

/**
 * Вхід тестовим акаунтом один раз перед сценаріями `user`; сесія — у e2e/.auth/user.json (у git не потрапляє).
 * Акаунт має вже пройти онбординг (раз вручну) — інакше «Сьогодні» веде на /onboarding.
 */
setup('вхід тестовим акаунтом', async ({ page }) => {
  setup.skip(!HAS_USER, NO_USER_REASON);

  await page.goto('/login');
  await page.getByLabel('Email').fill(E2E_EMAIL);
  await page.getByLabel('Пароль').fill(E2E_PASSWORD);
  await page.getByRole('button', { name: 'Увійти' }).click();

  await page.waitForURL((url) => !url.pathname.startsWith('/login'), { timeout: 30_000 }).catch(async () => {
    const alert = await page.getByRole('alert').first().textContent().catch(() => null);
    throw new Error(`Не вдалося увійти тестовим акаунтом${alert ? `: ${alert.trim()}` : ''}. Перевірте E2E_EMAIL / E2E_PASSWORD у .env.local.`);
  });
  if (new URL(page.url()).pathname.startsWith('/onboarding')) {
    throw new Error('Тестовий акаунт ще не пройшов онбординг: увійдіть ним раз вручну й пройдіть його до кінця.');
  }
  await expect(page.getByRole('navigation').first()).toBeVisible();

  await page.context().storageState({ path: AUTH_FILE });
});
