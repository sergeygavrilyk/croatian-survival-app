#!/usr/bin/env python3
"""
Розмітка всіх слів і речень: register / regionality / usage_tags · 2026-11-13 (крок 2 плану маркування).

Рішення власника 2026-11-13: «Я хочу до генерації B1, додати до вже наявних 6180 слів — значення. Але, важливо, це
зробити правильно, щоб не повертатись до цього в майбутньому»; «Даю Ок на кінцевий стан: усі поля обов'язкові й без
значення за замовчуванням…»; «Ок на версії». План — docs/proposals/2026-11-12_b1_b2_dialogues_reading_situations.md §4.3.

Як ставимо мітки:
  1. register — наявний лишається; старі regional / non_standard → colloquial; порожній — за правилами
     scripts/lexeme_register.py (словник слів, звертання на «ти»); сумнівні (DOUBT) і з позначкою в перекладі —
     standard + у звіт носію; решта — standard.
  2. regionality — наявний лишається; REGION нижче; решта — general.
  3. usage_tags — TAGS нижче (походження, наріччя, ідіома, жаргон); решта — {} (ознак немає).
  Явно (за списком) — слова з правил і з ознаками; решта словника — standard / general / {} одним оновленням у SQL.
  Кожна зміна — стара версія в content_versions, запис у content_reviews. Повторний запуск нічого не змінює
  (позначене — це usage_tags не null).

  python3 -B scripts/gen_lexeme_labels_20261113.py            → supabase/data_fixes/20261113_lexeme_labels.sql
                                                                + content/reviews/2026-11-13_lexeme_labels.md
  python3 -B scripts/gen_lexeme_labels_20261113.py --check    → лише перевірка (без запису файлів)
Знімок робочої бази (лише читання): scripts/lexeme_labels_20261113_snapshot.json.
"""
from __future__ import annotations

import json
import sys
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parent
sys.path.insert(0, str(HERE))
from lexeme_checks import REGIONS, USAGE_TAGS, check_labels  # noqa: E402
from lexeme_register import DOUBT, LEGACY, suggest_register, ti_address  # noqa: E402

SNAPSHOT = HERE / 'lexeme_labels_20261113_snapshot.json'
SQL_OUT = ROOT / 'supabase' / 'data_fixes' / '20261113_lexeme_labels.sql'
REVIEW_OUT = ROOT / 'content' / 'reviews' / '2026-11-13_lexeme_labels.md'
TAG = 'lexeme_labels 2026-11-13'

# ---------------------------------------------------------------------------------------------------------------
# Ознаки (usage_tags). Межа: позначаємо запозичення, яке учень чує як іншомовне чи розмовне (є стандартний відповідник
# або слово явно «чуже»: vikend, šlag, šugaman), а не давні повністю засвоєні слова (kuhinja, krumpir, šunka).
# Непевне походження — не ставимо, а пишемо у звіт носію (UNSURE).
# ---------------------------------------------------------------------------------------------------------------
ANGLICISM = ('backup', 'bend', 'dizajn', 'dizajnirati', 'džem', 'džemper', 'haker', 'hardver', 'hobi', 'hostel',
             'intervju', 'kauč', 'kliknuti', 'laptop', 'lift', 'link', 'mail', 'menadžer', 'motel', 'parking', 'podcast',
             'rent-a-car', 'roming', 'ruter', 'sendvič', 'softver', 'stres', 'supermarket', 'tablet', 'tinejdžer', 'tost',
             'trailer', 'vikend', 'web-stranica', 'kompjuter', 'facebook grupa', 'grupni chat', 'last minute ponuda',
             'online kupnja', 'online sastanak', 'online škola', 'naručiti termin online', 'popust za rani booking',
             'poslovni e-mail', 'zlonamjerni softver')
GERMANISM = ('cimerica', 'gablec', 'gemišt', 'kifla', 'kremšnita', 'štrudla', 'šlag', 'štand', 'šminka', 'šogor',
             'šogorica', 'flaster', 'fen', 'feniranje', 'kofer', 'pegla', 'peglati', 'šprica', 'ruksak')
ITALIANISM = ('kapula', 'pomidor', 'šugaman', 'marenda', 'spiza', 'gušt', 'fritule', 'fuži', 'bevanda', 'brudet',
              'brancin', 'bakalar', 'maneštra', 'maraskino', 'pašticada', 'pizzerija', 'pršut', 'riva', 'škampi',
              'srdela', 'srdele', 'tartuf', 'tartufi', 'orada', 'crni rižot', 'na buzaru', 'a cappella')
TURKISM = ('kusur', 'mušterija', 'burek', 'ćevapi')
KAJKAVIAN = ('gablec',)
IDIOM = ('izaći na kraj', 'izaći u susret', 'prenositi s koljena na koljeno', 'u zadnji čas', 'opet sam na nogama',
         'nestati bez traga', 'na licu mjesta', 'nikad ne reci nikad', 'dogovor je dogovor', 'napuniti baterije',
         'skriveni dragulj', 'osjećati se kao kod kuće', 'u dobre ruke')

TAGS: dict[str, list[str]] = {}
for _tag, _words in (('anglicism', ANGLICISM), ('germanism', GERMANISM), ('italianism', ITALIANISM),
                     ('turkism', TURKISM), ('kajkavian', KAJKAVIAN), ('idiom', IDIOM)):
    for _w in _words:
        TAGS.setdefault(_w, []).append(_tag)

# Регіон (regionality) — де слово вживають; наявні значення в базі лишаються (bura, jugo, riva, fjaka… — Dalmatia)
REGION: dict[str, tuple[str, str]] = {
    'gablec': ('Zagreb', 'загребське (кайкавське) слово; у перекладі «загреб.»'),
    'bevanda': ('Dalmatia', 'далматинське слово; у перекладі «Далмація»'),
    'fuži': ('Istria', 'істрійська паста; у перекладі «істрійська»'),
    'maneštra': ('Istria', 'істрійська (і кварнерська) страва'),
    'maestral': ('Dalmatia', 'вітер Адріатики — як bura, jugo (у базі вже Dalmatia)'),
}

# Регістр — винятки до правил lexeme_register.py
REGISTER_OVERRIDES: dict[str, tuple[str, str]] = {
    'kužiš?': ('colloquial', 'форма від kužiti (colloquial за правилами); DEPRECATED'),
}

# Речення (phrases): мітки поза типовими standard / general / {}
PHRASE_LABELS: dict[str, tuple[str | None, list[str], str]] = {
    'kužiš?': ('colloquial', [], 'kužiti — розмовне'),
    'predao sam zahtjev online.': (None, ['anglicism'], 'online'),
    'imamo li blokada za ovaj sprint?': (None, ['professional_jargon', 'anglicism'], 'ІТ-жаргон: sprint, blokada (блокер)'),
}

# Непевне — у звіт носію (мітки не ставимо або ставимо обережно)
UNSURE: dict[str, str] = {
    'fjaka': 'походження: італізм (fiacca)? грецьке? — ознаку italianism не ставлю, доки носій не підтвердить',
    'žmigavac': 'походження (германізм?) — ознаку не ставлю',
    'šalabahter': 'походження (германізм?) — ознаку не ставлю',
    'deka': 'австрійське Deka (германізм?) — ознаку не ставлю',
    'sjesti na račun': 'розмовне «надійти на рахунок»? — зараз standard',
    'mislim...': 'слово-заповнювач (DEPRECATED, також у phrases) — informal? зараз standard',
    'znači...': 'слово-заповнювач (DEPRECATED, також у phrases) — colloquial? зараз standard',
    'pa...': 'слово-заповнювач (DEPRECATED, також у phrases) — зараз standard',
    'zadržite kusur': 'містить туркізм kusur (colloquial) — фраза зараз standard без ознак',
    'gdje je apoteka': 'apoteka — розмовне / сербізм (DEPRECATED слово) — фраза зараз standard',
}

# Помилки даних, помічені під час перегляду (не виправляю тут — окремим пакетом)
DATA_ISSUES = [
    '*budilika* — одруківка (*budilica* теж є в словнику) — DEPRECATED?',
    '*pijesok* — одруківка (*pijesak* теж є); *taoc*, *suhozid* — уже у звіті 2026-11-12',
    '*kužiš?*, *mislim...*, *znači...*, *pa...* — леми зі знаками й трикрапкою (DEPRECATED; ті самі — у phrases)',
    'леми-речення з репліками діалогу (*a: dobar dan! kako ste?*, *developer: završio sam backend dio…*, *arhitekt: …*) — '
    'мають бути в conversations; позначено standard без ознак',
    '*dijaloz -> dijalog* — лема зі стрілкою',
]


def load() -> dict:
    return json.loads(SNAPSHOT.read_text(encoding='utf-8'))


def lexeme_rows(snap: dict) -> tuple[list[dict], list[str], list[str]]:
    """(явні рядки, помилки, нотатки для звіту)."""
    rule = {r[0]: r for r in snap['rule_rows']}
    tag_keys = {r[0] for r in snap['tag_rows']}
    known = set(rule) | tag_keys
    errors: list[str] = []
    for k in list(TAGS) + list(REGION) + list(REGISTER_OVERRIDES):
        if k not in known:
            errors.append(f'«{k}» немає в знімку (одруківка чи слова немає в базі?)')
    for k, tags in TAGS.items():
        if len(set(tags)) != len(tags) or any(t not in USAGE_TAGS for t in tags):
            errors.append(f'«{k}»: ознаки {tags}')

    out, notes = [], []
    for k in sorted(known):
        r = rule.get(k)
        status = (r[1] if r else next(t[1] for t in snap['tag_rows'] if t[0] == k))[:1]
        existing_reg = r[4] if r else None
        existing_region = r[5] if r else None
        why = []
        if k in REGISTER_OVERRIDES:
            reg, w = REGISTER_OVERRIDES[k]
            why.append(w)
        elif existing_reg in LEGACY:
            reg = 'colloquial'
            why.append(f'старе {existing_reg} → colloquial')
        elif existing_reg:
            reg = existing_reg
            why.append('регістр уже був')
        elif r:
            sug, w, src = suggest_register({'lemma': k, 'part_of_speech': r[2], 'vocabulary_type': r[3],
                                            'ukrainian_translation': r[6]})
            if src in ('rule', 'ti'):
                reg = sug
                why.append(w)
            else:
                reg = 'standard'
                if src in ('doubt', 'mark'):
                    notes.append(f'*{k}* — standard; {w}')
        else:
            reg = 'standard'
        region = existing_region or REGION.get(k, (None,))[0] or 'general'
        if existing_region:
            why.append('регіон уже був')
        if k in REGION and not existing_region:
            why.append(REGION[k][1])
        tags = TAGS.get(k, [])
        row = {'k': k, 'register': reg, 'regionality': region, 'usage_tags': tags,
               'why': '; '.join(why) or ('ознаки за перевіркою словника' if tags else 'за правилами регістру'), 'status': status}
        e, _w = check_labels({'lemma': k, **{f: row[f] for f in ('register', 'regionality', 'usage_tags')}})
        errors += [f'«{k}»: {m}' for m in e]
        out.append(row)
    return out, errors, notes


def phrase_rows(snap: dict) -> tuple[list[dict], list[str]]:
    out, errors = [], []
    texts = {p[0] for p in snap['phrases']}
    for k in PHRASE_LABELS:
        if k not in texts:
            errors.append(f'речення «{k}» немає в знімку')
    for text, ua, _sit in snap['phrases']:
        reg, tags, why = PHRASE_LABELS.get(text, (None, [], ''))
        if reg is None:
            reg = 'informal' if ti_address({'lemma': text, 'part_of_speech': 'phrase', 'ukrainian_translation': ua}) else 'standard'
            if reg == 'informal':
                why = why or 'звертання на «ти»'
        if reg == 'standard' and not tags:
            continue  # типові мітки ставить SQL для всіх решти речень
        row = {'k': text, 'register': reg, 'regionality': 'general', 'usage_tags': tags, 'why': why}
        e, _w = check_labels({'lemma': text, **{f: row[f] for f in ('register', 'regionality', 'usage_tags')}})
        errors += [f'речення «{text}»: {m}' for m in e]
        out.append(row)
    return out, errors


def q(s: str) -> str:
    return s.replace("'", "''")


def build_sql(lex: list[dict], phr: list[dict], snap: dict) -> str:
    lex_json = json.dumps([{k: r[k] for k in ('k', 'register', 'regionality', 'usage_tags', 'why')} for r in lex],
                          ensure_ascii=False)
    phr_json = json.dumps([{k: r[k] for k in ('k', 'register', 'regionality', 'usage_tags', 'why')} for r in phr],
                          ensure_ascii=False)
    m = snap['meta']
    reason = (f"{TAG}: мітки register / regionality / usage_tags (LEARNING_SPEC §18; рішення власника 2026-11-13 — явні значення "
              f"в усіх словах); скрипт scripts/gen_lexeme_labels_20261113.py")
    return f"""-- =====================================================================
-- Розмітка всіх слів і речень: register / regionality / usage_tags · 2026-11-13 (крок 2 плану маркування)
-- Згенеровано: python3 -B scripts/gen_lexeme_labels_20261113.py (не редагуйте вручну).
-- Рішення власника 2026-11-13: «Я хочу до генерації B1, додати до вже наявних 6180 слів — значення. Але, важливо, це
--   зробити правильно, щоб не повертатись до цього в майбутньому»; «Даю Ок на кінцевий стан: усі поля обов'язкові й без
--   значення за замовчуванням…»; «Ок на версії». Модель — docs/LEARNING_SPEC.md §18; план — docs/proposals/
--   2026-11-12_b1_b2_dialogues_reading_situations.md §4.3. Потрібна міграція M24 (20261113100000_m24_lexeme_labels.sql).
-- Що робить:
--   1. {len(lex)} слів — явні мітки за списком (правила регістру, старі regional / non_standard → colloquial, ознаки
--      походження, наріччя, ідіоми, регіони). Наявні register / regionality не змінює (крім старих значень).
--   2. Усі інші слова (і PUBLISHED, і DEPRECATED) — standard / general / {{}} там, де мітки порожні.
--   3. Речення (phrases): {len(phr)} — за списком (звертання на «ти», розмовне, ознаки), решта — standard / general / {{}}.
--   Кожна зміна — стара версія в content_versions, запис у content_reviews. Повторний запуск нічого не змінює.
-- Знімок робочої бази: слів {m['lexemes_total']} (без міток {m['lexemes_unlabeled']}), речень {m['phrases_total']}.
-- Звіт для носія: content/reviews/2026-11-13_lexeme_labels.md. Тест: supabase/tests/lexeme_labels_fill.test.sql.
-- Очікуване повідомлення (робоча база): «Готово: слів явно {len(lex)}, слів типово {m['lexemes_total'] - len(lex)}, …,
--   речень явно {len(phr)}, речень типово {m['phrases_total'] - len(phr)}, без міток 0».
-- Після нього — PR «замок» (M25: VALIDATE і NOT NULL).
-- =====================================================================

begin;

do $fix$
declare
  w record;
  x public.lexemes%rowtype;
  p public.phrases%rowtype;
  v_reg text;
  v_region text;
  v_lex int := 0;
  v_lex_same int := 0;
  v_lex_missing int := 0;
  v_lex_rest int := 0;
  v_phr int := 0;
  v_phr_rest int := 0;
  v_left int;
  c_reason constant text := '{q(reason)}';
begin
  if not exists (select 1 from information_schema.columns where table_schema = 'public' and table_name = 'lexemes'
                   and column_name = 'usage_tags') then
    raise exception 'Спершу міграція M24 (20261113100000_m24_lexeme_labels.sql): колонки usage_tags ще немає';
  end if;

  -- 1. Слова за списком
  for w in select * from jsonb_to_recordset('{q(lex_json)}'::jsonb)
             as t(k text, register text, regionality text, usage_tags text[], why text)
  loop
    select * into x from public.lexemes where lower(lemma) = w.k;
    if x.id is null then
      v_lex_missing := v_lex_missing + 1;
      continue;
    end if;
    if x.usage_tags is not null then
      v_lex_same := v_lex_same + 1;
      continue;
    end if;
    v_reg := case when x.register is null or x.register in ('regional', 'non_standard') then w.register else x.register end;
    v_region := coalesce(x.regionality, w.regionality);
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('lexeme', x.id, coalesce((select max(version) from public.content_versions
                                      where entity_type = 'lexeme' and entity_id = x.id), 0) + 1,
            to_jsonb(x), c_reason || ' — ' || w.why);
    update public.lexemes
       set register = v_reg, regionality = v_region, usage_tags = w.usage_tags,
           version = coalesce(version, 1) + 1, updated_at = now()
     where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('lexeme', x.id, x.status, x.status, 'auto_passed', 'script',
            jsonb_build_array(jsonb_build_object('register', v_reg, 'regionality', v_region, 'usage_tags', to_jsonb(w.usage_tags))),
            c_reason || ' — ' || w.why);
    v_lex := v_lex + 1;
  end loop;

  -- 2. Решта слів: standard / general / {{}} (старі regional / non_standard → colloquial — на випадок, якщо їх немає в списку)
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'lexeme', l.id, coalesce((select max(cv.version) from public.content_versions cv
                                   where cv.entity_type = 'lexeme' and cv.entity_id = l.id), 0) + 1,
         to_jsonb(l), c_reason || ' — типові мітки (не в правилах): standard / general / {{}}'
    from public.lexemes l
   where l.usage_tags is null or l.register is null or l.regionality is null;

  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  select 'lexeme', l.id, l.status, l.status, 'auto_passed', 'script', '[]'::jsonb,
         c_reason || ' — типові мітки (не в правилах): standard / general / {{}}'
    from public.lexemes l
   where l.usage_tags is null or l.register is null or l.regionality is null;

  update public.lexemes
     set register = case when register is null then 'standard'
                         when register in ('regional', 'non_standard') then 'colloquial' else register end,
         regionality = coalesce(regionality, 'general'),
         usage_tags = coalesce(usage_tags, '{{}}'::text[]),
         version = coalesce(version, 1) + 1, updated_at = now()
   where usage_tags is null or register is null or regionality is null;
  get diagnostics v_lex_rest = row_count;

  -- 3. Речення за списком
  for w in select * from jsonb_to_recordset('{q(phr_json)}'::jsonb)
             as t(k text, register text, regionality text, usage_tags text[], why text)
  loop
    select * into p from public.phrases where lower(text_hr) = w.k;
    if p.id is null or p.usage_tags is not null then
      continue;
    end if;
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('phrase', p.id, coalesce((select max(version) from public.content_versions
                                      where entity_type = 'phrase' and entity_id = p.id), 0) + 1,
            to_jsonb(p), c_reason || ' — ' || w.why);
    update public.phrases
       set register = coalesce(p.register, w.register), regionality = coalesce(p.regionality, w.regionality),
           usage_tags = w.usage_tags, version = coalesce(version, 1) + 1, updated_at = now()
     where id = p.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('phrase', p.id, p.status, p.status, 'auto_passed', 'script', '[]'::jsonb, c_reason || ' — ' || w.why);
    v_phr := v_phr + 1;
  end loop;

  -- 4. Решта речень
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'phrase', ph.id, coalesce((select max(cv.version) from public.content_versions cv
                                   where cv.entity_type = 'phrase' and cv.entity_id = ph.id), 0) + 1,
         to_jsonb(ph), c_reason || ' — типові мітки: standard / general / {{}}'
    from public.phrases ph
   where ph.usage_tags is null or ph.register is null or ph.regionality is null;

  insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
  select 'phrase', ph.id, ph.status, ph.status, 'auto_passed', 'script', '[]'::jsonb,
         c_reason || ' — типові мітки: standard / general / {{}}'
    from public.phrases ph
   where ph.usage_tags is null or ph.register is null or ph.regionality is null;

  update public.phrases
     set register = coalesce(register, 'standard'), regionality = coalesce(regionality, 'general'),
         usage_tags = coalesce(usage_tags, '{{}}'::text[]), version = coalesce(version, 1) + 1, updated_at = now()
   where usage_tags is null or register is null or regionality is null;
  get diagnostics v_phr_rest = row_count;

  -- Самоперевірка: міток без значення й старих значень не лишилось
  select (select count(*) from public.lexemes where register is null or regionality is null or usage_tags is null)
       + (select count(*) from public.phrases where register is null or regionality is null or usage_tags is null)
    into v_left;
  if v_left > 0 then
    raise exception 'Лишились рядки без міток: %', v_left;
  end if;
  if exists (select 1 from public.lexemes where register in ('regional', 'non_standard')) then
    raise exception 'Лишились старі значення register (regional / non_standard)';
  end if;
  raise notice 'Готово: слів явно %, слів типово %, уже було %, немає в базі %, речень явно %, речень типово %, без міток %',
    v_lex, v_lex_rest, v_lex_same, v_lex_missing, v_phr, v_phr_rest, v_left;
end
$fix$;

commit;
"""


def build_review(lex: list[dict], phr: list[dict], notes: list[str], snap: dict) -> str:
    m = snap['meta']
    reg = Counter(r['register'] for r in lex)
    region = Counter(r['regionality'] for r in lex)
    tags = Counter(t for r in lex for t in r['usage_tags'])
    rest = m['lexemes_total'] - len(lex)
    lines = [
        '# Розмітка всіх слів і речень — звіт (2026-11-13)',
        '',
        'Пакет `supabase/data_fixes/20261113_lexeme_labels.sql` (генератор `scripts/gen_lexeme_labels_20261113.py`, знімок робочої бази '
        '`scripts/lexeme_labels_20261113_snapshot.json`). Модель — `docs/LEARNING_SPEC.md` §18; крок 2 плану '
        '`docs/proposals/2026-11-12_b1_b2_dialogues_reading_situations.md` §4.3.',
        '',
        '## 1. Підсумок',
        '',
        f'- Слів у базі: **{m["lexemes_total"]}** (без міток до пакета — {m["lexemes_unlabeled"]}); речень (`phrases`): **{m["phrases_total"]}**.',
        f'- Явно, за списком: **{len(lex)}** слів. Решта **{rest}** слів — `standard` / `general` / `{{}}`.',
        f'- Речення: за списком **{len(phr)}**, решта {m["phrases_total"] - len(phr)} — `standard` / `general` / `{{}}`.',
        '- Кожна зміна — стара версія в `content_versions`, запис у `content_reviews` (`script`).',
        '',
        '| Регістр (явні) | Слів |', '|---|---|',
        *[f'| `{k}` | {v} |' for k, v in sorted(reg.items())],
        '',
        '| Регіон (явні) | Слів |', '|---|---|',
        *[f'| `{k}` | {v} |' for k, v in sorted(region.items())],
        '',
        '| Ознака | Слів |', '|---|---|',
        *[f'| `{k}` | {v} |' for k, v in sorted(tags.items())],
        '',
        f'Разом з типовими: `standard` ≈ {rest + reg.get("standard", 0)} слів, `general` ≈ {rest + region.get("general", 0)}.',
        '',
        '## 2. Що змінилося в правилах',
        '',
        '- Старі значення: `regional` → `colloquial` (*kapula, pomidor, šugaman* — + `italianism`, регіон `Dalmatia` уже був); '
        '`non_standard` → `colloquial` (*da li govorite engleski*, DEPRECATED).',
        '- DEPRECATED слова теж розмічено (рішення 2026-11-13: «і PUBLISHED, і DEPRECATED»): звертання на «ти» '
        '(*kako provodiš vikend, što radiš, zovi policiju*) — `informal`.',
        '- Межа для ознак походження: запозичення, яке учень чує як іншомовне чи розмовне (*vikend, šlag, šugaman, kusur*); давні '
        'повністю засвоєні слова (*kuhinja, krumpir, šunka, čarape*) — без ознаки.',
        '',
        '## 3. Слова з явними мітками',
        '',
        '| Слово | Статус | register | regionality | usage_tags | Чому |', '|---|---|---|---|---|---|',
        *[f'| *{r["k"]}* | {r["status"]} | `{r["register"]}` | `{r["regionality"]}` | '
          f'{", ".join("`" + t + "`" for t in r["usage_tags"]) or "—"} | {r["why"]} |' for r in lex],
        '',
        '## 4. Речення з мітками поза типовими',
        '',
        '| Речення | register | usage_tags | Чому |', '|---|---|---|---|',
        *[f'| *{r["k"]}* | `{r["register"]}` | {", ".join("`" + t + "`" for t in r["usage_tags"]) or "—"} | {r["why"]} |' for r in phr],
        '',
        '## 5. Що варто глянути носію',
        '',
        '**Сумнівний регістр** (поставлено `standard`; якщо носій скаже «розмовне» — змінимо окремим пакетом через `content_versions`):',
        '',
        *[f'- {n}' for n in notes],
        '',
        '**Непевне походження й регістр:**',
        '',
        *[f'- *{k}* — {v}' for k, v in UNSURE.items()],
        '',
        '## 6. Помилки даних, помічені під час перегляду (окремим пакетом)',
        '',
        *[f'- {d}' for d in DATA_ISSUES],
        '',
    ]
    return '\n'.join(lines)


def main() -> None:
    snap = load()
    lex, e1, notes = lexeme_rows(snap)
    phr, e2 = phrase_rows(snap)
    errors = e1 + e2
    for m in errors:
        print('ПОМИЛКА', m)
    if errors:
        sys.exit(1)
    print(f'Слів явно: {len(lex)}; речень явно: {len(phr)}; сумнівних для носія: {len(notes)}')
    if '--check' in sys.argv:
        return
    SQL_OUT.write_text(build_sql(lex, phr, snap), encoding='utf-8')
    REVIEW_OUT.write_text(build_review(lex, phr, notes, snap), encoding='utf-8')
    print(f'→ {SQL_OUT.relative_to(ROOT)} ({SQL_OUT.stat().st_size // 1024} КБ), {REVIEW_OUT.relative_to(ROOT)}')


if __name__ == '__main__':
    main()
