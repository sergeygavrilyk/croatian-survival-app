#!/usr/bin/env python3
"""
Старі приклади словника з українським перекладом у дужках або з кирилицею всередині слова (2026-10-21).
Знайдено тестом supabase/tests/lexemes_examples.test.sql («у прикладах немає кирилиці»): 21 приклад у 20 словах,
з часів до пакетів 2026-10-12 (наприклад «Prazna mi je baterija (У мене сіла батарея).», «rječнику», «Mama (розмовно).»).

  python3 -B scripts/gen_lexemes_examples_cleanup_20261021.py → supabase/data_fixes/20261021_lexemes_examples_cyrillic.sql

Кожен такий приклад замінюється чистим хорватським реченням зі словом-лемою. Замінюється лише рядок, що досі має
старий текст (повторний запуск нічого не змінює). Стара версія → content_versions, запис у content_reviews.
"""
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
from full_lessons import q  # noqa: E402
from lexeme_checks import check_example  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261021_lexemes_examples_cyrillic.sql'
NOTE = 'lexemes_examples_cyrillic_20261021: приклад без українського перекладу в дужках — стара версія'
REVIEW = ('Приклад очищено 2026-10-21: прибрано український переклад у дужках / кирилицю в реченні '
          '(scripts/gen_lexemes_examples_cleanup_20261021.py). Потрібна перевірка носієм.')

# (лема, старий приклад у базі, новий приклад)
FIXES = [
    ('baterija', 'Prazna mi je baterija (У мене сіла батарея).', 'Prazna mi je baterija.'),
    ('čuti', 'Čujemo se! (Зідзвонимось/почуємось)', 'Ne čujem te dobro, govori glasnije.'),
    ('djed', 'Dida (розмовно).', 'Djed svako jutro čita novine na balkonu.'),
    ('jugo', 'Ubio me jugo (болить голова від вітру).', 'Ubio me jugo, cijeli dan me boli glava.'),
    ('kako ide', 'Evo, pomalo (помаленьку).', 'Kako ide posao? Evo, pomalo.'),
    ('kasno', 'Oprostite, kasnim (я спізнююсь).', 'Već je kasno, idemo kući.'),
    ('kat', 'Živim u prizemlju (на першому / цокольному поверсі).', 'Živim na drugom katu, lijevo od lifta.'),
    ('kriv', 'Krivi broj (неправильний номер).', 'Oprostite, nazvali ste krivi broj.'),
    ('kriv', 'Ja sam kriv (я винен).', 'Oprosti, ja sam kriv.'),
    ('krv', 'Trebam izvaditi krv (здати кров).', 'Sutra ujutro moram izvaditi krv.'),
    ('kvar', 'Imamo kvar u kupaonici (проблема у ванній).', 'Imamo kvar u kupaonici, voda curi.'),
    ('liječnik', 'Opća praksa (сімейний лікар).', 'Moram se naručiti kod liječnika opće prakse.'),
    ('ljut', 'Ova paprika je jako ljuta (гострий).', 'Ova paprika je jako ljuta.'),
    ('majka', 'Mama (розмовно).', 'Moja majka živi u Kijevu.'),
    ('otac', 'Tata (розмовно).', 'Moj otac radi kao vozač autobusa.'),
    ('rječnik', 'Pronađite riječ u rječнику.', 'Pronađite riječ u rječniku.'),
    ('siguran', 'Jesi li siguran? (Ти впевнений?)', 'Jesi li siguran da je trgovina otvorena?'),
    ('star', 'Stari grad (Старе місто).', 'Stari grad je pun turista.'),
    ('šteta', 'Baš šteta! (Яка шкода!)', 'Baš šteta što ne možeš doći!'),
    ('vidjeti', 'Vidimo se! (Побачимось)', 'Jesi li vidjela moje ključeve?'),
    ('vrećica', 'Trebate li vrećicu? (Вам потрібен пакет?)', 'Trebate li vrećicu?'),
]


def validate():
    errors = []
    for lemma, old, new in FIXES:
        errors += [f'{lemma}: {e}' for e in check_example(lemma, new, strict_lemma=False)]
        if not re.search(r'[Ѐ-ӿ]', old):
            errors.append(f'{lemma}: у старому прикладі немає кирилиці — не той рядок')
    if errors:
        raise SystemExit('Помилки:\n  ' + '\n  '.join(errors))


def build() -> str:
    data = json.dumps([{'k': k, 'old': o, 'new': n} for k, o, n in FIXES], ensure_ascii=False, indent=0)
    return f"""-- =====================================================================
-- Приклади словника без українського перекладу в дужках · 2026-10-21
-- Згенеровано: python3 -B scripts/gen_lexemes_examples_cleanup_20261021.py (не редагуйте вручну).
--
--   * 21 старий приклад у 20 словах мав український переклад у дужках («Prazna mi je baterija (У мене сіла батарея).»),
--     кирилицю всередині слова («rječнику») або взагалі не був реченням («Mama (розмовно).»).
--   * Кожен замінюється чистим хорватським реченням; решта прикладів слова не змінюється.
--   * Змінюється лише рядок, що досі має старий текст — повторний запуск нічого не змінює.
--     Стара версія → content_versions, запис у content_reviews.
-- Після нього тест supabase/tests/lexemes_examples.test.sql має пройти («ALL TESTS PASSED»).
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

do $fix$
declare
  d record;
  r record;
  v_changed int := 0;
begin
  for d in select * from jsonb_to_recordset({q(data)}::jsonb) as t(k text, old text, new text)
  loop
    for r in select * from public.lexemes
              where lower(lemma) = d.k and examples @> jsonb_build_array(d.old)
    loop
      insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
      values ('lexeme', r.id,
              coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
              to_jsonb(r), {q(NOTE)});
      update public.lexemes set
        examples = (select coalesce(jsonb_agg(case when e = d.old then d.new else e end order by n), '[]'::jsonb)
                      from jsonb_array_elements_text(r.examples) with ordinality as x(e, n)),
        version = coalesce(version, 1) + 1
      where id = r.id;
      insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
      values ('lexeme', r.id, r.status, r.status, 'auto_passed', 'ai',
              jsonb_build_array(jsonb_build_object('old', d.old, 'new', d.new)), {q(REVIEW)});
      v_changed := v_changed + 1;
    end loop;
  end loop;
  raise notice 'Замінено прикладів зараз: %', v_changed;
end
$fix$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int;
begin
  select count(*) into v_bad from public.lexemes l, jsonb_array_elements_text(l.examples) e
   where l.status <> 'DEPRECATED' and e ~ '[Ѐ-ӿ]';
  if v_bad > 0 then raise exception 'Лишились приклади з кирилицею: %', v_bad; end if;
  raise notice 'Готово: у прикладах словника немає кирилиці';
end $$;

commit;
"""


if __name__ == '__main__':
    validate()
    OUT.write_text(build(), encoding='utf-8')
    print(f'{OUT.relative_to(ROOT)}: {OUT.stat().st_size // 1024} КБ, прикладів: {len(FIXES)}')
