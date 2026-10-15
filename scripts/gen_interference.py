#!/usr/bin/env python3
"""
Генератор SQL для каталогу типових помилок українців (§19 ТЗ), v1 · 2026-10-13.

  python3 scripts/gen_interference.py           →  supabase/data_fixes/20261013_interference_v1.sql
  python3 scripts/gen_interference.py --review  →  таблиця всіх помилок (для звіту)

Дані: scripts/interference_data.py. Потрібна міграція M14 (linguistic_errors).
Скрипт спершу перевіряє дані й зупиняється, якщо щось не так. SQL ідемпотентний (код UKR-HR-NNNN унікальний).
"""
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import curriculum_a1_data as A1  # noqa: E402
import interference_data as D  # noqa: E402
from full_lessons import q, qj, uid  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261013_interference_v1.sql'
SOURCE = 'claude_interference_v1'
STATUS = 'PUBLISHED'  # бета, як уроки A0/A1 (рішення власника); 'DRAFT' — лише для адміна до перевірки носієм
REVIEW_NOTE = 'Бета: каталог типових помилок українців (§19) за запитом власника 2026-10-13 (interference_v1). Потрібна перевірка носієм.'
CYR = re.compile(r'[Ѐ-ӿ]')
SPOKEN = {'pronunciation', 'stress'}  # «неправильно / правильно» — підказка вимови кирилицею

errors: list[str] = []


def code(i: int) -> str:
    return f'UKR-HR-{i:04d}'


def validate():
    seen_pairs = set()
    used_categories = set()
    for i, row in enumerate(D.ERRORS, 1):
        if len(row) != 9:
            errors.append(f'{code(i)}: має бути 9 полів, а є {len(row)}')
            continue
        cat, cefr, grammar, lemma, title, wrong, right, expl, examples = row
        w = code(i)
        used_categories.add(cat)
        if cat not in D.CATEGORIES:
            errors.append(f'{w}: невідома категорія {cat!r}')
        if cefr not in ('A0', 'A1', 'A2', 'B1', 'B2'):
            errors.append(f'{w}: рівень {cefr!r}')
        if grammar is not None:
            lvl, _, key = grammar.partition(':')
            if lvl == 'A1' and key not in A1.GRAMMAR_A1:
                errors.append(f'{w}: немає теми A1 {key!r}')
            elif lvl not in ('A0', 'A1') or not key:
                errors.append(f'{w}: тема граматики має бути «A0:назва» або «A1:ключ»: {grammar!r}')
        if not CYR.search(title) or not CYR.search(expl):
            errors.append(f'{w}: назва й пояснення — українською')
        if not (10 <= len(expl) <= 600) or not (3 <= len(title) <= 120):
            errors.append(f'{w}: довжина назви чи пояснення')
        if wrong == right:
            errors.append(f'{w}: «неправильно» = «правильно»')
        if cat not in SPOKEN and (CYR.search(wrong) or CYR.search(right)):
            errors.append(f'{w}: «неправильно / правильно» — хорватською (кирилиця лише для вимови й наголосу)')
        if (wrong, right) in seen_pairs:
            errors.append(f'{w}: такий запис уже є')
        seen_pairs.add((wrong, right))
        if len(examples) != 2:
            errors.append(f'{w}: потрібно 2 приклади')
        for hr, ua in examples:
            if CYR.search(hr) or not CYR.search(ua):
                errors.append(f'{w}: приклад — (хорватською, українською): {hr!r}')
            if not hr.strip().endswith(('.', '!', '?')):
                errors.append(f'{w}: приклад має бути реченням: {hr!r}')
        if lemma is not None and lemma != lemma.lower():
            errors.append(f'{w}: лема з малої літери: {lemma!r}')
    missing = set(D.CATEGORIES) - used_categories
    if missing:
        errors.append(f'немає записів у категоріях: {sorted(missing)}')


def grammar_sql(grammar):
    if grammar is None:
        return 'null'
    lvl, _, key = grammar.partition(':')
    if lvl == 'A1':
        return q(uid('grammar', 'A1', A1.GRAMMAR_A1[key]['skeleton'])) + '::uuid'
    return f"(select id from public.grammar_topics where cefr = 'A0' and title_ua = {q(key)} order by created_at limit 1)"


def build() -> str:
    n = len(D.ERRORS)
    by_cat = {c: sum(1 for r in D.ERRORS if r[0] == c) for c in D.CATEGORIES}
    by_lvl = {l: sum(1 for r in D.ERRORS if r[1] == l) for l in ('A0', 'A1', 'A2')}
    out = [f"""-- =====================================================================
-- Типові помилки українців (§19 ТЗ) · interference_v1 · 2026-10-13
-- Згенеровано: python3 scripts/gen_interference.py (не редагуйте вручну).
-- Запуск: Supabase → SQL Editor → вставити ВЕСЬ файл → Run. Потрібна міграція M14.
--
--   * {n} помилок, коди {code(1)}…{code(n)}; рівні: A0 {by_lvl['A0']}, A1 {by_lvl['A1']}, A2 {by_lvl['A2']}.
--   * Категорії: {', '.join(f'{c} {k}' for c, k in by_cat.items())}.
--   * Прив'язка до тем граматики A0/A1 і слів — картка «Українці часто помиляються» в уроці.
--   * Статус {STATUS}: бета, як уроки A0/A1 (носій ще не перевіряв). Повторний запуск безпечний.
-- =====================================================================

begin;

do $$
begin
  if to_regclass('public.linguistic_errors') is null then
    raise exception 'Спершу запустіть міграцію M14 (20261013160000_m14_linguistic_errors.sql)';
  end if;
end $$;
"""]
    for i, (cat, cefr, grammar, lemma, title, wrong, right, expl, examples) in enumerate(D.ERRORS, 1):
        ex = [{'hr': hr, 'ua': ua} for hr, ua in examples]
        lex = (f"(select id from public.lexemes where lower(lemma) = lower({q(lemma)}) and status = 'PUBLISHED' order by created_at limit 1)"
               if lemma else 'null')
        out.append(
            'insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)\n'
            f'values ({q(code(i))}, {q(cat)}, {q(cefr)}, {q(title)}, {q(wrong)}, {q(right)}, {q(expl)}, {qj(ex)},\n'
            f'        {grammar_sql(grammar)}, {lex}, {q(STATUS)}, {q(SOURCE)})\n'
            'on conflict (code) do nothing;'
        )
    out.append(f"""
-- Журнал перевірки (один запис на кожну помилку)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'linguistic_error', e.id, null, '{STATUS}', 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)}
from public.linguistic_errors e
where e.source = {q(SOURCE)}
  and not exists (select 1 from public.content_reviews r where r.entity_id = e.id and r.notes = {q(REVIEW_NOTE)});

-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_cats int; v_no_link int;
begin
  select count(*), count(distinct category) into v_total, v_cats from public.linguistic_errors where source = {q(SOURCE)} and status = '{STATUS}';
  select count(*) into v_no_link from public.linguistic_errors
   where source = {q(SOURCE)} and grammar_topic_id is null and lexeme_id is null and cefr in ('A0', 'A1')
     and code in ({', '.join(q(code(i)) for i, r in enumerate(D.ERRORS, 1) if r[2] or r[3])});
  if v_total < {n} then raise exception 'Типових помилок %, очікувалось {n}', v_total; end if;
  if v_cats < 12 then raise exception 'Категорій %, очікувалось 12', v_cats; end if;
  if v_no_link > 0 then raise exception '% помилок не знайшли свою тему граматики чи слово', v_no_link; end if;
  raise notice 'Готово: типових помилок — %, категорій — %', v_total, v_cats;
end $$;

commit;
""")
    return '\n'.join(out)


def review_table() -> str:
    rows = ['| Код | Категорія | Рівень | Помилка | Неправильно | Правильно |', '|---|---|---|---|---|---|']
    for i, (cat, cefr, grammar, lemma, title, wrong, right, expl, ex) in enumerate(D.ERRORS, 1):
        rows.append(f'| {code(i)} | {D.CATEGORIES[cat]} | {cefr} | {title} | ~~{wrong}~~ | **{right}** |')
    return '\n'.join(rows)


if __name__ == '__main__':
    validate()
    if errors:
        print('ПОМИЛКИ В ДАНИХ:', *errors, sep='\n  ')
        sys.exit(1)
    if '--review' in sys.argv:
        print(review_table())
        sys.exit(0)
    sql = build()
    OUT.write_text(sql, encoding='utf-8')
    print(f'OK → {OUT.relative_to(ROOT)}: {len(D.ERRORS)} помилок, {len(sql.encode()) // 1024} КБ')
