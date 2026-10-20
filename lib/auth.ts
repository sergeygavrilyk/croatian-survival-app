/**
 * Вхід, реєстрація, новий пароль: тексти помилок Supabase Auth українською (без БД; тести — auth.test.ts).
 * Supabase повертає англійські повідомлення («Invalid login credentials») — користувач їх бачити не має.
 */

/** Мінімальна довжина нового пароля — як у налаштуваннях Supabase Auth проєкту (10, PROJECT_STATE «Безпека»). */
export const MIN_PASSWORD_LENGTH = 10;

const RULES: ReadonlyArray<[RegExp, string]> = [
  [/invalid login credentials/i, 'Неправильний email або пароль.'],
  [/email not confirmed/i, 'Пошту ще не підтверджено. Відкрийте лист від нас і натисніть посилання.'],
  [/user already registered|already been registered/i, 'Акаунт з цим email уже є. Увійдіть або відновіть пароль.'],
  [/password should be at least|password.*(short|length)/i, `Пароль має бути не коротший за ${MIN_PASSWORD_LENGTH} символів.`],
  [/weak|pwned|leaked|compromised/i, 'Цей пароль занадто простий або вже траплявся у витоках. Придумайте інший.'],
  [/different from the old|should be different/i, 'Новий пароль має відрізнятися від старого.'],
  [/rate limit|too many requests|security purposes/i, 'Забагато спроб. Зачекайте хвилину й спробуйте знову.'],
  [/invalid email|unable to validate email|email address .* invalid/i, 'Перевірте email — схоже, в адресі помилка.'],
  [/signups? not allowed|signup is disabled/i, 'Реєстрація зараз закрита.'],
  [/failed to fetch|network|fetch failed/i, 'Немає зв’язку з сервером. Перевірте інтернет і спробуйте ще раз.'],
];

/** Помилка Supabase Auth → зрозумілий український текст; невідома — загальний текст (без англійської). */
export function authErrorUk(message: string | null | undefined): string {
  const text = message ?? '';
  for (const [re, uk] of RULES) if (re.test(text)) return uk;
  return 'Не вдалося виконати дію. Спробуйте ще раз трохи згодом.';
}

/** Перевірка нового пароля перед відправкою: null — усе гаразд. */
export function newPasswordProblem(password: string, confirm?: string): string | null {
  if (password.length < MIN_PASSWORD_LENGTH) return `Пароль має бути не коротший за ${MIN_PASSWORD_LENGTH} символів.`;
  if (confirm !== undefined && password !== confirm) return 'Паролі не збігаються.';
  return null;
}
