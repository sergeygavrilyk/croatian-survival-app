/** Українські форми множини: pluralUk(5, ['фраза', 'фрази', 'фраз']) → «фраз». */
export function pluralUk(n: number, forms: readonly [string, string, string]): string {
  const abs = Math.abs(Math.trunc(n));
  const mod10 = abs % 10;
  const mod100 = abs % 100;
  if (mod10 === 1 && mod100 !== 11) return forms[0];
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return forms[1];
  return forms[2];
}

/** «9 фраз», «1 діалог». */
export function countUk(n: number, forms: readonly [string, string, string]): string {
  return `${n} ${pluralUk(n, forms)}`;
}
