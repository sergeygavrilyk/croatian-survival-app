-- =====================================================================
-- Регістр наявних слів словника · 2026-11-12
-- Згенеровано: python3 -B scripts/gen_lexeme_register_20261112.py (не редагуйте вручну).
-- Рішення власника 2026-11-12: «Необхідно зробити скріпт, який порівняє лексеми в DB supabase та проставить їм
--   визначеннями в CONTENT_PIPELINE.md: informal — літературне, але неофіційне (bok, ćao, Kako si? замість Kako ste?);
--   colloquial — розмовне, нелітературне (kužiti, frka); slang — мова групи (frend, fora)».
-- Що робить: ставить lexemes.register 34 опублікованим словам (informal 25, colloquial 9, slang 0) — ЛИШЕ там, де register порожній.
--   Не змінює: наявний register (ae, onak — slang; pomidor, kapula, šugaman — regional, нормалізує пакет M24),
--   переклади, regionality, DEPRECATED слова. Стара версія — у content_versions, запис — у content_reviews.
--   Слова, яких немає в базі, пропускає. Повторний запуск нічого не змінює.
-- Звіт для носія: content/reviews/2026-11-12_lexeme_register.md.
-- Після нього: тест supabase/tests/lexeme_register.test.sql → «ALL TESTS PASSED».
-- Очікуване повідомлення: «Готово: позначено …, уже було …, пропущено (немає / інший регістр) …».
-- =====================================================================

begin;

do $fix$
declare
  w record;
  x public.lexemes%rowtype;
  v_set int := 0;
  v_same int := 0;
  v_skip int := 0;
begin
  for w in select * from jsonb_to_recordset('[{"lemma": "a ti", "register": "informal"}, {"lemma": "bok", "register": "informal"}, {"lemma": "čekaj", "register": "informal"}, {"lemma": "cimerica", "register": "colloquial"}, {"lemma": "čujemo se", "register": "informal"}, {"lemma": "cura", "register": "colloquial"}, {"lemma": "fjaka", "register": "colloquial"}, {"lemma": "gablec", "register": "colloquial"}, {"lemma": "gušt", "register": "colloquial"}, {"lemma": "i tebi", "register": "informal"}, {"lemma": "izvoli", "register": "informal"}, {"lemma": "javi se", "register": "informal"}, {"lemma": "javit ću ti", "register": "informal"}, {"lemma": "kako se osjećaš", "register": "informal"}, {"lemma": "kako se zoveš", "register": "informal"}, {"lemma": "kako si", "register": "informal"}, {"lemma": "kila", "register": "colloquial"}, {"lemma": "koliko imaš godina", "register": "informal"}, {"lemma": "marenda", "register": "colloquial"}, {"lemma": "molim te", "register": "informal"}, {"lemma": "može", "register": "informal"}, {"lemma": "nedostaješ mi", "register": "informal"}, {"lemma": "nisam te čuo", "register": "informal"}, {"lemma": "nisi u pravu", "register": "informal"}, {"lemma": "odakle si", "register": "informal"}, {"lemma": "odgovara li ti", "register": "informal"}, {"lemma": "oprosti", "register": "informal"}, {"lemma": "pazi", "register": "informal"}, {"lemma": "spiza", "register": "colloquial"}, {"lemma": "super", "register": "colloquial"}, {"lemma": "u pravu si", "register": "informal"}, {"lemma": "vidimo se", "register": "informal"}, {"lemma": "zaslužio si", "register": "informal"}, {"lemma": "želim ti", "register": "informal"}]'::jsonb) as t(lemma text, register text)
  loop
    select * into x from public.lexemes where lower(lemma) = w.lemma and status = 'PUBLISHED';
    if x.id is null or (x.register is not null and x.register <> w.register) then
      v_skip := v_skip + 1;
      continue;
    end if;
    if x.register = w.register then
      v_same := v_same + 1;
      continue;
    end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), 'lexeme_register 2026-11-12: позначено регістр за визначеннями docs/CONTENT_PIPELINE.md «Регістр лексем» (рішення власника 2026-11-12); скрипт scripts/gen_lexeme_register_20261112.py, бета — носій перевіряє після.');
    update public.lexemes
       set register = w.register, version = coalesce(version, 1) + 1, updated_at = now()
     where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', x.id, 'PUBLISHED', 'PUBLISHED', 'auto_passed', 'script', '[]'::jsonb, 'lexeme_register 2026-11-12: позначено регістр за визначеннями docs/CONTENT_PIPELINE.md «Регістр лексем» (рішення власника 2026-11-12); скрипт scripts/gen_lexeme_register_20261112.py, бета — носій перевіряє після.' || ' register: ' || w.register || '.');
    v_set := v_set + 1;
  end loop;

  -- Самоперевірка: у опублікованих словах лише дозволені й старі значення
  if exists (select 1 from public.lexemes where status = 'PUBLISHED' and register is not null
              and register not in ('informal', 'colloquial', 'slang', 'formal', 'vulgar', 'regional', 'non_standard')) then
    raise exception 'register поза переліком: %', (select string_agg(distinct register, ', ') from public.lexemes
      where status = 'PUBLISHED' and register not in ('informal', 'colloquial', 'slang', 'formal', 'vulgar', 'regional', 'non_standard'));
  end if;
  raise notice 'Готово: позначено %, уже було %, пропущено (немає / інший регістр) %', v_set, v_same, v_skip;
end
$fix$;

commit;
