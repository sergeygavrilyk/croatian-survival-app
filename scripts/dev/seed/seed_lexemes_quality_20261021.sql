-- Слова в стані робочої бази до чистки 20261021_lexemes_grammar_fields.sql (2026-10-21). Лише для локальної перевірки.
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, forms, examples, status, source) values
  ('čuvati', 'čuvati', 'hr', 'noun', 'B1', 'берегти', 'core', '{}', '[]', 'PUBLISHED', 'local_test'),
  ('četrdeset', 'četrdeset', 'hr', 'noun', 'A0', 'сорок', 'core', '{}', '[]', 'PUBLISHED', 'local_test'),
  ('domaćin', 'domaćin', 'hr', 'noun', 'A2', 'господар', 'core', '{"gender": "m"}', '[]', 'PUBLISHED', 'local_test'),
  ('dogovarati', 'dogovarati', 'hr', 'verb', 'A2', 'домовлятися', 'core', '{"aspect": "pfv"}', '[]', 'PUBLISHED', 'local_test'),
  ('baciti', 'baciti', 'hr', 'verb', 'A2', 'викинути', 'core', '{"aspect": "unspecified"}', '[]', 'PUBLISHED', 'local_test'),
  ('čestitati', 'čestitati', 'hr', 'verb', 'A2', 'вітати', 'core', '{"aspect": "impfv"}', '[]', 'PUBLISHED', 'local_test'),
  ('vzdahnuti', 'vzdahnuti', 'hr', null, 'B1', 'зівтнути', 'core', '{}', '[]', 'PUBLISHED', 'local_test'),
  ('Devizni račun', 'devizni račun', 'hr', null, 'A0', 'Валютний рахунок', 'core', '{}', '[]', 'PUBLISHED', 'local_test'),
  ('administracija', 'administracija', 'hr', null, 'B1', 'адміністрація', 'core', '{}', '[]', 'PUBLISHED', 'local_test'),
  ('vijesti', 'vijesti', 'hr', null, 'B1', 'новини', 'core', '{}', '[]', 'PUBLISHED', 'local_test'),
  ('smisao', 'smisao', 'hr', null, 'B1', 'сенс, значення', 'core', '{}', '[]', 'PUBLISHED', 'local_test'),
  ('korist', 'korist', 'hr', 'noun', 'B1', 'користь', 'core', '{}', '[]', 'PUBLISHED', 'local_test'),
  ('dobro', 'dobro', 'hr', 'word', 'A0', 'добре', 'core', '{}', '[]', 'PUBLISHED', 'local_test'),
  ('gdje je izlaz', 'gdje je izlaz', 'hr', 'word', 'A0', 'де вихід', 'core', '{}', '[]', 'PUBLISHED', 'local_test'),
  ('bojati se', 'bojati se', 'hr', 'verb', 'A1', 'боятися', 'core', '{}', '[]', 'PUBLISHED', 'local_test'),
  ('diviti se', 'diviti se', 'hr', 'noun', 'B1', 'захоплюватися', 'core', '{}', '[]', 'PUBLISHED', 'local_test')
on conflict (lower(lemma)) do update set
  lemma = excluded.lemma, normalized = excluded.normalized, part_of_speech = excluded.part_of_speech,
  ukrainian_translation = excluded.ukrainian_translation, forms = excluded.forms;
update public.lexemes set part_of_speech = 'noun', forms = '{}' where lower(lemma) = 'pametan';
update public.lexemes set normalized = 'hitna pomod' where lower(lemma) = 'hitna pomoć';
