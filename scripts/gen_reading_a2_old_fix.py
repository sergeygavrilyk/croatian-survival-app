#!/usr/bin/env python3
"""
20 старих текстів для читання A2 (RD-A2-001…020) під програму A2 v2 · 2026-11-15.

  python3 -B scripts/gen_reading_a2_old_fix.py           →  supabase/data_fixes/20261115_reading_a2_old_v2.sql
  python3 -B scripts/gen_reading_a2_old_fix.py --stats   →  частка знайомих слів кожного тексту (було → стало)
  python3 -B scripts/gen_reading_a2_old_fix.py --export  →  словничок 6 переписаних текстів для ручної перевірки

Що робить (аудит A2: content/reviews/2026-11-12_a2_audit.md):
  * 14 текстів лишаються, але знайомі слова перераховано за A2 v2: знайомі — уроки A0, A1 і уроки A2 до модуля тексту
    (раніше — лише A0–A1); позначка «з уроків» (можна зберегти в тренажер) — за опублікованими уроками A0–A2.
    Текст, питання й переклади словничка не змінюються.
  * 6 текстів, де знайомих було < 90 % (RD-A2-007, 008, 010, 013, 018, 019), переписано наново словами уроків
    (scripts/reading_data_a2_rewrite.py): той самий код і тема, новий текст, переклад, питання й словничок.
Словничок 14 текстів — як у старому генераторі (scripts/gen_reading.py, збігається з базою); 6 нових — як у gen_reading_a2_v2.py.
Знімок уроків — scripts/reading_a2_old_snapshot.json (робоча база 2026-11-15, лише читання). Уже запущені файли не змінює.
"""
import json
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.argv = [sys.argv[0]] + [a for a in sys.argv[1:]]
sys.path.insert(0, str(Path(__file__).parent))
_argv, sys.argv = sys.argv, [sys.argv[0]]
import gen_reading as R  # noqa: E402  (лише функції й дані)
import gen_reading_a2_v2 as N  # noqa: E402
import reading_data_a2_rewrite as W  # noqa: E402
from full_lessons import q  # noqa: E402
sys.argv = _argv

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261115_reading_a2_old_v2.sql'
SNAP = json.loads((Path(__file__).parent / 'reading_a2_old_snapshot.json').read_text(encoding='utf-8'))
LESSONS: dict = SNAP['lessons']          # лема → [найнижчий рівень уроку, модуль A2 або None]
MIN_KNOWN = 0.9
WORDS = (60, 140)
NOTE_KEEP = ('reading_a2_old_v2 2026-11-15: знайомі слова перераховано за A2 v2 (уроки A0, A1 і A2 до модуля тексту), '
             'позначка «з уроків» — за уроками A0–A2. Текст і питання не змінено.')
NOTE_NEW = ('reading_a2_old_v2 2026-11-15: текст переписано наново словами уроків A0–A2 (було < 90 % знайомих). '
            'Бета, потрібна перевірка носієм.')
# модуль тексту = reading_texts.module_order у базі (тексти розкладено по модулях A2 v2 пакетом 20261112_curriculum_a2_v2_00_structure)
MODULE = {'RD-A2-001': 3, 'RD-A2-002': 3, 'RD-A2-003': 1, 'RD-A2-004': 1, 'RD-A2-005': 5, 'RD-A2-006': 5,
          'RD-A2-007': 6, 'RD-A2-008': 6, 'RD-A2-009': 7, 'RD-A2-010': 7, 'RD-A2-011': 4, 'RD-A2-012': 4,
          'RD-A2-013': 9, 'RD-A2-014': 9, 'RD-A2-015': 13, 'RD-A2-016': 13, 'RD-A2-017': 10, 'RD-A2-018': 10,
          'RD-A2-019': 14, 'RD-A2-020': 14}

errors: list[str] = []

# ---------------------------------------------------------------- дані для генератора A2 v2 (6 нових текстів)
N.SNAP.update({k: v for k, v in SNAP['lexemes'].items()})
N.L.NAMES.update(W.NAMES)
for _t in W.TEXTS:
    N.ANN[_t['key']] = N.parse_ann(W.TEXT_ANN[_t['key']], _t['key'])
NEW = {t['code']: t for t in W.TEXTS}
OLD = {t['code']: t for t in R.D2.TEXTS}


def lesson_known(key: str, module: int) -> tuple[bool, bool | None]:
    """(слово з уроків A0–A2?, знайоме для модуля?) — None, якщо слова немає в уроках."""
    if key not in LESSONS:
        return False, None
    lvl, mo = LESSONS[key]
    return True, (lvl in ('A0', 'A1') or (mo is not None and mo <= module))


# ---------------------------------------------------------------- 14 текстів: словничок старого генератора, нові позначки
def keep_glossary(t) -> tuple[list[dict], float, int]:
    module = MODULE[t['code']]
    entries, _old_ratio, n = R.glossary(t)
    for e in entries:
        e['lesson'] = e['lemma'].lower() in LESSONS
    toks = R.words(t['hr'])
    known = 0
    for tok in toks:
        r = R.resolve(t['code'], tok)
        if r is None:
            continue
        lemma, _ua, old_known = r
        key = lemma.lower()
        _in, k = lesson_known(key, module)
        if k is None:  # слова немає в уроках: службове слово / власна назва — як було; колишнє слово уроків — ні
            k = old_known and not (key in R.LEX and R.LEX[key][2] and key not in R.X.KNOWN)
        known += k
    return entries, known / len(toks), n


# ---------------------------------------------------------------- 6 нових текстів
def new_glossary(t) -> tuple[list[dict], float, int]:
    t = dict(t, module=MODULE[t['code']])
    seen: dict[str, dict] = {}
    known = 0
    toks = R.words(t['hr'])
    for tok in toks:
        r = N.resolve(t, tok)
        key = r['lemma'].lower()
        is_name = r['lemma'] in N.L.NAMES or N.name_info(tok) is not None and N.name_info(tok)[0] == r['lemma']
        in_lessons, k = lesson_known(key, t['module'])
        if k is None:
            k = is_name or key in R.X.KNOWN or key in N.L.KNOWN
        known += k
        low = tok.lower()
        if low in seen:
            continue
        e = {'form': low, 'lemma': r['lemma'], 'ua': r['ua'], 'lesson': in_lessons}
        if r['pos']:
            e['pos'] = R.render_pos(r['pos'])
        if r['gram']:
            e['gram'] = N.render_gram(r['gram'], r['lemma'])
        seen[low] = e
    return list(seen.values()), known / len(toks), len(toks)


def unknown(t) -> list[str]:
    t = dict(t, module=MODULE[t['code']])
    out = set()
    for tok in R.words(t['hr']):
        r = N.resolve(t, tok)
        key = r['lemma'].lower()
        _in, k = lesson_known(key, t['module'])
        if k is None:
            k = r['lemma'] in N.L.NAMES or N.name_info(tok) is not None or key in R.X.KNOWN or key in N.L.KNOWN
        if not k:
            out.add(r['lemma'])
    return sorted(out)


# ---------------------------------------------------------------- перевірки
def validate():
    if set(NEW) != {'RD-A2-007', 'RD-A2-008', 'RD-A2-010', 'RD-A2-013', 'RD-A2-018', 'RD-A2-019'}:
        errors.append(f'переписані тексти: {sorted(NEW)}')
    if set(OLD) != set(MODULE):
        errors.append('старі тексти A2 — не RD-A2-001…020')
    for code, t in sorted(OLD.items()):
        if code in NEW:
            continue
        _g, ratio, _n = keep_glossary(t)
        if ratio < MIN_KNOWN:
            errors.append(f'{code}: знайомих {ratio:.0%} — < 90 %, його теж треба переписати')
    for code, t in sorted(NEW.items()):
        w = f'{code} ({t["key"]})'
        if t['module'] != MODULE[code]:
            errors.append(f'{w}: модуль {t["module"]}, у базі — {MODULE[code]}')
        if t['type'] not in R.TYPES or t['type'] == 'sign' or t['situation'] not in R.SITUATIONS:
            errors.append(f'{w}: тип / ситуація')
        ua_title, hr_title = t['title']
        if not R.CYR.search(ua_title) or R.CYR.search(hr_title):
            errors.append(f'{w}: назва')
        if R.CYR.search(t['hr']):
            errors.append(f'{w}: кирилиця в хорватському тексті')
        if not R.CYR.search(t['ua']) or re.search(r'[ыэъё]', t['ua'].lower()):
            errors.append(f'{w}: переклад має бути українською (без ы, э, ъ, ё)')
        n = len(R.words(t['hr']))
        if not (WORDS[0] <= n <= WORDS[1]):
            errors.append(f'{w}: {n} слів (для A2: {WORDS[0]}–{WORDS[1]})')
        if len(t['questions']) != 3:
            errors.append(f'{w}: потрібно 3 питання')
        for qu, opts, ans in t['questions']:
            if (not R.CYR.search(qu) or len(opts) != 3 or len(set(opts)) != 3 or ans not in opts
                    or any(re.search(r'[A-Za-zČĆĐŠŽčćđšž]{3,}', o) for o in opts)):
                errors.append(f'{w}: питання «{qu}» — 3 різні варіанти українською, серед них відповідь')
        used = {tok.lower() for tok in R.words(t['hr'])}
        for form in N.ANN[t['key']]:
            if form not in used:
                errors.append(f'{w}: у словничку є «{form}», але в тексті такого слова немає')
        entries, ratio, _ = new_glossary(t)
        for e in entries:
            ua = (e['ua'] or '').strip()
            if not ua or not R.CYR.search(ua) or ua.lower() in R.PLACEHOLDERS:
                errors.append(f'{w}: «{e["form"]}» ({e["lemma"]}) — немає перекладу')
            if R.CYR.search(e['lemma']):
                errors.append(f'{w}: «{e["form"]}» — лема кирилицею')
            if 'pos' not in e:
                errors.append(f'{w}: «{e["lemma"]}» — немає частини мови')
            if e['form'] != e['lemma'].lower() and 'gram' not in e:
                errors.append(f'{w}: «{e["form"]}» ({e["lemma"]}) — немає граматичної підказки')
            for k in ('pos', 'gram'):
                if k in e and (len(e[k]) > 160 or not R.CYR.search(e[k])):
                    errors.append(f'{w}: «{e["form"]}» — {k} має бути українською, до 160 символів: {e[k]!r}')
        if ratio < MIN_KNOWN:
            errors.append(f'{w}: знайомих слів {ratio:.0%} (потрібно ≥ 90 %); незнайомі: {", ".join(unknown(t))}')


# ---------------------------------------------------------------- SQL
def rows() -> tuple[list[dict], list[dict]]:
    keep, new = [], []
    for code, t in sorted(OLD.items()):
        if code in NEW:
            continue
        g, ratio, _n = keep_glossary(t)
        keep.append({'code': code, 'glossary': g, 'known_ratio': round(ratio, 3)})
    for code, t in sorted(NEW.items()):
        g, ratio, n = new_glossary(t)
        new.append({'code': code, 'text_type': t['type'], 'situation': t['situation'], 'title_ua': t['title'][0],
                    'title_hr': t['title'][1], 'body_hr': t['hr'], 'body_ua': t['ua'], 'glossary': g,
                    'questions': [{'question_ua': qu, 'options': opts, 'answer': ans} for qu, opts, ans in t['questions']],
                    'word_count': n, 'known_ratio': round(ratio, 3)})
    return keep, new


def build() -> str:
    keep, new = rows()
    pk = json.dumps(keep, ensure_ascii=False).replace("'", "''")
    pn = json.dumps(new, ensure_ascii=False).replace("'", "''")
    if '$old$' in pk + pn:
        raise SystemExit('у даних трапився роздільник $old$')
    codes_new = ', '.join(q(r['code']) for r in new)
    return f"""-- =====================================================================
-- Тексти для читання A2: 20 старих текстів під програму A2 v2 · 2026-11-15
-- Згенеровано: python3 -B scripts/gen_reading_a2_old_fix.py (не редагуйте вручну).
--   * {len(keep)} текстів: знайомі слова перераховано — уроки A0, A1 і A2 до модуля тексту (раніше — лише A0–A1);
--     позначка «з уроків» — за уроками A0–A2. Змінює лише glossary і known_ratio; текст і питання — ні.
--   * {len(new)} текстів ({', '.join(r['code'] for r in new)}) переписано наново словами уроків: було < 90 % знайомих.
--     Той самий код і тема; новий текст, переклад, питання, словничок.
--   * Стара версія кожного зміненого тексту — у content_versions, запис — у content_reviews. Статус не змінюється.
--   * Одна дія (або все, або нічого). Повторний запуск нічого не змінює.
-- Запуск: workflow «Apply SQL (production)» після мержу й Approve власника. Очікуване повідомлення: «Готово: …».
-- =====================================================================

do $old$
declare
  v_keep jsonb := '{pk}'::jsonb;
  v_new jsonb := '{pn}'::jsonb;
  v_same int; v_low int; v_bad int; v_k int; v_n int;
begin
  if (select count(*) from public.reading_texts where cefr = 'A2' and code between 'RD-A2-001' and 'RD-A2-020') <> 20 then
    raise exception 'Немає 20 старих текстів A2 (RD-A2-001…020)';
  end if;

  -- 1. Стара версія змінених текстів
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'reading_text', r.id,
         coalesce((select max(v.version) from public.content_versions v where v.entity_type = 'reading_text' and v.entity_id = r.id), 0) + 1,
         to_jsonb(r), {q(NOTE_KEEP)}
    from public.reading_texts r
    join jsonb_to_recordset(v_keep) as g(code text, glossary jsonb, known_ratio numeric) on g.code = r.code
   where r.glossary is distinct from g.glossary or r.known_ratio is distinct from g.known_ratio;
  insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
  select 'reading_text', r.id,
         coalesce((select max(v.version) from public.content_versions v where v.entity_type = 'reading_text' and v.entity_id = r.id), 0) + 1,
         to_jsonb(r), {q(NOTE_NEW)}
    from public.reading_texts r
    join jsonb_to_recordset(v_new) as g(code text, body_hr text) on g.code = r.code
   where r.body_hr is distinct from g.body_hr;

  -- 2. {len(keep)} текстів: словничок і частка знайомих
  with changed as (
    update public.reading_texts r
       set glossary = g.glossary, known_ratio = g.known_ratio, version = r.version + 1
      from jsonb_to_recordset(v_keep) as g(code text, glossary jsonb, known_ratio numeric)
     where g.code = r.code and (r.glossary is distinct from g.glossary or r.known_ratio is distinct from g.known_ratio)
    returning r.id, r.status
  ), logged as (
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    select 'reading_text', c.id, c.status, c.status, 'auto_passed', 'script', '[]'::jsonb, {q(NOTE_KEEP)} from changed c
    returning 1
  )
  select count(*) into v_k from logged;

  -- 3. {len(new)} текстів наново
  with changed as (
    update public.reading_texts r
       set text_type = g.text_type, situation = g.situation, title_ua = g.title_ua, title_hr = g.title_hr,
           body_hr = g.body_hr, body_ua = g.body_ua, glossary = g.glossary, questions = g.questions,
           word_count = g.word_count, known_ratio = g.known_ratio, version = r.version + 1
      from jsonb_to_recordset(v_new)
        as g(code text, text_type text, situation text, title_ua text, title_hr text, body_hr text, body_ua text,
             glossary jsonb, questions jsonb, word_count int, known_ratio numeric)
     where g.code = r.code and r.body_hr is distinct from g.body_hr
    returning r.id, r.status
  ), logged as (
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    select 'reading_text', c.id, c.status, c.status, 'auto_passed', 'ai', '[]'::jsonb, {q(NOTE_NEW)} from changed c
    returning 1
  )
  select count(*) into v_n from logged;

  -- Самоперевірка: якщо щось не так — усе відкочується
  select count(*) into v_same from public.reading_texts r
    join jsonb_to_recordset(v_keep) as g(code text, glossary jsonb, known_ratio numeric) on g.code = r.code
   where r.glossary = g.glossary and r.known_ratio = g.known_ratio;
  select count(*) into v_low from public.reading_texts where cefr = 'A2' and status = 'PUBLISHED' and known_ratio < {MIN_KNOWN};
  select count(*) into v_bad from public.reading_texts r where r.code in ({codes_new})
     and (jsonb_array_length(r.questions) <> 3 or r.word_count not between {WORDS[0]} and {WORDS[1]}
          or exists (select 1 from jsonb_array_elements(r.glossary) e
                     where e->>'pos' is null or coalesce(e->>'ua', '') = ''
                        or (e->>'gram' is null and e->>'form' <> lower(e->>'lemma'))));
  if v_same <> {len(keep)} then raise exception 'Узгоджено текстів %, очікувалось {len(keep)}', v_same; end if;
  if v_low > 0 then raise exception 'Текстів A2 з часткою знайомих < 90 %%: %', v_low; end if;
  if v_bad > 0 then raise exception '% переписаних текстів без питань, словничка чи граматичних підказок', v_bad; end if;
  raise notice 'Готово: тексти A2 — перераховано зараз %, переписано зараз %; у всіх текстах A2 ≥ 90 %% знайомих слів', v_k, v_n;
end
$old$;
"""


def stats() -> str:
    out = []
    for code, t in sorted(OLD.items(), key=lambda x: (MODULE[x[0]], x[0])):
        _g, was, _n = R.glossary(t)
        if code in NEW:
            _g2, now, n = new_glossary(NEW[code])
            out.append(f'{code} A2.{MODULE[code]:<2} наново  {was:6.1%} → {now:6.1%} ({n} сл.)  незнайомі: {", ".join(unknown(NEW[code]))}')
        else:
            _g2, now, n = keep_glossary(t)
            out.append(f'{code} A2.{MODULE[code]:<2} лишився {was:6.1%} → {now:6.1%} ({n} сл.)')
    return '\n'.join(out)


def export() -> str:
    out = []
    for code, t in sorted(NEW.items()):
        gl, ratio, n = new_glossary(t)
        out.append(f"## {code} · A2.{MODULE[code]} · {t['title'][0]} ({n} сл., {ratio:.0%} знайомих)\n")
        for e in gl:
            out.append(f"- **{e['form']}** → {e['lemma']} — {e['ua']} · _{e.get('pos', '?')}_" + (f" · {e['gram']}" if 'gram' in e else '')
                       + ('' if e['lesson'] else ' · (не з уроків)'))
        out.append('')
    return '\n'.join(out)


if __name__ == '__main__':
    validate()
    if '--stats' in sys.argv:
        print(stats())
        print('ПОМИЛОК:', len(errors), *errors, sep='\n  ')
        sys.exit(0)
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    if '--export' in sys.argv:
        print(export())
        sys.exit(0)
    sql = build()
    OUT.write_text(sql, encoding='utf-8')
    print(f'OK → {OUT.relative_to(ROOT)}: {len(sql.encode()) // 1024} КБ')
