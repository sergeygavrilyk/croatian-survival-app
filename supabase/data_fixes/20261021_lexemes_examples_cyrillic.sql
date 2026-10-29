-- =====================================================================
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
  for d in select * from jsonb_to_recordset('[
{
"k": "baterija",
"old": "Prazna mi je baterija (У мене сіла батарея).",
"new": "Prazna mi je baterija."
},
{
"k": "čuti",
"old": "Čujemo se! (Зідзвонимось/почуємось)",
"new": "Ne čujem te dobro, govori glasnije."
},
{
"k": "djed",
"old": "Dida (розмовно).",
"new": "Djed svako jutro čita novine na balkonu."
},
{
"k": "jugo",
"old": "Ubio me jugo (болить голова від вітру).",
"new": "Ubio me jugo, cijeli dan me boli glava."
},
{
"k": "kako ide",
"old": "Evo, pomalo (помаленьку).",
"new": "Kako ide posao? Evo, pomalo."
},
{
"k": "kasno",
"old": "Oprostite, kasnim (я спізнююсь).",
"new": "Već je kasno, idemo kući."
},
{
"k": "kat",
"old": "Živim u prizemlju (на першому / цокольному поверсі).",
"new": "Živim na drugom katu, lijevo od lifta."
},
{
"k": "kriv",
"old": "Krivi broj (неправильний номер).",
"new": "Oprostite, nazvali ste krivi broj."
},
{
"k": "kriv",
"old": "Ja sam kriv (я винен).",
"new": "Oprosti, ja sam kriv."
},
{
"k": "krv",
"old": "Trebam izvaditi krv (здати кров).",
"new": "Sutra ujutro moram izvaditi krv."
},
{
"k": "kvar",
"old": "Imamo kvar u kupaonici (проблема у ванній).",
"new": "Imamo kvar u kupaonici, voda curi."
},
{
"k": "liječnik",
"old": "Opća praksa (сімейний лікар).",
"new": "Moram se naručiti kod liječnika opće prakse."
},
{
"k": "ljut",
"old": "Ova paprika je jako ljuta (гострий).",
"new": "Ova paprika je jako ljuta."
},
{
"k": "majka",
"old": "Mama (розмовно).",
"new": "Moja majka živi u Kijevu."
},
{
"k": "otac",
"old": "Tata (розмовно).",
"new": "Moj otac radi kao vozač autobusa."
},
{
"k": "rječnik",
"old": "Pronađite riječ u rječнику.",
"new": "Pronađite riječ u rječniku."
},
{
"k": "siguran",
"old": "Jesi li siguran? (Ти впевнений?)",
"new": "Jesi li siguran da je trgovina otvorena?"
},
{
"k": "star",
"old": "Stari grad (Старе місто).",
"new": "Stari grad je pun turista."
},
{
"k": "šteta",
"old": "Baš šteta! (Яка шкода!)",
"new": "Baš šteta što ne možeš doći!"
},
{
"k": "vidjeti",
"old": "Vidimo se! (Побачимось)",
"new": "Jesi li vidjela moje ključeve?"
},
{
"k": "vrećica",
"old": "Trebate li vrećicu? (Вам потрібен пакет?)",
"new": "Trebate li vrećicu?"
}
]'::jsonb) as t(k text, old text, new text)
  loop
    for r in select * from public.lexemes
              where lower(lemma) = d.k and examples @> jsonb_build_array(d.old)
    loop
      insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
      values ('lexeme', r.id,
              coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
              to_jsonb(r), 'lexemes_examples_cyrillic_20261021: приклад без українського перекладу в дужках — стара версія');
      update public.lexemes set
        examples = (select coalesce(jsonb_agg(case when e = d.old then d.new else e end order by n), '[]'::jsonb)
                      from jsonb_array_elements_text(r.examples) with ordinality as x(e, n)),
        version = coalesce(version, 1) + 1
      where id = r.id;
      insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
      values ('lexeme', r.id, r.status, r.status, 'auto_passed', 'ai',
              jsonb_build_array(jsonb_build_object('old', d.old, 'new', d.new)), 'Приклад очищено 2026-10-21: прибрано український переклад у дужках / кирилицю в реченні (scripts/gen_lexemes_examples_cleanup_20261021.py). Потрібна перевірка носієм.');
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
