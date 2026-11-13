#!/usr/bin/env python3
"""
Генератор SQL: типові помилки українців, пакет v2 · 2026-11-13.

  python3 -B scripts/gen_interference_v2_20261113.py           →  supabase/data_fixes/20261113_interference_v2.sql
  python3 -B scripts/gen_interference_v2_20261113.py --review  →  таблиця нових записів (для звіту)

Дані: scripts/interference_data_v2.py (нові записи + виправлення v1). v1 (interference_data.py) не змінюється.
Перевірки — ті самі, що в gen_interference.py, + без повторів з v1, тема граматики лише A0 / A1 (як у тесті
interference.test.sql), «правильно» у вимові й наголосі починається з хорватського слова (для кнопки 🔊).
"""
import re
import sys
from pathlib import Path

sys.dont_write_bytecode = True
sys.path.insert(0, str(Path(__file__).parent))
import interference_data as V1  # noqa: E402
import interference_data_v2 as D  # noqa: E402
from full_lessons import q, qj  # noqa: E402

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / 'supabase' / 'data_fixes' / '20261113_interference_v2.sql'
SOURCE = 'claude_interference_v2'
STATUS = 'PUBLISHED'  # бета, як v1 і уроки A0–B1 (рішення власника)
REVIEW_NOTE = 'Бета: типові помилки v2 (вид дієслова, артиклі, вимова) — борг PROJECT_STATE 2026-11-13. Потрібна перевірка носієм.'
FIX_NOTE = 'interference_v2 2026-11-13: уточнено підказку вимови кирилицею (було «майже «кутя»» — плутає з «т»). Потрібна перевірка носієм.'
CYR = re.compile(r'[Ѐ-ӿ]')
SPOKEN = {'pronunciation', 'stress'}
FIRST = len(V1.ERRORS) + 1  # 75

errors: list[str] = []


def code(i: int) -> str:
    return f'UKR-HR-{i:04d}'


def spoken_word(text: str) -> str:
    """Хорватське слово перед « — » у підказці вимови (те саме робить spokenSample у lib/interference.ts)."""
    head = text.split(' — ', 1)[0].strip()
    return head if head and ' — ' in text and not CYR.search(head) else ''


def validate():
    seen = {(r[5], r[6]) for r in V1.ERRORS}
    v1_by_code = {code(i): r for i, r in enumerate(V1.ERRORS, 1)}
    for n, row in enumerate(D.ERRORS):
        w = code(FIRST + n)
        if len(row) != 9:
            errors.append(f'{w}: має бути 9 полів, а є {len(row)}')
            continue
        cat, cefr, grammar, lemma, title, wrong, right, expl, examples = row
        if cat not in V1.CATEGORIES:
            errors.append(f'{w}: невідома категорія {cat!r}')
        if cefr not in ('A0', 'A1', 'A2', 'B1', 'B2'):
            errors.append(f'{w}: рівень {cefr!r}')
        if grammar is not None:
            lvl, _, title_ua = grammar.partition(':')
            if lvl not in ('A0', 'A1') or not title_ua:
                errors.append(f'{w}: тема граматики — «A0:<назва>» або «A1:<назва>»: {grammar!r}')
        if not CYR.search(title) or not CYR.search(expl):
            errors.append(f'{w}: назва й пояснення — українською')
        if not (10 <= len(expl) <= 600) or not (3 <= len(title) <= 120) or not (1 <= len(wrong) <= 200) or not (1 <= len(right) <= 200):
            errors.append(f'{w}: довжина полів')
        if wrong == right:
            errors.append(f'{w}: «неправильно» = «правильно»')
        if cat not in SPOKEN and (CYR.search(wrong) or CYR.search(right)):
            errors.append(f'{w}: «неправильно / правильно» — хорватською (кирилиця лише для вимови й наголосу)')
        if cat in SPOKEN and not spoken_word(right):
            errors.append(f'{w}: підказка вимови — «слово — «підказка»»: {right!r}')
        if (wrong, right) in seen:
            errors.append(f'{w}: такий запис уже є')
        seen.add((wrong, right))
        if len(examples) != 2:
            errors.append(f'{w}: потрібно 2 приклади')
        for hr, ua in examples:
            if CYR.search(hr) or not CYR.search(ua):
                errors.append(f'{w}: приклад — (хорватською, українською): {hr!r}')
            if not hr.strip().endswith(('.', '!', '?')):
                errors.append(f'{w}: приклад має бути реченням: {hr!r}')
        if lemma is not None and lemma != lemma.lower():
            errors.append(f'{w}: лема з малої літери: {lemma!r}')
        if 'TODO' in expl or 'приклад' == expl.strip():
            errors.append(f'{w}: заглушка')
    for c, fields in D.FIXES.items():
        if c not in v1_by_code:
            errors.append(f'{c}: виправлення для невідомого запису')
            continue
        if set(fields) - {'correct_text', 'incorrect_text', 'explanation_ua', 'title_ua'}:
            errors.append(f'{c}: виправляти можна лише тексти')
        r = v1_by_code[c]
        if r[0] in SPOKEN and 'correct_text' in fields and not spoken_word(fields['correct_text']):
            errors.append(f'{c}: підказка вимови — «слово — «підказка»»')
        if fields.get('correct_text', r[6]) == fields.get('incorrect_text', r[5]):
            errors.append(f'{c}: «неправильно» = «правильно»')


def grammar_sql(grammar):
    if grammar is None:
        return 'null'
    lvl, _, title_ua = grammar.partition(':')
    return (f"(select id from public.grammar_topics where cefr = {q(lvl)} and title_ua = {q(title_ua)} "
            "and status = 'PUBLISHED' order by created_at limit 1)")


def build() -> str:
    n = len(D.ERRORS)
    last = FIRST + n - 1
    by_cat: dict[str, int] = {}
    for r in D.ERRORS:
        by_cat[r[0]] = by_cat.get(r[0], 0) + 1
    linked = [code(FIRST + i) for i, r in enumerate(D.ERRORS) if r[2] or r[3]]
    out = [f"""-- =====================================================================
-- Типові помилки українців (§19) · interference_v2 · 2026-11-13
-- Згенеровано: python3 -B scripts/gen_interference_v2_20261113.py (не редагуйте вручну).
-- Борг docs/PROJECT_STATE.md: «типові помилки: вимова — підказки кирилицею; мало «артиклів» і «виду дієслова»».
--
--   * +{n} помилок, коди {code(FIRST)}…{code(last)}: {', '.join(f'{c} {k}' for c, k in by_cat.items())}.
--     Разом у каталозі стане {FIRST - 1 + n}: вид дієслова 2 → {2 + by_cat.get('aspect', 0)}, артиклі 1 → {1 + by_cat.get('articles', 0)}, вимова 5 → {5 + by_cat.get('pronunciation', 0)}.
--   * Прив'язка до тем граматики A0 / A1 і слів — картка «Українці часто помиляються» в уроці.
--   * Виправлено {len(D.FIXES)} запис(и) v1: {', '.join(D.FIXES)} (підказка вимови). Стара версія — у content_versions.
--   * Статус {STATUS}: бета (носій ще не перевіряв). Повторний запуск нічого не змінює.
-- Після нього: тест supabase/tests/interference_v2.test.sql → «ALL TESTS PASSED».
-- Очікуване повідомлення: «Готово: типових помилок — {FIRST - 1 + n}, нових — {n}, вид дієслова — {2 + by_cat.get('aspect', 0)}, артиклі — {1 + by_cat.get('articles', 0)}, вимова — {5 + by_cat.get('pronunciation', 0)}».
-- =====================================================================

begin;

do $$
begin
  if (select count(*) from public.linguistic_errors where code between {q(code(1))} and {q(code(FIRST - 1))}) < {FIRST - 1} then
    raise exception 'Спершу потрібен каталог v1 (20261013_interference_v1.sql)';
  end if;
end $$;
"""]
    for i, (cat, cefr, grammar, lemma, title, wrong, right, expl, examples) in enumerate(D.ERRORS):
        ex = [{'hr': hr, 'ua': ua} for hr, ua in examples]
        lex = (f"(select id from public.lexemes where lower(lemma) = lower({q(lemma)}) and status = 'PUBLISHED' order by created_at limit 1)"
               if lemma else 'null')
        out.append(
            'insert into public.linguistic_errors (code, category, cefr, title_ua, incorrect_text, correct_text, explanation_ua, examples, grammar_topic_id, lexeme_id, status, source)\n'
            f'values ({q(code(FIRST + i))}, {q(cat)}, {q(cefr)}, {q(title)}, {q(wrong)}, {q(right)}, {q(expl)}, {qj(ex)},\n'
            f'        {grammar_sql(grammar)}, {lex}, {q(STATUS)}, {q(SOURCE)})\n'
            'on conflict (code) do nothing;'
        )
    out.append(f"""
-- Журнал перевірки (один запис на кожну нову помилку)
insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
select 'linguistic_error', e.id, null, '{STATUS}', 'auto_passed', 'ai', '[]'::jsonb, {q(REVIEW_NOTE)}
from public.linguistic_errors e
where e.source = {q(SOURCE)}
  and not exists (select 1 from public.content_reviews r where r.entity_id = e.id and r.notes = {q(REVIEW_NOTE)});
""")
    for c, fields in D.FIXES.items():
        sets = ', '.join(f'{k} = {q(v)}' for k, v in fields.items())
        differs = ' or '.join(f'x.{k} is distinct from {q(v)}' for k, v in fields.items())
        out.append(f"""-- Виправлення {c}
do $fix$
declare x public.linguistic_errors%rowtype;
begin
  select * into x from public.linguistic_errors where code = {q(c)};
  if x.id is null then raise exception 'Немає запису {c}'; end if;
  if {differs} then
    insert into public.content_versions (entity_type, entity_id, version, payload, change_reason)
    values ('linguistic_error', x.id, coalesce((select max(version) from public.content_versions where entity_type = 'linguistic_error' and entity_id = x.id), 0) + 1,
            to_jsonb(x), {q(FIX_NOTE)});
    update public.linguistic_errors set {sets}, version = version + 1 where id = x.id;
    insert into public.content_reviews (entity_type, entity_id, from_status, to_status, verdict, reviewer_kind, findings, notes)
    values ('linguistic_error', x.id, x.status, x.status, 'auto_passed', 'ai', '[]'::jsonb, {q(FIX_NOTE)});
  end if;
end $fix$;
""")
    out.append(f"""-- Самоперевірка: якщо щось не так — усе відкочується
do $$
declare v_total int; v_new int; v_aspect int; v_art int; v_pron int; v_no_link int; v_bad_grammar int;
begin
  select count(*) into v_total from public.linguistic_errors where status = '{STATUS}';
  select count(*) into v_new from public.linguistic_errors where source = {q(SOURCE)} and status = '{STATUS}';
  select count(*) filter (where category = 'aspect'), count(*) filter (where category = 'articles'), count(*) filter (where category = 'pronunciation')
    into v_aspect, v_art, v_pron from public.linguistic_errors where status = '{STATUS}';
  select count(*) into v_no_link from public.linguistic_errors
   where source = {q(SOURCE)} and grammar_topic_id is null and lexeme_id is null
     and code in ({', '.join(q(c) for c in linked)});
  select count(*) into v_bad_grammar from public.linguistic_errors e
   where e.source = {q(SOURCE)} and e.grammar_topic_id is not null
     and not exists (select 1 from public.grammar_topics g where g.id = e.grammar_topic_id and g.cefr in ('A0', 'A1'));
  if v_new < {n} then raise exception 'Нових типових помилок %, очікувалось {n}', v_new; end if;
  if v_no_link > 0 then raise exception '% нових помилок не знайшли свою тему граматики чи слово', v_no_link; end if;
  if v_bad_grammar > 0 then raise exception '% нових помилок прив''язано не до тем A0 / A1', v_bad_grammar; end if;
  if exists (select 1 from public.linguistic_errors where code = 'UKR-HR-0060' and correct_text like '%кутя%') then
    raise exception 'UKR-HR-0060 не виправлено';
  end if;
  raise notice 'Готово: типових помилок — %, нових — %, вид дієслова — %, артиклі — %, вимова — %', v_total, v_new, v_aspect, v_art, v_pron;
end $$;

commit;
""")
    return '\n'.join(out)


def review_table() -> str:
    rows = ['| Код | Категорія | Рівень | Помилка | Неправильно | Правильно |', '|---|---|---|---|---|---|']
    for i, (cat, cefr, grammar, lemma, title, wrong, right, expl, ex) in enumerate(D.ERRORS):
        rows.append(f'| {code(FIRST + i)} | {V1.CATEGORIES[cat]} | {cefr} | {title} | ~~{wrong}~~ | **{right}** |')
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
    print(f'OK → {OUT.relative_to(ROOT)}: +{len(D.ERRORS)} помилок, виправлень {len(D.FIXES)}, {len(sql.encode()) // 1024} КБ')
