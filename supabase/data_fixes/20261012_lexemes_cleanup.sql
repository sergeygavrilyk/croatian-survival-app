-- 2026-10-12 · Очищення lexemes від заглушок і зламаних записів
-- Виконано Claude з дозволу власника продукту.
-- Резервна копія таблиці до змін: backup.lexemes_20261012 (3387 рядків).
-- Відкат одного рядка: update public.lexemes l set examples = b.examples from backup.lexemes_20261012 b where b.id = l.id and l.lemma = '...';

begin;

-- 1. Шаблонні приклади-заглушки → порожній список (слова лишаються)
update public.lexemes
set examples = '[]'::jsonb, version = coalesce(version, 1) + 1
where examples::text ~ '(Važno je .* u ovoj situaciji|dio svakodnevnog života|često se koristi u svakodnevnom govoru|Primjer rečenice|To je vrlo [a-zčćđšž]+\.)';

-- 2. Перед видаленням дублікатів — переносимо ширші переклади в правильні записи
update public.lexemes set ukrainian_translation = 'річ; предмет; справа', version = coalesce(version, 1) + 1 where lemma = 'stvar';
update public.lexemes set ukrainian_translation = 'причина; привід',      version = coalesce(version, 1) + 1 where lemma = 'razlog';

-- 3. Зламані дублікати (змішана кирилиця/латиниця, сербська кирилиця, «x -> y», одруківка), для яких є правильний запис
delete from public.lexemes
where lemma in (
  'isприčati se', 'контейнер -> kontejner', 'оčaj', 'osobna iskazenica', 'поštar',
  'пожар', 'пожар -> požar', 'раздвојити -> razdvojiti', 'разлог', 'разлог -> razlog',
  'развој', 'развој -> razvoj', 'stвар'
);

-- 4. Зламані записи без правильної пари — виправляємо написання
update public.lexemes set lemma = 'pogreška',            normalized = 'pogreska',            version = coalesce(version, 1) + 1 where lemma = 'pogreшка';
update public.lexemes set lemma = 'poštanski sandučić',  normalized = 'postanski sanducic',  version = coalesce(version, 1) + 1 where lemma = 'поštanski sandučić';
update public.lexemes set lemma = 'predstaviti se',      normalized = 'predstaviti se',      version = coalesce(version, 1) + 1 where lemma = 'представити се -> predstaviti se';
update public.lexemes set lemma = 'složenost',           normalized = 'slozenost',           version = coalesce(version, 1) + 1 where lemma = 'сложеност -> složenost';
update public.lexemes set lemma = 'Ljekarnik: Uzmite ove pastile. Tri puta dnevno poslije jela.',
                          normalized = 'ljekarnik: uzmite ove pastile. tri puta dnevno poslije jela.',
                          version = coalesce(version, 1) + 1
where lemma = 'Ljekarnik: Uzмите ove pastile. Tri puta dnevno poslije jela.';

-- 5. «li» мав переклад «li»
update public.lexemes
set ukrainian_translation = 'чи (питальна частка)', part_of_speech = 'particle',
    vocabulary_type = 'function_word', cefr = 'A1', version = coalesce(version, 1) + 1
where lemma = 'li';

commit;
