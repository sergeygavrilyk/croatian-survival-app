import { test } from 'node:test';
import assert from 'node:assert/strict';
import { MIN_PASSWORD_LENGTH, authErrorUk, newPasswordProblem } from './auth.ts';

test('authErrorUk: типові помилки Supabase — українською', () => {
  assert.equal(authErrorUk('Invalid login credentials'), 'Неправильний email або пароль.');
  assert.match(authErrorUk('Email not confirmed'), /не підтверджено/);
  assert.match(authErrorUk('User already registered'), /уже є/);
  assert.match(authErrorUk('Password should be at least 10 characters.'), /не коротший за 10/);
  assert.match(authErrorUk('New password should be different from the old password.'), /відрізнятися/);
  assert.match(authErrorUk('For security purposes, you can only request this after 42 seconds.'), /Забагато спроб/);
  assert.match(authErrorUk('Failed to fetch'), /інтернет/);
});

test('authErrorUk: невідома помилка — без англійської', () => {
  const text = authErrorUk('Something unexpected happened');
  assert.doesNotMatch(text, /[A-Za-z]/);
  assert.equal(authErrorUk(undefined), text);
});

test('newPasswordProblem: довжина й збіг паролів', () => {
  assert.equal(MIN_PASSWORD_LENGTH, 10);
  assert.match(newPasswordProblem('short1') ?? '', /10 символів/);
  assert.equal(newPasswordProblem('dovoljno-dug'), null);
  assert.equal(newPasswordProblem('dovoljno-dug', 'drugi-pass1'), 'Паролі не збігаються.');
  assert.equal(newPasswordProblem('dovoljno-dug', 'dovoljno-dug'), null);
});
