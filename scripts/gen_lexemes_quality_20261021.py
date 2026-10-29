#!/usr/bin/env python3
"""
Чистка граматичних полів словника lexemes · 2026-10-21 (PROJECT_STATE → «Технічний борг» → Контент).

  python3 -B scripts/gen_lexemes_quality_20261021.py            → supabase/data_fixes/20261021_lexemes_grammar_fields.sql
  python3 -B scripts/gen_lexemes_quality_20261021.py --preview  → лише SELECT плану змін (для звірки з робочою базою, нічого не змінює)

Що робить SQL (усі рядки, крім DEPRECATED):
  * part_of_speech: порожні й службові ('word', 'other', 'formulaic', 'chunk') → справжня частина мови;
    хибні (čuvati — «noun», числівники — «noun»…) → правильна. Дані й правила — scripts/lexemes_quality_data.py.
  * forms.aspect у кожного дієслова: ipfv / pfv / biasp (раніше: impfv, ipf, pf, unspecified, порожньо).
  * forms.gender у кожного іменника: m / f / n / m_pl / f_pl / n_pl.
  * normalized = lemma малими без діакритик (як normalizeCroatian у lib/srs.ts).
  * Леми з великої літери, що не є власними назвами, → з малої; 3 точкові виправлення лем.
  * Перед змінами — копія таблиці в backup.lexemes_20261021; стара версія кожного зміненого рядка → content_versions,
    запис у content_reviews; version + 1. Повторний запуск нічого не змінює (план порожній).
"""
import json
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
from full_lessons import q  # noqa: E402
import lexemes_quality_data as D  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261021_lexemes_grammar_fields.sql'
NOTE = 'lexemes_quality_20261021: частина мови / рід / вид / normalized — стара версія'
REVIEW = ('Автоматична чистка граматичних полів 2026-10-21 (частина мови, рід, вид дієслова, normalized; '
          'scripts/lexemes_quality_data.py). Потрібна вибіркова перевірка носієм.')

POS_ALLOWED = ('noun', 'verb', 'adjective', 'adverb', 'pronoun', 'preposition', 'conjunction', 'particle',
               'interjection', 'number', 'phrase')
GENDERS = ('m', 'f', 'n', 'm_pl', 'f_pl', 'n_pl')
ASPECTS = ('ipfv', 'pfv', 'biasp')


def validate():
    errors = []
    for k, v in D.POS_OVERRIDES.items():
        if v not in POS_ALLOWED:
            errors.append(f'{k}: невідома частина мови {v}')
        if k != k.lower().strip():
            errors.append(f'{k}: ключ має бути малими')
    for k, v in D.ASPECT.items():
        if v not in ASPECTS:
            errors.append(f'{k}: вид {v}')
    for k, v in D.GENDER_OVERRIDES.items():
        if v not in GENDERS:
            errors.append(f'{k}: рід {v}')
    # Дієслово з POS_OVERRIDES мусить мати вид
    for k, v in D.POS_OVERRIDES.items():
        if v == 'verb' and k not in D.ASPECT:
            errors.append(f'{k}: дієслово без виду в ASPECT')
    for key, lemma, old, new in D.LEMMA_FIXES:
        if lemma.lower() != key and lemma.lower() in D.POS_OVERRIDES:
            errors.append(f'{lemma}: конфлікт')
    if errors:
        raise SystemExit('Помилки даних:\n  ' + '\n  '.join(errors))


def config() -> dict:
    return {
        'pos': D.POS_OVERRIDES,
        'aspect': D.ASPECT,
        'aspect_fix': D.ASPECT_CODE_FIXES,
        'gender': D.GENDER_OVERRIDES,
        'lower': D.LOWERCASE_LEMMAS,
        'lemma_fixes': [{'key': k, 'lemma': l, 'old_ua': o, 'ua': n} for k, l, o, n in D.LEMMA_FIXES],
        'service_pos': list(D.SERVICE_POS),
    }


def plan_sql(cfg_literal: str, all_rows: bool = False) -> str:
    """SELECT: id, старі й нові значення для кожного рядка, де щось зміниться."""
    return f"""with cfg as (select {cfg_literal}::jsonb as j),
s1 as (
  select l.*, lf.x as lf
    from public.lexemes l
    left join lateral (
      select x from cfg, jsonb_array_elements(cfg.j->'lemma_fixes') x
       where x->>'key' = lower(l.lemma) and x->>'old_ua' = l.ukrainian_translation) lf on true
   where l.status <> 'DEPRECATED'
),
s2 as (
  select s1.*,
    case when lf is not null then lf->>'lemma'
         when lower(lemma) in (select jsonb_array_elements_text(j->'lower') from cfg) then lower(lemma)
         else lemma end as new_lemma,
    case when lf is not null then lf->>'ua'
         when lower(lemma) in (select jsonb_array_elements_text(j->'lower') from cfg)
              and ukrainian_translation ~ '^[А-ЯІЇЄҐ]'
           then lower(left(ukrainian_translation, 1)) || substr(ukrainian_translation, 2)
         else ukrainian_translation end as new_ua
  from s1
),
s3 as (
  select s2.*, lower(new_lemma) as nk,
    coalesce((select j->'pos'->>lower(new_lemma) from cfg),
      case when part_of_speech is null or part_of_speech in (select jsonb_array_elements_text(j->'service_pos') from cfg) then
        case when new_lemma ~ '^\\S+(ti|ći) se$' or (new_lemma !~ '\\s' and new_lemma ~ '(ti|ći)$') then 'verb'
             when new_lemma ~ '\\s' then 'phrase'
             else 'noun' end
      else part_of_speech end) as new_pos
  from s2
),
s4 as (
  select s3.*,
    case when new_pos = 'verb' then coalesce(
      cfg.j->'aspect'->>nk,
      cfg.j->'aspect_fix'->>(forms->>'aspect'),
      case when forms->>'aspect' in ('ipfv', 'pfv', 'biasp') then forms->>'aspect' end) end as new_aspect,
    case when new_pos = 'noun' then coalesce(
      cfg.j->'gender'->>nk,
      case when forms->>'gender' in ('m', 'f', 'n', 'm_pl', 'f_pl', 'n_pl') then forms->>'gender' end,
      case when nk ~ 'ost$' then 'f'
           when nk ~ 'a$' then 'f'
           when nk ~ '[oe]$' then 'n'
           when nk ~ '[bcčćdđfghjklmnprsštvzžu]$' then 'm' end) end as new_gender
  from s3, cfg
),
s5 as (
  select s4.*,
    (case when jsonb_typeof(forms) = 'object' then forms else '{{}}'::jsonb end) - 'aspect' - 'gender'
      || case when new_aspect is not null then jsonb_build_object('aspect', new_aspect) else '{{}}'::jsonb end
      || case when new_pos = 'noun' and new_gender is not null then jsonb_build_object('gender', new_gender)
              when new_pos = 'phrase' and forms ? 'gender' then jsonb_build_object('gender', forms->'gender')
              else '{{}}'::jsonb end as new_forms,
    translate(lower(btrim(new_lemma)), 'čćđšž', 'ccdsz') as new_normalized
  from s4
)
select id, lemma, new_lemma, ukrainian_translation, new_ua, part_of_speech, new_pos, forms, new_forms,
       normalized, new_normalized, new_aspect, new_gender
  from s5
 where {'true or ' if all_rows else ''}new_lemma is distinct from lemma or new_ua is distinct from ukrainian_translation
    or new_pos is distinct from part_of_speech or new_forms is distinct from forms
    or new_normalized is distinct from normalized"""


def build() -> str:
    cfg_literal = q(json.dumps(config(), ensure_ascii=False, sort_keys=True))
    plan = plan_sql(cfg_literal)
    return f"""-- =====================================================================
-- Словник lexemes: частина мови, рід, вид дієслова, normalized · 2026-10-21
-- Згенеровано: python3 -B scripts/gen_lexemes_quality_20261021.py (не редагуйте вручну).
--
--   * part_of_speech: порожні й службові ('word', 'other', 'formulaic', 'chunk') → справжня частина мови;
--     хибні (čuvati — «noun», числівники — «noun», pametan — «noun»…) → правильна.
--   * Кожне дієслово — forms.aspect: ipfv / pfv / biasp; кожен іменник — forms.gender: m / f / n / *_pl.
--   * normalized = лема малими без діакритик (domaćin → domacin, hitna pomoć → hitna pomoc, događaj → dogadaj).
--   * Леми з великої, що не є власними назвами (Devizni račun, Zastoj…), → з малої; vzdahnuti → uzdahnuti,
--     sretan Božić, sretna Nova godina.
--   * Копія таблиці → backup.lexemes_20261021; стара версія кожного зміненого слова → content_versions,
--     запис у content_reviews. Повторний запуск нічого не змінює.
-- Запуск: Supabase → SQL Editor → вставити весь файл → Run. Очікуване повідомлення: «Готово: …».
-- =====================================================================

begin;

create schema if not exists backup;
create table if not exists backup.lexemes_20261021 as table public.lexemes;
revoke all on all tables in schema backup from anon, authenticated;

do $fix$
declare
  r record;
  v_changed int := 0;
  v_missing text;
begin
  -- Попередження: ключі даних, яких немає в базі (не помилка — просто нічого не змінять)
  select string_agg(k, ', ') into v_missing
    from jsonb_object_keys({cfg_literal}::jsonb->'pos') k
   where not exists (select 1 from public.lexemes where lower(lemma) = k);
  if v_missing is not null then raise notice 'Немає в словнику (частина мови): %', v_missing; end if;

  for r in {plan}
  loop
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    select 'lexeme', l.id,
           coalesce((select max(version) from public.content_versions where entity_type = 'lexeme' and entity_id = l.id), 0) + 1,
           to_jsonb(l), {q(NOTE)}
      from public.lexemes l where l.id = r.id;
    update public.lexemes set
      lemma = r.new_lemma, ukrainian_translation = r.new_ua, part_of_speech = r.new_pos,
      forms = r.new_forms, normalized = r.new_normalized, version = coalesce(version, 1) + 1
    where id = r.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    select 'lexeme', l.id, l.status, l.status, 'auto_passed', 'script',
           jsonb_build_array(jsonb_build_object('pos', r.part_of_speech, 'new_pos', r.new_pos,
                                                'forms', r.forms, 'new_forms', r.new_forms)),
           {q(REVIEW)}
      from public.lexemes l where l.id = r.id;
    v_changed := v_changed + 1;
  end loop;
  raise notice 'Змінено слів зараз: %', v_changed;
end
$fix$;

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_pos int; v_verb int; v_noun int; v_norm int; v_upper int;
begin
  select count(*) into v_pos from public.lexemes
   where status <> 'DEPRECATED'
     and (part_of_speech is null or part_of_speech not in ({', '.join(q(p) for p in POS_ALLOWED)}));
  select count(*) into v_verb from public.lexemes
   where status <> 'DEPRECATED' and part_of_speech = 'verb'
     and coalesce(forms->>'aspect', '') not in ('ipfv', 'pfv', 'biasp');
  select count(*) into v_noun from public.lexemes
   where status <> 'DEPRECATED' and part_of_speech = 'noun'
     and coalesce(forms->>'gender', '') not in ('m', 'f', 'n', 'm_pl', 'f_pl', 'n_pl');
  select count(*) into v_norm from public.lexemes
   where status <> 'DEPRECATED' and normalized is distinct from translate(lower(btrim(lemma)), 'čćđšž', 'ccdsz');
  select count(*) into v_upper from public.lexemes
   where status <> 'DEPRECATED' and lower(lemma) in ('devizni račun', 'zastoj', 'iskreno') and lemma <> lower(lemma);
  if v_pos + v_verb + v_noun + v_norm + v_upper > 0 then
    raise exception 'Лишились проблеми: без частини мови %, дієслів без виду %, іменників без роду %, normalized %, великі літери %',
      v_pos, v_verb, v_noun, v_norm, v_upper;
  end if;
  raise notice 'Готово: частина мови, рід, вид і normalized у порядку (записів у журналі перевірки: %)',
    (select count(*) from public.content_reviews where notes = {q(REVIEW)});
end $$;

commit;
"""


PREVIEW = """with p as ({plan})
select json_build_object(
 'changed', (select count(*) from p where new_lemma is distinct from lemma or new_ua is distinct from ukrainian_translation
    or new_pos is distinct from part_of_speech or new_forms is distinct from forms or new_normalized is distinct from normalized),
 'pos_trans', (select json_object_agg(t, c) from (select coalesce(part_of_speech, '-') || '>' || new_pos t, count(*) c
    from p where part_of_speech is distinct from new_pos group by 1) x),
 'verb_no_aspect', (select string_agg(new_lemma, ', ') from p where new_pos = 'verb' and new_aspect is null),
 'noun_no_gender', (select string_agg(new_lemma, ', ') from p where new_pos = 'noun' and new_gender is null),
 'aspect_changed', (select string_agg(new_lemma || ':' || (forms->>'aspect') || '>' || new_aspect, ', ') from p
    where new_pos = 'verb' and forms->>'aspect' is not null and forms->>'aspect' <> 'unspecified'
      and coalesce((%s::jsonb)->>(forms->>'aspect'), forms->>'aspect') <> new_aspect),
 'gender_changed', (select string_agg(new_lemma || ':' || (forms->>'gender') || '>' || new_gender, ', ') from p
    where new_pos = 'noun' and forms->>'gender' is not null and forms->>'gender' <> new_gender),
 'lemma_changed', (select string_agg(lemma || '>' || new_lemma, ', ') from p where lemma <> new_lemma)
)"""


if __name__ == '__main__':
    validate()
    if '--preview' in sys.argv:
        cfg_literal = q(json.dumps(config(), ensure_ascii=False, sort_keys=True))
        plan = plan_sql(cfg_literal, all_rows=True)
        print(PREVIEW.replace('{plan}', plan).replace('%s', q(json.dumps(D.ASPECT_CODE_FIXES))))
    else:
        OUT.parent.mkdir(parents=True, exist_ok=True)
        OUT.write_text(build(), encoding='utf-8')
        print(f'{OUT.relative_to(ROOT)}: {OUT.stat().st_size // 1024} КБ; '
              f'частина мови: {len(D.POS_OVERRIDES)}, вид: {len(D.ASPECT)}, рід: {len(D.GENDER_OVERRIDES)}')
