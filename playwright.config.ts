import { defineConfig, devices } from '@playwright/test';
import { AUTH_FILE, HAS_USER } from './e2e/env';

/**
 * E2E (docs/TESTING.md §3). Запуск: `npm run e2e` (збірка + сервер на :3100 + усі сценарії)
 * або `npm run e2e:smoke` (лише без входу — так запускає CI).
 *
 * Тестовий акаунт — лише на комп'ютері власника: E2E_EMAIL і E2E_PASSWORD у .env.local
 * (файл у git не потрапляє). Без них сценарії з входом пропускаються.
 * Офлайн перевіряємо лише у збірці: у `npm run dev` PWA вимкнено.
 */
const PORT = Number(process.env.E2E_PORT ?? 3100);
const baseURL = process.env.E2E_BASE_URL ?? `http://localhost:${PORT}`;

export default defineConfig({
  testDir: 'e2e',
  timeout: 90_000,
  expect: { timeout: 15_000 },
  fullyParallel: false,
  workers: 1, // один тестовий акаунт — сценарії по черзі
  forbidOnly: Boolean(process.env.CI),
  retries: process.env.CI ? 1 : 0,
  reporter: [['list'], ['html', { open: 'never' }]],
  use: {
    ...devices['Pixel 7'], // застосунок — для телефона
    baseURL,
    locale: 'uk-UA',
    timezoneId: 'Europe/Zagreb',
    trace: 'retain-on-failure',
    screenshot: 'only-on-failure',
  },
  projects: [
    { name: 'smoke', testMatch: /smoke\.spec\.ts/ },
    { name: 'setup', testMatch: /auth\.setup\.ts/ },
    {
      name: 'user',
      testMatch: /user\.spec\.ts/,
      dependencies: ['setup'],
      use: { storageState: HAS_USER ? AUTH_FILE : undefined },
    },
  ],
  // Свій сервер на :3100, щоб не заважати `npm run dev` на :3000. У CI збірка вже є — лише запуск.
  webServer: process.env.E2E_BASE_URL
    ? undefined
    : {
        command: process.env.CI ? `npm run start -- -p ${PORT}` : `npm run build && npm run start -- -p ${PORT}`,
        url: baseURL,
        reuseExistingServer: false,
        timeout: 300_000,
        stdout: 'ignore',
        stderr: 'pipe',
      },
});
