-- =====================================================================
-- Проблемні слова словника A0 — виправлення · 2026-10-20
-- Згенеровано: python3 -B scripts/gen_lexemes_fix_20261020.py (не редагуйте вручну).
--
-- Рішення власника 2026-10-20: «Виправити» (не DEPRECATED). Список — content/reviews/2026-10-12_curriculum_a0_v1.md.
--   * 8 заглушок «базовий термін (A0)» (bijela mačka, crna mačka, mali pas, veliki pas, novi / stari / brzi / spori auto) —
--     справжній переклад, приклад, normalized без діакритики, рід, тип «сполучення».
--   * 8 діалектних / розмовних / сербських слів (pomidor, kapula, šugaman, apoteka, kompjuter, da li govorite engleski, ae, onak) —
--     лишаються в словнику, але з позначкою в перекладі й стандартним відповідником (rajčica, luk, ručnik, ljekarna, računalo,
--     Govorite li engleski?); register / regionality / пояснення; рівень A0 → A2. «Onak» → «onak» (лема з малої).
--   * Стара версія кожного слова — у content_versions; запис у content_reviews. Слово змінюється, лише якщо переклад досі старий,
--     тож повторний запуск нічого не змінює. У жодному уроці й вправі цих слів немає.
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
  "key": "bijela mačka",
  "old": "базовий термін (A0)",
  "lemma": "bijela mačka",
  "normalized": "bijela macka",
  "ua": "біла кішка",
  "pos": "phrase",
  "vtype": "collocation",
  "cefr": "A0",
  "register": null,
  "regionality": null,
  "expl": null,
  "forms": {
   "gender": "f"
  },
  "examples": [
   "Na prozoru sjedi bijela mačka."
  ]
 },
 {
  "key": "crna mačka",
  "old": "базовий термін (A0)",
  "lemma": "crna mačka",
  "normalized": "crna macka",
  "ua": "чорна кішка",
  "pos": "phrase",
  "vtype": "collocation",
  "cefr": "A0",
  "register": null,
  "regionality": null,
  "expl": null,
  "forms": {
   "gender": "f"
  },
  "examples": [
   "Crna mačka spava na kauču."
  ]
 },
 {
  "key": "mali pas",
  "old": "базовий термін (A0)",
  "lemma": "mali pas",
  "normalized": "mali pas",
  "ua": "маленький собака, песик",
  "pos": "phrase",
  "vtype": "collocation",
  "cefr": "A0",
  "register": null,
  "regionality": null,
  "expl": null,
  "forms": {
   "gender": "m"
  },
  "examples": [
   "Susjeda ima malog psa."
  ]
 },
 {
  "key": "veliki pas",
  "old": "базовий термін (A0)",
  "lemma": "veliki pas",
  "normalized": "veliki pas",
  "ua": "великий собака",
  "pos": "phrase",
  "vtype": "collocation",
  "cefr": "A0",
  "register": null,
  "regionality": null,
  "expl": null,
  "forms": {
   "gender": "m"
  },
  "examples": [
   "Pazi, u dvorištu je veliki pas!"
  ]
 },
 {
  "key": "novi auto",
  "old": "базовий термін (A0)",
  "lemma": "novi auto",
  "normalized": "novi auto",
  "ua": "нова машина, нове авто",
  "pos": "phrase",
  "vtype": "collocation",
  "cefr": "A0",
  "register": null,
  "regionality": null,
  "expl": null,
  "forms": {
   "gender": "m"
  },
  "examples": [
   "Kupili smo novi auto."
  ]
 },
 {
  "key": "stari auto",
  "old": "базовий термін (A0)",
  "lemma": "stari auto",
  "normalized": "stari auto",
  "ua": "стара машина, старе авто",
  "pos": "phrase",
  "vtype": "collocation",
  "cefr": "A0",
  "register": null,
  "regionality": null,
  "expl": null,
  "forms": {
   "gender": "m"
  },
  "examples": [
   "Prodajem stari auto."
  ]
 },
 {
  "key": "brzi auto",
  "old": "базовий термін (A0)",
  "lemma": "brzi auto",
  "normalized": "brzi auto",
  "ua": "швидка машина, швидке авто",
  "pos": "phrase",
  "vtype": "collocation",
  "cefr": "A0",
  "register": null,
  "regionality": null,
  "expl": null,
  "forms": {
   "gender": "m"
  },
  "examples": [
   "Marko vozi brzi auto."
  ]
 },
 {
  "key": "spori auto",
  "old": "базовий термін (A0)",
  "lemma": "spori auto",
  "normalized": "spori auto",
  "ua": "повільна машина, повільне авто",
  "pos": "phrase",
  "vtype": "collocation",
  "cefr": "A0",
  "register": null,
  "regionality": null,
  "expl": null,
  "forms": {
   "gender": "m"
  },
  "examples": [
   "Iza nas vozi jedan spori auto."
  ]
 },
 {
  "key": "pomidor",
  "old": "помідор",
  "lemma": "pomidor",
  "normalized": "pomidor",
  "ua": "помідор (діалект, Далмація; стандартно — rajčica)",
  "pos": "noun",
  "vtype": "core",
  "cefr": "A2",
  "register": "regional",
  "regionality": "Dalmatia",
  "expl": "Діалектне слово (Далмація). У стандартній хорватській — rajčica.",
  "forms": null,
  "examples": null
 },
 {
  "key": "kapula",
  "old": "цибуля",
  "lemma": "kapula",
  "normalized": "kapula",
  "ua": "цибуля (діалект, Далмація; стандартно — luk)",
  "pos": "noun",
  "vtype": "core",
  "cefr": "A2",
  "register": "regional",
  "regionality": "Dalmatia",
  "expl": "Діалектне слово (Далмація). У стандартній хорватській — luk.",
  "forms": null,
  "examples": [
   "Za salatu trebam jednu kapulu."
  ]
 },
 {
  "key": "šugaman",
  "old": "рушник",
  "lemma": "šugaman",
  "normalized": "sugaman",
  "ua": "рушник (діалект, Далмація; стандартно — ručnik)",
  "pos": "noun",
  "vtype": "core",
  "cefr": "A2",
  "register": "regional",
  "regionality": "Dalmatia",
  "expl": "Діалектне слово (Далмація). У стандартній хорватській — ručnik.",
  "forms": null,
  "examples": null
 },
 {
  "key": "apoteka",
  "old": "аптека",
  "lemma": "apoteka",
  "normalized": "apoteka",
  "ua": "аптека (розмовне; стандартно — ljekarna)",
  "pos": "noun",
  "vtype": "core",
  "cefr": "A2",
  "register": "colloquial",
  "regionality": null,
  "expl": "Розмовне слово (стандартне в Сербії та Боснії). У стандартній хорватській — ljekarna.",
  "forms": null,
  "examples": [
   "Je li apoteka još otvorena?"
  ]
 },
 {
  "key": "kompjuter",
  "old": "комп''ютер",
  "lemma": "kompjuter",
  "normalized": "kompjuter",
  "ua": "комп’ютер (розмовне; стандартно — računalo)",
  "pos": "noun",
  "vtype": "core",
  "cefr": "A2",
  "register": "colloquial",
  "regionality": null,
  "expl": "Розмовне слово. У стандартній хорватській — računalo.",
  "forms": null,
  "examples": null
 },
 {
  "key": "da li govorite engleski",
  "old": "чи розмовляєте ви англійською",
  "lemma": "da li govorite engleski",
  "normalized": "da li govorite engleski",
  "ua": "чи розмовляєте ви англійською (сербська конструкція; хорватською — Govorite li engleski?)",
  "pos": "phrase",
  "vtype": "chunk",
  "cefr": "A2",
  "register": "non_standard",
  "regionality": null,
  "expl": "Питання з «da li…» — сербська конструкція. У хорватській: Govorite li engleski?",
  "forms": null,
  "examples": null
 },
 {
  "key": "ae",
  "old": "так / ага / згоден",
  "lemma": "ae",
  "normalized": "ae",
  "ua": "так, ага (сленг, Далмація)",
  "pos": "particle",
  "vtype": "formulaic",
  "cefr": "A2",
  "register": "slang",
  "regionality": "Dalmatia",
  "expl": "Розмовне «так, ага» в Далмації. Нейтрально — da.",
  "forms": null,
  "examples": null
 },
 {
  "key": "onak",
  "old": "Типу / Якось так",
  "lemma": "onak",
  "normalized": "onak",
  "ua": "ну, типу; якось так (сленг, Загреб)",
  "pos": "adverb",
  "vtype": "formulaic",
  "cefr": "A2",
  "register": "slang",
  "regionality": "Zagreb",
  "expl": "Розмовне слово-паразит у Загребі (від onako — «так, отак»). У нейтральній мові не вживається.",
  "forms": null,
  "examples": null
 }
]'::jsonb)
             as t(key text, old text, lemma text, normalized text, ua text, pos text, vtype text, cefr text,
                  register text, regionality text, expl text, forms jsonb, examples jsonb)
  loop
    for r in select * from public.lexemes where lower(lemma) = d.key and ukrainian_translation = d.old loop
      insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
      values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
              to_jsonb(r), 'lexemes_fix_20261020: проблемне слово словника A0 виправлено за рішенням власника 2026-10-20 — стара версія');
      update public.lexemes set
        lemma = d.lemma, normalized = d.normalized, ukrainian_translation = d.ua, part_of_speech = d.pos,
        vocabulary_type = d.vtype, cefr = d.cefr,
        register = coalesce(d.register, register), regionality = coalesce(d.regionality, regionality),
        ukrainian_explanation = coalesce(d.expl, ukrainian_explanation),
        forms = coalesce(d.forms, forms), examples = coalesce(d.examples, examples)
      where id = r.id;
      insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
      values ('lexeme', r.id, r.status, r.status, 'auto_passed', 'ai', '[]'::jsonb, 'Виправлено за рішенням власника 2026-10-20 (проблемні слова словника A0, content/reviews/2026-10-12_curriculum_a0_v1.md). Потрібна перевірка носієм.');
      v_changed := v_changed + 1;
    end loop;
  end loop;
  raise notice 'Змінено слів зараз: %', v_changed;
end
$fix$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_bad int; v_fixed int;
begin
  select count(*) into v_bad from public.lexemes
   where status = 'PUBLISHED' and (ukrainian_translation = 'базовий термін (A0)' or lemma = 'Onak'
     or (lower(lemma) in ('pomidor', 'kapula', 'šugaman', 'apoteka', 'kompjuter', 'da li govorite engleski', 'ae', 'onak')
         and (cefr = 'A0' or ukrainian_translation !~ '(діалект|розмовне|сербська|сленг)')));
  select count(*) into v_fixed from public.content_reviews where notes = 'Виправлено за рішенням власника 2026-10-20 (проблемні слова словника A0, content/reviews/2026-10-12_curriculum_a0_v1.md). Потрібна перевірка носієм.';
  if v_bad > 0 then raise exception 'Лишилось проблемних слів: %', v_bad; end if;
  raise notice 'Готово: проблемні слова словника A0 виправлено (записів у журналі перевірки: %)', v_fixed;
end $$;

commit;
