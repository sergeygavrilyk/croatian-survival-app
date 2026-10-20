#!/usr/bin/env python3
"""
Виправлення проблемних слів словника A0 (рішення власника 2026-10-20: «Виправити», не DEPRECATED).
Джерело списку: content/reviews/2026-10-12_curriculum_a0_v1.md → «Проблеми наявного словника A0».

  python3 -B scripts/gen_lexemes_fix_20261020.py  →  supabase/data_fixes/20261020_lexemes_a0_problem_words.sql
                                                     + scripts/dev/seed/seed_lexemes_fix_20261020.sql (стан робочої бази до виправлення, для локальної перевірки)

* 8 заглушок «базовий термін (A0)» — справжній переклад, приклад, normalized без діакритики, рід, тип «сполучення».
* 8 діалектних / розмовних / сербських слів — лишаються в словнику (PUBLISHED), але з позначкою прямо в перекладі
  (словник показує лише переклад) і стандартним хорватським відповідником; register / regionality / пояснення;
  рівень A0 → A2 (це не базова лексика A0). У жодному уроці й вправі цих слів немає (перевірено 2026-10-20).
SQL: стара версія кожного слова — у content_versions; змінює слово, лише якщо переклад досі старий (повторний запуск нічого не змінює).
"""
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
from full_lessons import q  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261020_lexemes_a0_problem_words.sql'
SEED = ROOT / 'scripts' / 'dev' / 'seed' / 'seed_lexemes_fix_20261020.sql'
NOTE = 'lexemes_fix_20261020: проблемне слово словника A0 виправлено за рішенням власника 2026-10-20 — стара версія'
REVIEW = ('Виправлено за рішенням власника 2026-10-20 (проблемні слова словника A0, content/reviews/2026-10-12_curriculum_a0_v1.md). '
          'Потрібна перевірка носієм.')
PLACEHOLDER = 'базовий термін (A0)'

# (лема в базі, старий переклад) → нові значення
FIXES = [
    # --- заглушки
    dict(key='bijela mačka', old=PLACEHOLDER, lemma='bijela mačka', normalized='bijela macka', ua='біла кішка', pos='phrase',
         vtype='collocation', cefr='A0', forms={'gender': 'f'}, examples=['Na prozoru sjedi bijela mačka.']),
    dict(key='crna mačka', old=PLACEHOLDER, lemma='crna mačka', normalized='crna macka', ua='чорна кішка', pos='phrase',
         vtype='collocation', cefr='A0', forms={'gender': 'f'}, examples=['Crna mačka spava na kauču.']),
    dict(key='mali pas', old=PLACEHOLDER, lemma='mali pas', normalized='mali pas', ua='маленький собака, песик', pos='phrase',
         vtype='collocation', cefr='A0', forms={'gender': 'm'}, examples=['Susjeda ima malog psa.']),
    dict(key='veliki pas', old=PLACEHOLDER, lemma='veliki pas', normalized='veliki pas', ua='великий собака', pos='phrase',
         vtype='collocation', cefr='A0', forms={'gender': 'm'}, examples=['Pazi, u dvorištu je veliki pas!']),
    dict(key='novi auto', old=PLACEHOLDER, lemma='novi auto', normalized='novi auto', ua='нова машина, нове авто', pos='phrase',
         vtype='collocation', cefr='A0', forms={'gender': 'm'}, examples=['Kupili smo novi auto.']),
    dict(key='stari auto', old=PLACEHOLDER, lemma='stari auto', normalized='stari auto', ua='стара машина, старе авто', pos='phrase',
         vtype='collocation', cefr='A0', forms={'gender': 'm'}, examples=['Prodajem stari auto.']),
    dict(key='brzi auto', old=PLACEHOLDER, lemma='brzi auto', normalized='brzi auto', ua='швидка машина, швидке авто', pos='phrase',
         vtype='collocation', cefr='A0', forms={'gender': 'm'}, examples=['Marko vozi brzi auto.']),
    dict(key='spori auto', old=PLACEHOLDER, lemma='spori auto', normalized='spori auto', ua='повільна машина, повільне авто', pos='phrase',
         vtype='collocation', cefr='A0', forms={'gender': 'm'}, examples=['Iza nas vozi jedan spori auto.']),
    # --- діалектні, розмовні, сербські
    dict(key='pomidor', old='помідор', lemma='pomidor', normalized='pomidor', ua='помідор (діалект, Далмація; стандартно — rajčica)',
         pos='noun', vtype='core', cefr='A2', register='regional', regionality='Dalmatia',
         expl='Діалектне слово (Далмація). У стандартній хорватській — rajčica.'),
    dict(key='kapula', old='цибуля', lemma='kapula', normalized='kapula', ua='цибуля (діалект, Далмація; стандартно — luk)',
         pos='noun', vtype='core', cefr='A2', register='regional', regionality='Dalmatia',
         expl='Діалектне слово (Далмація). У стандартній хорватській — luk.', examples=['Za salatu trebam jednu kapulu.']),
    dict(key='šugaman', old='рушник', lemma='šugaman', normalized='sugaman', ua='рушник (діалект, Далмація; стандартно — ručnik)',
         pos='noun', vtype='core', cefr='A2', register='regional', regionality='Dalmatia',
         expl='Діалектне слово (Далмація). У стандартній хорватській — ručnik.'),
    dict(key='apoteka', old='аптека', lemma='apoteka', normalized='apoteka', ua='аптека (розмовне; стандартно — ljekarna)',
         pos='noun', vtype='core', cefr='A2', register='colloquial',
         expl='Розмовне слово (стандартне в Сербії та Боснії). У стандартній хорватській — ljekarna.',
         examples=['Je li apoteka još otvorena?']),
    dict(key='kompjuter', old="комп'ютер", lemma='kompjuter', normalized='kompjuter', ua='комп’ютер (розмовне; стандартно — računalo)',
         pos='noun', vtype='core', cefr='A2', register='colloquial',
         expl='Розмовне слово. У стандартній хорватській — računalo.'),
    dict(key='da li govorite engleski', old='чи розмовляєте ви англійською', lemma='da li govorite engleski',
         normalized='da li govorite engleski',
         ua='чи розмовляєте ви англійською (сербська конструкція; хорватською — Govorite li engleski?)',
         pos='phrase', vtype='chunk', cefr='A2', register='non_standard',
         expl='Питання з «da li…» — сербська конструкція. У хорватській: Govorite li engleski?'),
    dict(key='ae', old='так / ага / згоден', lemma='ae', normalized='ae', ua='так, ага (сленг, Далмація)',
         pos='particle', vtype='formulaic', cefr='A2', register='slang', regionality='Dalmatia',
         expl='Розмовне «так, ага» в Далмації. Нейтрально — da.'),
    dict(key='onak', old='Типу / Якось так', lemma='onak', normalized='onak', ua='ну, типу; якось так (сленг, Загреб)',
         pos='adverb', vtype='formulaic', cefr='A2', register='slang', regionality='Zagreb',
         expl='Розмовне слово-паразит у Загребі (від onako — «так, отак»). У нейтральній мові не вживається.'),
]

# Стан робочої бази до виправлення (2026-10-20) — лише для локального сиду
BEFORE = {
    'bijela mačka': ('bijela mačka', 'phrase', 'A0', None, 'chunk', {}, []),
    'crna mačka': ('crna mačka', 'phrase', 'A0', None, 'chunk', {}, []),
    'mali pas': ('mali pas', 'phrase', 'A0', None, 'chunk', {}, []),
    'veliki pas': ('veliki pas', 'phrase', 'A0', None, 'chunk', {}, []),
    'novi auto': ('novi auto', 'phrase', 'A0', None, 'chunk', {}, []),
    'stari auto': ('stari auto', 'phrase', 'A0', None, 'chunk', {}, []),
    'brzi auto': ('brzi auto', 'phrase', 'A0', None, 'chunk', {}, []),
    'spori auto': ('spori auto', 'phrase', 'A0', None, 'chunk', {}, []),
    'pomidor': ('pomidor', 'noun', 'A0', 'Dalmatia', 'core', {'gender': 'm', 'plural': 'pomidori'}, ['Salata od pomidora.']),
    'kapula': ('kapula', 'noun', 'A0', 'Dalmatia', 'core', {'gender': 'f'}, ['Meso i kapula.']),
    'šugaman': ('sugaman', 'noun', 'A0', 'Dalmatia', 'core', {'gender': 'm', 'plural': 'šugamani'}, ['Ponesi šugaman za plažu.']),
    'apoteka': ('apoteka', 'noun', 'A2', None, 'core', {'gender': 'f'}, []),
    'kompjuter': ('kompjuter', 'noun', 'A0', None, 'core', {'loc': 'kompjuteru', 'gender': 'm'}, ['Radim na kompjuteru.']),
    'da li govorite engleski': ('da li govorite engleski', 'word', 'A0', None, 'core', {}, []),
    'ae': ('ae', 'particle', 'A0', 'Dalmatia', 'formulaic', {}, ['Ae, tako je.', 'Ae?']),
    'onak': ('onak', None, 'A0', None, 'core', {}, []),
}
BEFORE_LEMMA = {'onak': 'Onak'}

CYR = re.compile(r'[Ѐ-ӿ]')


def validate():
    errors = []
    for f in FIXES:
        if CYR.search(f['lemma'] + ''.join(f.get('examples', []))):
            errors.append(f"{f['lemma']}: кирилиця в лемі чи прикладі")
        if re.search(r'[čćđšž]', f['normalized']) or f['normalized'] != f['normalized'].lower():
            errors.append(f"{f['lemma']}: normalized має бути без діакритики й малими")
        if not CYR.search(f['ua']) or 'базовий термін' in f['ua']:
            errors.append(f"{f['lemma']}: переклад")
        if f['lemma'].lower() != f['key']:
            errors.append(f"{f['lemma']}: лема змінює слово (lower має збігатися з ключем)")
    if len({f['key'] for f in FIXES}) != 16:
        errors.append('має бути 16 різних слів')
    if errors:
        raise SystemExit('Помилки:\n  ' + '\n  '.join(errors))


def jb(v) -> str:
    return q(json.dumps(v, ensure_ascii=False)) + '::jsonb'


def build() -> str:
    rows = []
    for f in FIXES:
        rows.append({
            'key': f['key'], 'old': f['old'], 'lemma': f['lemma'], 'normalized': f['normalized'], 'ua': f['ua'],
            'pos': f['pos'], 'vtype': f['vtype'], 'cefr': f['cefr'], 'register': f.get('register'),
            'regionality': f.get('regionality'), 'expl': f.get('expl'),
            'forms': f.get('forms'), 'examples': f.get('examples'),
        })
    data = json.dumps(rows, ensure_ascii=False, indent=1)
    return f"""-- =====================================================================
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
  for d in select * from jsonb_to_recordset({q(data)}::jsonb)
             as t(key text, old text, lemma text, normalized text, ua text, pos text, vtype text, cefr text,
                  register text, regionality text, expl text, forms jsonb, examples jsonb)
  loop
    for r in select * from public.lexemes where lower(lemma) = d.key and ukrainian_translation = d.old loop
      insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
      values ('lexeme', r.id, coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = r.id), 0) + 1,
              to_jsonb(r), {q(NOTE)});
      update public.lexemes set
        lemma = d.lemma, normalized = d.normalized, ukrainian_translation = d.ua, part_of_speech = d.pos,
        vocabulary_type = d.vtype, cefr = d.cefr,
        register = coalesce(d.register, register), regionality = coalesce(d.regionality, regionality),
        ukrainian_explanation = coalesce(d.expl, ukrainian_explanation),
        forms = coalesce(d.forms, forms), examples = coalesce(d.examples, examples)
      where id = r.id;
      insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
      values ('lexeme', r.id, r.status, r.status, 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW)});
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
   where status = 'PUBLISHED' and (ukrainian_translation = {q(PLACEHOLDER)} or lemma = 'Onak'
     or (lower(lemma) in ('pomidor', 'kapula', 'šugaman', 'apoteka', 'kompjuter', 'da li govorite engleski', 'ae', 'onak')
         and (cefr = 'A0' or ukrainian_translation !~ '(діалект|розмовне|сербська|сленг)')));
  select count(*) into v_fixed from public.content_reviews where notes = {q(REVIEW)};
  if v_bad > 0 then raise exception 'Лишилось проблемних слів: %', v_bad; end if;
  raise notice 'Готово: проблемні слова словника A0 виправлено (записів у журналі перевірки: %)', v_fixed;
end $$;

commit;
"""


def seed() -> str:
    out = ['-- Проблемні слова словника A0 у стані робочої бази до виправлення (2026-10-20). Лише для локальної перевірки.']
    old = {f['key']: f['old'] for f in FIXES}
    for key, (norm, pos, cefr, reg, vtype, forms, ex) in BEFORE.items():
        lemma = BEFORE_LEMMA.get(key, key)
        out.append('insert into public.lexemes (lemma, normalized, language, part_of_speech, cefr, ukrainian_translation, regionality, '
                   'vocabulary_type, forms, examples, status, source) values '
                   f"({q(lemma)}, {q(norm if key not in ('bijela mačka', 'crna mačka') else key)}, 'hr', {q(pos) if pos else 'null'}, {q(cefr)}, "
                   f"{q(old[key])}, {q(reg) if reg else 'null'}, {q(vtype)}, {jb(forms)}, {jb(ex)}, 'PUBLISHED', 'local_test') on conflict do nothing;")
    return '\n'.join(out) + '\n'


if __name__ == '__main__':
    validate()
    OUT.write_text(build(), encoding='utf-8')
    SEED.write_text(seed(), encoding='utf-8')
    print(f'{OUT.relative_to(ROOT)}: {OUT.stat().st_size // 1024} КБ; {SEED.relative_to(ROOT)}')
