-- Слова робочої бази для PR 4 «Дублі A2» (2026-11-19), яких немає в локальній копії (значення — з робочої бази). Лише для локальної перевірки.
-- Після M25: мітки обов’язкові.
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, status, source, register, regionality, usage_tags, forms, examples) values ('ispravljati', 'ispravljati', 'hr', 'verb', 'A2', 'виправляти', 'core', 'PUBLISHED', 'local_test', 'standard', 'general', '{}', '{"aspect": "ipfv"}'::jsonb, '["Učiteljica nam ispravlja zadaće."]'::jsonb) on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, status, source, register, regionality, usage_tags, forms, examples) values ('sudjelovati', 'sudjelovati', 'hr', 'verb', 'B1', 'брати участь', 'core', 'PUBLISHED', 'local_test', 'standard', 'general', '{}', '{"aspect": "ipfv"}'::jsonb, '["Želim sudjelovati u projektu."]'::jsonb) on conflict do nothing;
insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, vocabulary_type, status, source, register, regionality, usage_tags, forms, examples) values ('morska sol', 'morska sol', 'hr', 'phrase', 'A1', 'морська сіль', 'chunk', 'PUBLISHED', 'local_test', 'standard', 'general', '{}', '{}'::jsonb, '["Kupka s morskom soli."]'::jsonb) on conflict do nothing;
-- Переклади слів уроків A2 9, 27, 38, 70, які в локальній копії інші, ніж у робочій базі (звірено 2026-11-19), і рівень dokaz
update public.lexemes set ukrainian_translation = 'відвідувати; проходити' where lemma = 'pohađati' and source <> 'claude_a2_dupes';
update public.lexemes set ukrainian_translation = 'дискутувати' where lemma = 'raspravljati' and source <> 'claude_a2_dupes';
update public.lexemes set ukrainian_translation = 'обговорення, дискусія' where lemma = 'rasprava' and source <> 'claude_a2_dupes';
update public.lexemes set ukrainian_translation = 'замок (дверний)' where lemma = 'brava' and source <> 'claude_a2_dupes';
update public.lexemes set ukrainian_translation = 'оцінка (естімація)' where lemma = 'procjena' and source <> 'claude_a2_dupes';
update public.lexemes set ukrainian_translation = 'встановити; вбудувати' where lemma = 'ugraditi' and source <> 'claude_a2_dupes';
update public.lexemes set ukrainian_translation = 'екстрений виклик' where lemma = 'hitna intervencija' and source <> 'claude_a2_dupes';
update public.lexemes set ukrainian_translation = 'помаленьку / не поспішай' where lemma = 'pomalo' and source <> 'claude_a2_dupes';
update public.lexemes set cefr = 'B1' where lemma = 'dokaz' and cefr = 'A1';
