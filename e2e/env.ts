/**
 * Змінні E2E. Тестовий акаунт: E2E_EMAIL і E2E_PASSWORD — у .env.local (у git не потрапляє) або в секретах GitHub
 * для CI (робота e2e-user, з 2026-11-14). Без них сценарії з входом пропускаються.
 */
try {
  process.loadEnvFile('.env.local');
} catch {
  // немає .env.local (CI) — змінні приходять із середовища
}

export const AUTH_FILE = 'e2e/.auth/user.json';
export const E2E_EMAIL = process.env.E2E_EMAIL ?? '';
export const E2E_PASSWORD = process.env.E2E_PASSWORD ?? '';
export const HAS_USER = Boolean(E2E_EMAIL && E2E_PASSWORD);
export const NO_USER_REASON = 'Немає E2E_EMAIL / E2E_PASSWORD у .env.local — сценарії з входом пропущено';

/** Тестовий урок з CLAUDE.md (опублікований, A0). */
export const TEST_LESSON_ID = process.env.E2E_LESSON_ID ?? 'c0000000-0000-0000-0000-000000000001';
